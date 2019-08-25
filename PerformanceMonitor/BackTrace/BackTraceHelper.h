//
//  BackTraceHelper.h
//  PerformanceMonitor
//
//  Created by ming on 2019/8/25.
//  Copyright © 2019 roy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BackTraceHelper : NSObject

+ (NSString *)lsl_backtraceOfAllThread;
+ (NSString *)lsl_backtraceOfMainThread;
+ (NSString *)lsl_backtraceOfCurrentThread;
+ (NSString *)lsl_backtraceOfNSThread:(NSThread *)thread;

+ (void)lsl_logMain;
+ (void)lsl_logCurrent;
+ (void)lsl_logAllThread;

+ (NSString *)backtraceLogFilePath;
+ (void)recordLoggerWithFileName: (NSString *)fileName;

@end

NS_ASSUME_NONNULL_END
