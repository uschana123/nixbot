prefix =   /usr/local

CC = /Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/arm-apple-darwin10-gcc-4.2.1
LDFLAGS  =  -framework CoreFoundation -framework Foundation -F/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS3.2.sdk/System/Library/Frameworks -L/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS3.2.sdk/usr/lib -framework Foundation -framework CoreFoundation -framework UIKit -L/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS3.2.sdk/System/Library/Frameworks/IOKit.framework/Versions/A /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS3.2.sdk/System/Library/PrivateFrameworks/BluetoothManager.framework/BluetoothManager -lIOKit -lobjc
CPPFLAGS =  -I/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS3.2.sdk/usr/include -I/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS3.2.sdk/usr/lib/gcc/arm-apple-darwin10/4.2.1/include -F/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS3.2.sdk/System/Library/Frameworks -Werror -I../include
BTSTACK_LIB_LDFLAGS = -dynamiclib -install_name $(prefix)/lib/libBTstack.dylib
BTSTACK_LIB_EXTENSION = dylib

remote_device_db_sources = remote_device_db_iphone.m
run_loop_sources = run_loop_posix.c run_loop_embedded.c run_loop_cocoa.m
springboard_access_sources = ../SpringBoardAccess/SpringBoardAccess.c
usb_sources = 

libBTstack_SOURCES = btstack.c hci_cmds.c linked_list.c run_loop.c $(run_loop_sources) sdp_util.c socket_connection.c utils.c
			  
BTdaemon_SOURCES =  $(libBTstack_SOURCES) \
    bt_control_iphone.m     \
    daemon.c                \
    hci.c                   \
    hci_dump.c              \
    hci_transport_h4.c      \
    $(usb_sources)          \
    l2cap.c                 \
    l2cap_signaling.c       \
    $(remote_device_db_sources)  \
    platform_iphone.c       \
    sdp.c                   \
    $(springboard_access_sources)

all: libBTstack.$(BTSTACK_LIB_EXTENSION) libBTstack.a BTdaemon

libBTstack.$(BTSTACK_LIB_EXTENSION): $(libBTstack_SOURCES)
		./get_version.sh
		$(CC) $(CPPFLAGS) $(BTSTACK_LIB_LDFLAGS) -o $@ $(libBTstack_SOURCES) $(LDFLAGS)
		# export CODESIGN_ALLOCATE=/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/codesign_allocate ; ldid -S $@

libBTstack.a: $(libBTstack_SOURCES:.c=.o) $(libBTstack_SOURCES:.m=.o)
		ar cru $@ $(libBTstack_SOURCES:.c=.o) $(libBTstack_SOURCES:.m=.o)
		ranlib $@

BTdaemon: $(BTdaemon_SOURCES)
		$(CC) $(CPPFLAGS) -o $@ $(BTdaemon_SOURCES) $(LDFLAGS)
		# export CODESIGN_ALLOCATE=/Developer/Platforms/iPhoneOS.platform/Developer/usr/bin/codesign_allocate ; ldid -S $@

clean:
	rm -rf libBTstack* BTdaemon *.o
	
install:    
	echo "installing BTdaemon in $(prefix)..."
	mkdir -p $(prefix)/bin $(prefix)/lib $(prefix)/include
	cp libBTstack.a libBTstack.dylib $(prefix)/lib/
	cp BTdaemon $(prefix)/bin/
	cp -r ../include/btstack $(prefix)/include
