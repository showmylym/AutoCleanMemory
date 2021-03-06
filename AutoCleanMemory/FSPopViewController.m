//
//  FSPopViewController.m
//  AutoCleanMemory
//
//  Created by Jerry on 13-6-5.
//  Copyright (c) 2013年 RayManning. All rights reserved.
//

#import "FSPopViewController.h"
#import <mach/mach.h>
#import <mach/mach_host.h>

#define kLastVersion        @"LastVersion"

const int warningFreedMemValue =       200;

@interface FSPopViewController (){
    unsigned long _currentMemoryRemained;
}

@end

@implementation FSPopViewController


- (id)init {
    self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    // Initialization code here.

    _needUseRedColorToShowFreedMemory = NO;
    _currentMemoryRemained = 0;
    
    //process old version preference
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * lastVersion = [userDefaults valueForKey:kLastVersion];
    NSString * thisVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    if (lastVersion == nil || (lastVersion != nil && ![lastVersion isEqualToString:thisVersion])) {
        //do migration between different versions
        
    } else {
        
    }
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(refreshMemoryUsageTimerHandler:) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryUsageNeedRefresh:) name:MemoryUsageNeedRefreshNotification object:nil];

}


#pragma mark - get memory usage info
- (NSString *)memStringFromValue:(unsigned long)originalValue {
    NSString * string = nil;
    double converteredValue = 0.0;
    if (originalValue >= 1000000000L) {
        converteredValue = originalValue / 1024.0 / 1024.0 / 1024.0;
        string = [NSString stringWithFormat:@"%.2lf GB", converteredValue];
    } else {
        converteredValue = originalValue / 1024.0 /1024.0;
        string = [NSString stringWithFormat:@"%.0lf MB", converteredValue];
    }
    return string;
}

- (NSDictionary *) currentMemoryInfo {
    mach_port_t host_port = mach_host_self();
    vm_statistics64_data_t vm_stat64;
    mach_msg_type_number_t host_info64_outCnt = sizeof(vm_statistics64_data_t) / sizeof(natural_t);
    
    vm_size_t pagesize;
    host_page_size(host_port, &pagesize);

    
    if (host_statistics64(host_port, HOST_VM_INFO64, (host_info64_t)&vm_stat64, &host_info64_outCnt) != KERN_SUCCESS)
        NSLog(@"Failed to fetch vm statistics");
    

    /* Stats in bytes */
    unsigned long mem_free        = vm_stat64.free_count * (unsigned long)pagesize;
    unsigned long mem_active      = vm_stat64.active_count * (unsigned long)pagesize;
    unsigned long mem_inactive    = vm_stat64.inactive_count * (unsigned long)pagesize;
    unsigned long mem_wired       = vm_stat64.wire_count * (unsigned long)pagesize;
    unsigned long mem_compression = vm_stat64.compressor_page_count * (unsigned long)pagesize;
    unsigned long mem_used        = (vm_stat64.active_count +
                                     vm_stat64.inactive_count +
                                     vm_stat64.wire_count +
                                     vm_stat64.compressor_page_count) * (unsigned long)pagesize;
    unsigned long mem_total       = mem_used + mem_free ;

    
    //set flag to judge whether need purge and change status bar item string color
    [self setFlagByFreedMemory:mem_free andInactiveMemory:mem_inactive];
//    NSLog(@"used: %ld free: %ld total: %ld pageSize: %ld", mem_used, mem_free, mem_total, pagesize);
    _currentMemoryRemained = mem_free;
    
    NSString * memoryUsedString        = [self memStringFromValue:mem_used];
    NSString * memoryFreeString        = [self memStringFromValue:mem_free];
    NSString * memoryTotalString       = [self memStringFromValue:mem_total];
    NSString * memoryActiveString      = [self memStringFromValue:mem_active];
    NSString * memoryInactiveString    = [self memStringFromValue:mem_inactive];
    NSString * memoryWiredString       = [self memStringFromValue:mem_wired];
    NSString * memoryCompressionString = [self memStringFromValue:mem_compression];

    NSDictionary * dict = @{kmem_used:memoryUsedString, kmem_free:memoryFreeString,
                            kmem_total:memoryTotalString, kmem_active:memoryActiveString,
                            kmem_inactive:memoryInactiveString, kmem_wired:memoryWiredString,
                            kmem_compression:memoryCompressionString};
    return dict;
}

#pragma mark - IBAction

- (void)exitButtonPressed:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

#pragma mark - timer call back
- (void) refreshMemoryUsageTimerHandler:(NSTimer *) timer {
    NSDictionary * userInfo = [self currentMemoryInfo];
    if (userInfo != nil) {
        //fire autoclean

        [[NSNotificationCenter defaultCenter] postNotificationName:MemoryUsageNeedRefreshNotification object:self userInfo:userInfo];
    }
}

#pragma mark - Notification call back
- (void) memoryUsageNeedRefresh:(NSNotification *) note {
    NSDictionary * userInfo = note.userInfo;
    if (userInfo != nil) {
        [self refreshControlsValue:userInfo];
    }
    
}

#pragma mark - private methods

- (void) setFlagByFreedMemory:(unsigned long)mem_free andInactiveMemory:(unsigned long)mem_inactive {
    if (mem_free < warningFreedMemValue * 1024L * 1024L) {
        _needUseRedColorToShowFreedMemory = YES;
    } else {
        _needUseRedColorToShowFreedMemory = NO;
    }
    
}


- (void) refreshControlsValue:(NSDictionary *)userInfo {
    if (userInfo != nil) {
        NSString * memoryUsedString        = [userInfo valueForKey:kmem_used];
        NSString * memoryFreeString        = [userInfo valueForKey:kmem_free];
        NSString * memoryActiveString      = [userInfo valueForKey:kmem_active];
        NSString * memoryInactiveString    = [userInfo valueForKey:kmem_inactive];
        NSString * memoryWiredString       = [userInfo valueForKey:kmem_wired];
        NSString * memoryCompressionString = [userInfo valueForKey:kmem_compression];
        NSString * memoryTotalString       = [userInfo valueForKey:kmem_total];

        //update Controls
        [self.totalUsageTextField.cell setTitle:memoryUsedString];
        [self.freeTextField.cell setTitle:memoryFreeString];
        [self.totalMemoryTextField.cell setTitle:memoryTotalString];
        [self.activeTextField.cell setTitle:memoryActiveString];
        [self.inactiveUsageTextField.cell setTitle:memoryInactiveString];
        [self.wiredUsageTextField.cell setTitle:memoryWiredString];
        [self.compressedMemoryTextField.cell setTitle:memoryCompressionString];
    }
}


@end

NSString * const MemoryUsageNeedRefreshNotification = @"MemoryUsageNeedRefreshNotification";
