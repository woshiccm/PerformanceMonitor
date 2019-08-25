//
//  BackTraceHelper.h
//  PerformanceMonitor
//
//  Created by ming on 2019/8/25.
//  Copyright © 2019 roy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <limits.h>
#import <string.h>
#import <pthread.h>
#import <sys/types.h>
#import <mach/mach.h>
#import <mach-o/nlist.h>
#import <mach-o/dyld.h>

NS_ASSUME_NONNULL_BEGIN

@interface BackTraceHelper : NSObject

+ (NSString *)backtraceOfMachthread:(thread_t)thread;

+ (NSString *)backtraceLogFilePath;
+ (void)recordLoggerWithFileName: (NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
