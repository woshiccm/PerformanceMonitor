//
//  CatonMonitor.swift
//  PerformanceMonitor
//
//  Created by roy.cao on 2019/8/25.
//  Copyright © 2019 roy. All rights reserved.
//
// https://cloud.tencent.com/developer/article/1427933

import Foundation

public class CatonMonitor {
    
    enum Constants {
        static let timeOutInterval: TimeInterval = 0.05
        static let queueTitle = "com.roy.PerformanceMonitor.CatonMonitor"
    }
    
    private var queue: DispatchQueue = DispatchQueue(label: Constants.queueTitle)
    private var isMonitoring = false
    private var semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
    
    public init() {}
    
    public func start() {
        let main = BackTrace.main_thread_t
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

                    print(BackTrace.callStack(.main))
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
