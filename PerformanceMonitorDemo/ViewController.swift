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

//        let imgPrefix = self.imagePrefix()
//        var imageCount:UInt32 = 0
//        let images = objc_copyImageNames(&imageCount)
//        for i in 0 ..< imageCount {
//            let imagePath = String(cString: images[Int(i)])
//        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        foo()
        let fpsVC = FPSTestViewController()
        self.navigationController?.pushViewController(fpsVC, animated: true)
    }

    func foo() {
        bar()
    }

    func bar() {

    }
}
