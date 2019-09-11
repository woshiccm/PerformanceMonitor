//
//  ThreadLocal.swift
//  PerformanceMonitor
//
//  Created by roy.cao on 2019/9/8.
//  Copyright © 2019 roy. All rights reserved.
//

/// A type that allows for storing a value that's unique to the current thread.
final class ThreadLocal<Value> {

    private final class Box<Value> {
        var value: Value

        init(_ value: Value) {
            self.value = value
        }
    }

    fileprivate var key: pthread_key_t

    private let _value: Value

    init(_ value: Value) {
        _value = value
        key = pthread_key_t()
        pthread_key_create(&key, {
            guard let rawPointer = ($0 as UnsafeMutableRawPointer?) else {
                return
            }
            Unmanaged<AnyObject>.fromOpaque(rawPointer).release()
        })
    }

    var value: Value {
        get {
            guard let pointer = pthread_getspecific(key) else {
                return _value
            }
            return Unmanaged<Box<Value>>.fromOpaque(pointer).takeUnretainedValue().value
        }
        set {
            if let pointer = pthread_getspecific(key) {
                Unmanaged<AnyObject>.fromOpaque(pointer).release()
            }
            pthread_setspecific(key, Unmanaged.passRetained(Box<Value>(newValue)).toOpaque())
        }
    }

    deinit { pthread_key_delete(key) }
}

extension ThreadLocal: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(key.hashValue)
    }

    static func == <T>(lhs: ThreadLocal<T>, rhs: ThreadLocal<T>) -> Bool {
        return lhs.key == rhs.key
    }
}
