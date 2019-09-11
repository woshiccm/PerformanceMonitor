//
//  FPSHelper.swift
//  PerformanceMonitor
//
//  Created by roy.cao on 2019/8/24.
//  Copyright © 2019 roy. All rights reserved.
//

import Foundation

@objc public protocol FPSMonitorDelegate: class {
    
    func fpsMonitor(with monitor: FPSMonitor, fps: Double)
}

public class FPSMonitor: NSObject {
    
    class WeakProxy {
        weak var target: FPSMonitor?
        
        init(target: FPSMonitor) {
            self.target = target
        }
        
        @objc func tick(link: CADisplayLink) {
            target?.tick(link: link)
        }
    }
    
    enum Constants {
        static let timeInterval: TimeInterval = 1.0
    }
    
    public weak var delegate: FPSMonitorDelegate?
    
    private var link: CADisplayLink?
    private var count: Int = 0
    private var lastTime: TimeInterval = 0.0
    
    public override init() {
        super.init()
        
        link = CADisplayLink(target: WeakProxy.init(target: self), selector: #selector(WeakProxy.tick(link:)))
        link?.isPaused = true
        link?.add(to: RunLoop.main, forMode: .common)
        setupObservers()
    }
    
    public func start() {
        link?.isPaused = false
    }
    
    public func stop() {
        link?.isPaused = true
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationWillResignActiveNotification),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActiveNotification),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    deinit {
        link?.invalidate()
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func tick(link: CADisplayLink) {
        count += 1
        let timePassed = link.timestamp - self.lastTime
        
        guard timePassed >= Constants.timeInterval else {
            return
        }
        
        self.lastTime = link.timestamp
        let fps = Double(self.count) / timePassed
        self.count = 0
        
        self.delegate?.fpsMonitor(with: self, fps: fps)
    }
}

private extension FPSMonitor {
    
    @objc func applicationWillResignActiveNotification() {
        stop()
    }
    
    @objc func applicationDidBecomeActiveNotification() {
        start()
    }
}
