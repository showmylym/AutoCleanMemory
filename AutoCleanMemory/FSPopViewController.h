//
//  FSPopViewController.h
//  AutoCleanMemory
//
//  Created by Jerry on 13-6-5.
//  Copyright (c) 2013年 RayManning. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const MemoryUsageNeedRefreshNotification;

#define kmem_used        @"mem_used"
#define kmem_free        @"mem_free"
#define kmem_total       @"mem_total"
#define kmem_active      @"mem_active"
#define kmem_inactive    @"mem_inactive"
#define kmem_wired       @"mem_wired"
#define kmem_compression @"mem_compression"

@interface FSPopViewController : NSViewController

@property (assign) BOOL needUseRedColorToShowFreedMemory;

@property (weak) IBOutlet NSTextField *inactiveUsageTextField;
@property (weak) IBOutlet NSTextField *wiredUsageTextField;
@property (weak) IBOutlet NSTextField *freeTextField;
@property (weak) IBOutlet NSTextField *activeTextField;
@property (weak) IBOutlet NSTextField *compressedMemoryTextField;
@property (weak) IBOutlet NSTextField *totalUsageTextField;
@property (weak) IBOutlet NSTextField *totalMemoryTextField;


- (IBAction)exitButtonPressed:(id)sender;
@end
