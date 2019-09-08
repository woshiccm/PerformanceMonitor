//
//  PerformanceMonitor.h
//  PerformanceMonitor
//
//  Created by roy.cao on 2019/8/24.
//  Copyright © 2019 roy. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for PerformanceMonitor.
FOUNDATION_EXPORT double PerformanceMonitorVersionNumber;

//! Project version string for PerformanceMonitor.
FOUNDATION_EXPORT const unsigned char PerformanceMonitorVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <PerformanceMonitor/PublicHeader.h>

#import <dlfcn.h>

#ifdef __cplusplus
extern "C" {
#endif
    IMP _Nonnull imp_implementationForwardingToTracer(void * _Nonnull patch, IMP _Nonnull onEntry, IMP _Nonnull onExit);
    void findPureSwiftClasses(const char * _Nullable path, void (^ _Nonnull callback)(void * _Nonnull symbol));
    int fast_dladdr(const void * _Nonnull, Dl_info * _Nonnull);
#ifdef __cplusplus
}
#endif
