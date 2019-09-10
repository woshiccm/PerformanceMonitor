//
//  MethodTimeMonitor.h
//  PerformanceMonitor
//
//  Created by roy.cao on 2019/9/10.
//  Copyright © 2019 roy. All rights reserved.
//

#ifndef MethodTimeMonitor_h
#define MethodTimeMonitor_h


#endif /* MethodTimeMonitor_h */

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
