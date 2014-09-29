//
//  FSAppDelegate.h
//  AutoCleanMemory
//
//  Created by Jerry on 13-6-5.
//  Copyright (c) 2013年 RayManning. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FSPopViewController.h"

@interface FSAppDelegate : NSObject <NSApplicationDelegate, NSPopoverDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, strong) NSStatusItem * statusBarItem;

@property (nonatomic, strong) FSPopViewController * popViewController;

@property (nonatomic, strong) NSPopover * popover;

@end
