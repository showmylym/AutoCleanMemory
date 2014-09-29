//
//  FSAppDelegate.m
//  AutoCleanMemory
//
//  Created by Jerry on 13-6-5.
//  Copyright (c) 2013年 RayManning. All rights reserved.
//

#import "FSAppDelegate.h"
@implementation FSAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application

    self.statusBarItem = [[NSStatusBar systemStatusBar] statusItemWithLength:80.0f];
    [self.statusBarItem setTarget:self];
    [self.statusBarItem setAction:@selector(popUpPopover:)];
    [self.statusBarItem setHighlightMode:YES];
    
    if (self.popover == nil) {
        self.popover = [NSPopover new];
        self.popover.delegate = self;
        self.popover.appearance = NSPopoverAppearanceMinimal;
        self.popover.behavior = NSPopoverBehaviorTransient;
        self.popViewController = [FSPopViewController new];
        self.popover.contentViewController = self.popViewController;
        self.popover.contentSize = self.popViewController.view.frame.size;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryUsageNeedRefresh:) name:MemoryUsageNeedRefreshNotification object:nil];

}


- (void) popUpPopover:(id)sender {
    [self.popover showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMaxYEdge];
}




#pragma mark - update memory info of status item
//notification call back
- (void) memoryUsageNeedRefresh:(NSNotification *)note {
    NSDictionary * userInfo = note.userInfo;
    if (userInfo != nil) {
        NSString * freedMemoryString = [userInfo valueForKey:kmem_free];
        [self showInfoToStatusBarItem:[freedMemoryString stringByAppendingString:@" Free"]];
    }
    
}
- (void) showInfoToStatusBarItem:(NSString *)freedMemoryString {
    
    NSFont * __strong font = [NSFont fontWithName:@"Lucida Grande" size:12.0f];
    NSMutableAttributedString * muAttributedString = [[NSMutableAttributedString alloc] initWithString:freedMemoryString];
    [muAttributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, freedMemoryString.length)];
    
    if (self.popViewController.needUseRedColorToShowFreedMemory) {
        [muAttributedString addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, freedMemoryString.length)];
    } else {
        [muAttributedString addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:NSMakeRange(0, freedMemoryString.length)];
    }

    [self.statusBarItem setAttributedTitle:muAttributedString];
}


@end
