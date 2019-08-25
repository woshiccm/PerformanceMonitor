//
//  MemoryMonitor.swift
//  PerformanceMonitor
//
//  Created by roy.cao on 2019/8/24.
//  Copyright © 2019 roy. All rights reserved.
//

import Foundation

/// Memory state
public typealias MemoryState = (freeBytes: Double, activeBytes: Double, inactiveBytes: Double, wiredBytes: Double, compressedBytes: Double, totalBytes: Double)

public class MemoryMonitor {
    
    enum Constants {
        static let MB: Double = 1024 * 1024
    }
    
    public static let totalBytes: Double = Double(ProcessInfo.processInfo.physicalMemory)
    
    /// Current memory usage for your Applicaiton, equal Xcode Debug Gauge
    /// resident_size does not get accurate memory, and the correct way is to use phys_footprint, which can be proved from the source codes of WebKit and XNU.
    /// https://github.com/WebKit/webkit/blob/master/Source/WTF/wtf/cocoa/MemoryFootprintCocoa.cpp
    public static func usage() -> Double {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size / MemoryLayout<integer_t>.size)
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        var used: Double = 0
        if result == KERN_SUCCESS {
            used = Double(taskInfo.phys_footprint)
        }
        
        return used / Constants.MB
    }
    
    /// Current memory usage for your device, not equal Xcode Debug Gauge
    public static func deviceUsage() -> Double {
        var taskInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<integer_t>.size)
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        var used: Double = 0
        if kerr == KERN_SUCCESS {
            used = Double(taskInfo.resident_size)
        }
        
        return used / Constants.MB
    }
    
    /// Obtain current memory state for your device.
    public static func state() -> MemoryState {
        var count: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let pageSize = Double(vm_kernel_page_size)
        
        let statisticsPointer = vm_statistics64_t.allocate(capacity: Int(count))
        defer { statisticsPointer.deallocate() }
        
        let kerr = statisticsPointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            host_statistics64(mach_host_self(), host_flavor_t(HOST_VM_INFO64), $0, &count)
        }
        
        #if DEBUG
        if kerr != KERN_SUCCESS {
            let errorString = String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"
            print("Collecting memroy detail failed: \(errorString)")
        }
        #endif
        
        let statistics: vm_statistics64 = statisticsPointer.move()
        let free = Double(statistics.free_count) * pageSize
        let active = Double(statistics.active_count) * pageSize
        let inactive = Double(statistics.inactive_count) * pageSize
        let wired = Double(statistics.wire_count) * pageSize
        let compressed = Double(statistics.compressor_page_count) * pageSize
        
        return (free, active, inactive, wired, compressed, totalBytes)
    }
}
