//
//  ViewController.swift
//  PerformanceMonitorDemo
//
//  Created by roy.cao on 2019/8/24.
//  Copyright © 2019 roy. All rights reserved.
//

import UIKit
import PerformanceMonitor

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let fpsVC = FPSTestViewController()
        self.navigationController?.pushViewController(fpsVC, animated: true)
    }
}
