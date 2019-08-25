//
//  PerformanceMonitor.swift
//  PerformanceMonitor
//
//  Created by roy.cao on 2019/8/24.
//  Copyright © 2019 roy. All rights reserved.
//

import UIKit

public struct PerformanceReport {
    let cpu: Double
    let memory: Double
    let fps: Double
}

public protocol PerformanceMonitorelegate: class {
    
    func performanceMonitor(report: PerformanceReport)
}

public class PerformanceMonitor {
    
    public static let shared = PerformanceMonitor()
    
    weak var delegate: PerformanceMonitorelegate?
    
    public struct DisplayOptions: OptionSet {
        public let rawValue: Int
        
        /// CPU usage.
        public static let cpu = DisplayOptions(rawValue: 1 << 0)
        
        /// Memory usage.
        public static let memory = DisplayOptions(rawValue: 1 << 1)
        
        /// FPS.
        public static let fps = DisplayOptions(rawValue: 1 << 2)
        
        public static let all: DisplayOptions = [.cpu, .memory, .fps]
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    private var monitoringTimer: DispatchSourceTimer?
    
    public init(displayOptions: DisplayOptions = .all) {
        
    }
    
    public func start() {
        monitoringTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        monitoringTimer?.schedule(deadline: .now(), repeating: 1)
        monitoringTimer?.setEventHandler(handler: { [weak self] in
            DispatchQueue.main.async {
                let cpu = String.init(format: "%.2f", CPUMonitor.usage())
                let memory = String.init(format: "%.2f", MemoryMonitor.usage())
                let text = "CPU: \(cpu)%  Memory: \(memory) MB  FPS: \(1)"
            }
        })
        monitoringTimer?.resume()
    }
    
    public func stop() {
        monitoringTimer?.cancel()
    }
    
    public func pause() {
        monitoringTimer?.suspend()
    }
    
    public func resume() {
        monitoringTimer?.resume()
    }
    
    deinit {
        monitoringTimer?.cancel()
    }
}
