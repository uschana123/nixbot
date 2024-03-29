/*
 * Copyright (C) 2009 by Matthias Ringwald
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holders nor the names of
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY MATTHIAS RINGWALD AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MATTHIAS
 * RINGWALD OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
 * OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
 * AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */

/*
 *  run_loop_cocoa.c
 *
 *  Created by Matthias Ringwald on 8/2/09.
 */

#include <btstack/btstack.h>

#include <btstack/run_loop.h>
#include "run_loop_private.h"

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

#include <stdio.h>
#include <stdlib.h>

static void theCFRunLoopTimerCallBack (CFRunLoopTimerRef timer,void *info){
    timer_source_t * ts = (timer_source_t*)info;
    ts->process(ts);
}

static void socketDataCallback (
						 CFSocketRef s,
						 CFSocketCallBackType callbackType,
						 CFDataRef address,
						 const void *data,
						 void *info) {
	
    if (callbackType == kCFSocketReadCallBack && info){
        data_source_t *ds = (data_source_t *) info;
        ds->process(ds);
    }
}

void cocoa_add_data_source(data_source_t *dataSource){

	// add fd as CF "socket"
	
	// store our dataSource in socket context
	CFSocketContext socketContext;
	bzero(&socketContext, sizeof(CFSocketContext));
	socketContext.info = dataSource;

	// create CFSocket from file descriptor
	CFSocketRef socket = CFSocketCreateWithNative (
										  kCFAllocatorDefault,
										  dataSource->fd,
										  kCFSocketReadCallBack,
										  socketDataCallback,
										  &socketContext
    );
    
	// create run loop source
	CFRunLoopSourceRef socketRunLoop = CFSocketCreateRunLoopSource ( kCFAllocatorDefault, socket, 0);
    
    // hack: store CFSocketRef in next pointer of linked_item
    dataSource->item.next = (void *) socketRunLoop;

    // add to run loop
	CFRunLoopAddSource( CFRunLoopGetCurrent(), socketRunLoop, kCFRunLoopCommonModes);
    // printf("cocoa_add_data_source %x, socketRunLoop %x, runLoop %x\n", (int) dataSource, (int) socketRunLoop, (int) CFRunLoopGetCurrent());
}

int  cocoa_remove_data_source(data_source_t *dataSource){
    // printf("cocoa_remove_data_source socketRunLoop %x, runLoop %x\n", (int) dataSource->item.next, CFRunLoopGetCurrent());
    CFRunLoopRemoveSource( CFRunLoopGetCurrent(), (CFRunLoopSourceRef) dataSource->item.next, kCFRunLoopCommonModes);
	return 0;
}

void  cocoa_add_timer(timer_source_t * ts)
{
    // printf("cocoa_add_timer %x\n", (int) ts);
    CFTimeInterval fireDate = ((double)ts->timeout.tv_sec) + (((double)ts->timeout.tv_usec)/1000000.0);
    CFRunLoopTimerContext timerContext = {0, ts, NULL, NULL, NULL};
    CFRunLoopTimerRef timerRef = CFRunLoopTimerCreate (kCFAllocatorDefault,fireDate,0,0,0,theCFRunLoopTimerCallBack,&timerContext);

    // hack: store CFRunLoopTimerRef in next pointer of linked_item
    ts->item.next = (void *)timerRef;
        
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), timerRef, kCFRunLoopCommonModes);
}

int  cocoa_remove_timer(timer_source_t * ts){

    // printf("cocoa_remove_timer ref %x\n", (int) ts->item.next);

    CFRunLoopRemoveTimer(CFRunLoopGetCurrent(), (CFRunLoopTimerRef) ts->item.next, kCFRunLoopCommonModes);
	return 0;
}

void cocoa_init(){
}

void cocoa_execute()
{
    CFRunLoopRun();
}

void cocoa_dump_timer(){
    fprintf(stderr, "WARNING: run_loop_dump_timer not implemented yet!");
	return;
}

const run_loop_t run_loop_cocoa = {
    &cocoa_init,
    &cocoa_add_data_source,
    &cocoa_remove_data_source,
    &cocoa_add_timer,
    &cocoa_remove_timer,
    &cocoa_execute,
    &cocoa_dump_timer
};

