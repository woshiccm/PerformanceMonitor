//
//  BackTraceHelper.h
//  PerformanceMonitor
//
//  Created by roy.cao on 2019/8/25.
//  Copyright © 2019 roy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>

@interface BackTraceObjc : NSObject

+ (NSString *)backtraceOfMachthread:(thread_t)thread;

@end
