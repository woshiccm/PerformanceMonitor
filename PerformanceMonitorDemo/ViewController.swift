//
//  ViewController.swift
//  PerformanceMonitorDemo
//
//  Created by ming on 2019/8/24.
//  Copyright © 2019 roy. All rights reserved.
//

import UIKit
import PerformanceMonitor

var fpsMonitor = FPSMonitor()
var catonMonitor = CatonMonitor()

class ViewController: UIViewController {
    
    var timer: DispatchSourceTimer?  // GIF播放定时器
    let infoLabel: UILabel = {      // 展示cpu、内存信息
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 100, height: 30))
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.init(name: "Menlo", size: 12.0)
        label.backgroundColor = UIColor.black
        return label
    }()
    
    let window: UIWindow = {
        let window = UIWindow.init(frame: CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.size.width, height: 30))
        window.rootViewController = UIViewController()
        window.backgroundColor = UIColor.black
        window.makeKeyAndVisible()
        window.windowLevel = UIWindow.Level.alert
        return window
    }()
    
    
    let fpsView = UILabel.init(frame: CGRect.init(x: UIScreen.main.bounds.size.width - 100, y: 0, width: 100, height: 30))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fpsMonitor.delegate = self
        
        catonMonitor.start()
        
        fpsMonitor.stop()
        
        guard let windoww = UIApplication.shared.delegate?.window as? UIWindow else {
            return
        }
        
        window.center.x = windoww.center.x
        // CPU、内存
        window.rootViewController?.view.addSubview(infoLabel)
        // FPS
        
        window.rootViewController?.view.addSubview(fpsView)
        
        fpsView.textColor = .white
        fpsView.font = UIFont.init(name: "Menlo", size: 12.0)
        
        showUsageInfo()
    }
    
    func showUsageInfo() {
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timer?.schedule(deadline: .now(), repeating: 1)
        timer?.setEventHandler(handler: { [weak self] in
            DispatchQueue.main.async {
                let cpu = String.init(format: "%.2f", CPUMonitor.usage())
                let memory = String.init(format: "%.2f", MemoryMonitor.usage())
                self?.infoLabel.text = "CPU: \(cpu)%  Memory: \(memory) MB"
            }
        })
        timer?.resume()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let fpsVC = LSLFPSTableViewController.init(style: .plain)
        self.navigationController?.pushViewController(fpsVC, animated: true)
    }
}

extension ViewController: FPSMonitorDelegate {
    
    func fPS(with monitor: FPSMonitor, fps: Double) {
        let fps = String.init(format: "%.2f", fps)
        fpsView.text = "FPS: \(fps)"
    }
}
