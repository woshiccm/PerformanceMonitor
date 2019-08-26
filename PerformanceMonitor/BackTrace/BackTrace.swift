//
//  BackTrace.swift
//  PerformanceMonitor
//
//  Created by roy.cao on 2019/8/25.
//  Copyright © 2019 roy. All rights reserved.
//

import Foundation

extension Character {
    var isAscii: Bool {
        return unicodeScalars.allSatisfy { $0.isASCII }
    }
    var ascii: UInt32? {
        return isAscii ? unicodeScalars.first?.value : nil
    }
}

extension String {
    var ascii : [Int8] {
        var unicodeValues = [Int8]()
        for code in unicodeScalars {
            unicodeValues.append(Int8(code.value))
        }
        return unicodeValues
    }
}

public class BackTrace {

    public static let main_thread_t = mach_thread_self()
    
    public static func callStack(_ thread: Thread) -> String {
        let pthread = machThread(from: thread)
        return BackTraceObjc.backtrace(ofMachthread: pthread)
    }

    public static func machThread(from thread: Thread) -> thread_t {
        var name: [Int8] = [Int8]()
        var count = mach_msg_type_number_t(0)
        var threads: thread_act_array_t!

        guard task_threads(mach_task_self_, &(threads), &count) == KERN_SUCCESS else {
            return mach_thread_self()
        }

        if thread.isMainThread {
            return self.main_thread_t
        }

        let originName = thread.name

        for i in 0..<count {
            let index = Int(i)
            if let p_thread = pthread_from_mach_thread_np((threads[index])) {
                name.append(Int8(Character.init("\0").ascii!))
                pthread_getname_np(p_thread, &name, MemoryLayout<Int8>.size * 256)
                if (strcmp(&name, (thread.name!.ascii)) == 0) {
                    thread.name = originName
                    return threads[index]
                }
            }
        }

        thread.name = originName
        return mach_thread_self()
    }
}
