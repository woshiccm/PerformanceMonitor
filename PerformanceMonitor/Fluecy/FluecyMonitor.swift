//
//  FluecyMonitor.swift
//  PerformanceMonitor
//
//  Created by roy.cao on 2019/8/25.
//  Copyright © 2019 roy. All rights reserved.
//

import Foundation
import RCBacktrace

public class FluecyMonitor {
    
    enum Constants {
        static let timeOutInterval: TimeInterval = 0.05
        static let queueTitle = "com.roy.PerformanceMonitor.CatonMonitor"
    }
    
    private var queue: DispatchQueue = DispatchQueue(label: Constants.queueTitle)
    private var isMonitoring = false
    private var semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    
    public init() {}
    
    public func start() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        queue.async {
            while self.isMonitoring {
                
                var timeout = true
                
                DispatchQueue.main.async {
                    timeout = false
                    self.semaphore.signal()
                }
                
                Thread.sleep(forTimeInterval: Constants.timeOutInterval)
                
                if timeout {
                    DispatchQueue.main.async {
                        let symbols = RCBacktrace.callstack(.main)
                        print("👁 Not fluecy ------------------------------------------------------------")
                        for symbol in symbols {
                            print(symbol.description)
                        }
                        print("👁 Not fluecy -------------------------------------------------------------")
                    }
                }
                self.semaphore.wait()
            }
        }
    }
    
    public func stop() {
        guard isMonitoring else { return }
        
        isMonitoring = false
    }
}
