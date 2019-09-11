//
//  CPUMonitor.swift
//  PerformanceMonitor
//
//  Created by roy.cao on 2019/8/24.
//  Copyright © 2019 roy. All rights reserved.
//

import Foundation

private let HOST_CPU_LOAD_INFO_COUNT: natural_t = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)

public class CPUMonitor {
    
    public struct HostCPULoadInfo {
        public let user: Double
        public let system: Double
        public let idle: Double
        public let nice: Double
        
        /// 1、CPU_STATE_USER
        /// 2、CPU_STATE_SYSTEM
        /// 3、CPU_STATE_IDLE
        /// 4、CPU_STATE_NICE
        init(cpuLoadInfo: host_cpu_load_info) {
            user = Double(cpuLoadInfo.cpu_ticks.0)
            system = Double(cpuLoadInfo.cpu_ticks.1)
            idle = Double(cpuLoadInfo.cpu_ticks.2)
            nice = Double(cpuLoadInfo.cpu_ticks.3)
        }
    }
    
    // Current CPU usage for your Applicaiton
    public static func usage() -> Double {
        var usageOfCPU: Double = 0.0
        var threads = UnsafeMutablePointer(mutating: [thread_act_t]())
        var count = mach_msg_type_number_t(0)
        
        defer {
            vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threads)), vm_size_t(Int(count) * MemoryLayout<thread_t>.stride))
        }
        
        let kerr = withUnsafeMutablePointer(to: &threads) {
            $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
                task_threads(mach_task_self_, $0, &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else { return usageOfCPU }
        
        for index in 0..<count {
            var threadInfo = thread_basic_info()
            var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
            
            let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    thread_info(threads[Int(index)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
                }
            }
            
            guard infoResult == KERN_SUCCESS else {
                break
            }
            
            let threadBasicInfo = threadInfo as thread_basic_info
            if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
                usageOfCPU = (usageOfCPU + (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0))
            }
        }
        
        return usageOfCPU
    }
    
    public static func hostCPULoadInfo() -> HostCPULoadInfo? {
        var size = HOST_CPU_LOAD_INFO_COUNT
        var cpuLoadInfo = host_cpu_load_info()
        
        let kerr = withUnsafeMutablePointer(to: &cpuLoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(HOST_CPU_LOAD_INFO_COUNT)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }
        
        if kerr != KERN_SUCCESS {
            #if DEBUG
            let errorString = String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"
            print("Collecting host cpu load info failed: \(errorString)")
            #endif
            return nil
        }
        
        return HostCPULoadInfo(cpuLoadInfo: cpuLoadInfo)
    }
    
    // Current CPU total usage, CPU_STATE_USER + CPU_STATE_SYSTEM + CPU_STATE_NICE
    public static func totalUsage() -> Double {
        guard let hostCPULoadInfo = hostCPULoadInfo() else {
            return 0
        }
        
        let totalTicks = hostCPULoadInfo.user + hostCPULoadInfo.system + hostCPULoadInfo.idle + hostCPULoadInfo.nice
        
        return (hostCPULoadInfo.user + hostCPULoadInfo.system + hostCPULoadInfo.nice) / totalTicks * 100
    }
}
