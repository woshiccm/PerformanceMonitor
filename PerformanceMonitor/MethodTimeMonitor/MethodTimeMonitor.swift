//
//  MethodTimeMonitor.swift
//  PerformanceMonitor
//
//  Created by roy.cao on 2019/9/8.
//  Copyright © 2019 roy. All rights reserved.
//

import Foundation

// https://github.com/apple/swift/blob/master/docs/ABI/TypeMetadata.rst#class-metadata
struct SwiftClassMetada {
    let metaClass: Int
    let superClass: Any.Type
    let reserved1: Int
    let reserved2: Int
    let rodataPointer: Int
    let flags: UInt32
    let instanceAddressPoint: UInt32
    let instanceSize: UInt32
    let instanceAlignmentMask: UInt16
    let reserved: UInt16

    let classSize: UInt32
    let classAddressPoint: UInt32
    let descriptor: Int
    var ivarDestroyer: UnsafeMutableRawPointer?
    // the follow is vtable
}

// Reference: https://github.com/johnno1962/SwiftTrace

#if arch(arm64)

/// Stack layout on entry from xt_forwarding_trampoline_arm64.s
struct EntryStack {
    static let maxFloatArgs = 8
    static let maxIntArgs = 8

    public var floatArg1: Double = 0.0
    public var floatArg2: Double = 0.0
    public var floatArg3: Double = 0.0
    public var floatArg4: Double = 0.0
    public var floatArg5: Double = 0.0
    public var floatArg6: Double = 0.0
    public var floatArg7: Double = 0.0
    public var floatArg8: Double = 0.0
    public var intArg1: intptr_t = 0
    public var intArg2: intptr_t = 0
    public var intArg3: intptr_t = 0
    public var intArg4: intptr_t = 0
    public var intArg5: intptr_t = 0
    public var intArg6: intptr_t = 0
    public var intArg7: intptr_t = 0
    public var intArg8: intptr_t = 0
    public var structReturn: intptr_t = 0 // x8
    public var framePointer: intptr_t = 0
    public var swiftSelf: intptr_t = 0 // x20
    public var thrownError: intptr_t = 0 // x21
}

///  Stack layout on exit from xt_forwarding_trampoline_arm64.s
struct ExitStack {
    static let returnRegs = 4

    public var floatReturn1: Double = 0.0
    public var floatReturn2: Double = 0.0
    public var floatReturn3: Double = 0.0
    public var floatReturn4: Double = 0.0
    public var d4: Double = 0.0
    public var d5: Double = 0.0
    public var d6: Double = 0.0
    public var d7: Double = 0.0
    public var intReturn1: intptr_t = 0
    public var intReturn2: intptr_t = 0
    public var intReturn3: intptr_t = 0
    public var intReturn4: intptr_t = 0
    public var x4: intptr_t = 0
    public var x5: intptr_t = 0
    public var x6: intptr_t = 0
    public var x7: intptr_t = 0
    public var structReturn: intptr_t = 0 // x8
    public var framePointer: intptr_t = 0
    public var swiftSelf: intptr_t = 0 // x20
    public var thrownError: intptr_t = 0 // x21

    mutating func resyncStructReturn() {
        structReturn = autoBitCast(invocation.structReturn)
    }
}
#else // x86_64
 /// Stack layout on entry from xt_forwarding_trampoline_x64.s
struct EntryStack {
    static let maxFloatArgs = 8
    static let maxIntArgs = 6

    public var floatArg1: Double = 0.0
    public var floatArg2: Double = 0.0
    public var floatArg3: Double = 0.0
    public var floatArg4: Double = 0.0
    public var floatArg5: Double = 0.0
    public var floatArg6: Double = 0.0
    public var floatArg7: Double = 0.0
    public var floatArg8: Double = 0.0
    public var framePointer: intptr_t = 0
    public var r10: intptr_t = 0
    public var r12: intptr_t = 0
    public var swiftSelf: intptr_t = 0  // r13
    public var r14: intptr_t = 0
    public var r15: intptr_t = 0
    public var intArg1: intptr_t = 0    // rdi
    public var intArg2: intptr_t = 0    // rsi
    public var intArg3: intptr_t = 0    // rcx
    public var intArg4: intptr_t = 0    // rdx
    public var intArg5: intptr_t = 0    // r8
    public var intArg6: intptr_t = 0    // r9
    public var structReturn: intptr_t = 0 // rax
    public var rbx: intptr_t = 0
}

 /// Stack layout on exit from xt_forwarding_trampoline_x64.s
struct ExitStack {
    static let returnRegs = 4

    public var stackShift1: intptr_t = 0
    public var stackShift2: intptr_t = 0
    public var floatReturn1: Double = 0.0 // xmm0
    public var floatReturn2: Double = 0.0 // xmm1
    public var floatReturn3: Double = 0.0 // xmm2
    public var floatReturn4: Double = 0.0 // xmm3
    public var xmm4: Double = 0.0
    public var xmm5: Double = 0.0
    public var xmm6: Double = 0.0
    public var xmm7: Double = 0.0
    public var framePointer: intptr_t = 0
    public var r10: intptr_t = 0
    public var thrownError: intptr_t = 0 // r12
    public var swiftSelf: intptr_t = 0  // r13
    public var r14: intptr_t = 0
    public var r15: intptr_t =  0
    public var rdi: intptr_t = 0
    public var rsi: intptr_t = 0
    public var intReturn1: intptr_t = 0 // rax (also struct Return)
    public var intReturn2: intptr_t = 0 // rdx
    public var intReturn3: intptr_t = 0 // rcx
    public var intReturn4: intptr_t = 0 // r8
    public var r9: intptr_t = 0
    public var rbx: intptr_t = 0
    public var structReturn: intptr_t {
        return intReturn1
    }
}
#endif

private func autoBitCast<IN, OUT>(_ arg: IN) -> OUT {
    return unsafeBitCast(arg, to: OUT.self)
}

/// pointer to a function implementing a Swift method */
typealias SIMP = UnsafeMutableRawPointer

extension NSObject {

    public class func traceBundle() {
        MethodTimeMonitor.traceBundle(containing: self)
    }

    public class func traceClass() {
        MethodTimeMonitor.trace(aClass: self)
    }
}

public struct MethodTimeMonitorRecord: CustomStringConvertible {

    public let timeCost: String
    public let methodName: String

    public var description: String {
        var cost = timeCost
        let timeCostPointer = UnsafeRawPointer(&cost)
        return String(format: "%-10s %@ ", UInt(bitPattern: timeCostPointer), methodName)
    }
}

public protocol MethodTimeMonitorDelegate: AnyObject {

    func methodTimeMonitor(_ record: MethodTimeMonitorRecord)
}

open class MethodTimeMonitor: NSObject {

    public static weak var delegate: MethodTimeMonitorDelegate?

    static var threadLocal = ThreadLocal<[Patch.Invocation]>([])

    /// Class used to create "Invocation" instances representing a specific call to a member function on the "ThreadLocal" stack.
    static var defaultInvocationFactory = Patch.Invocation.self

    /// Strace "info" instance used to store information about a patch on a method
    class Patch: NSObject {
        /// Dictionary of patch objects created by trampoline */
        static var active = [IMP: Patch]()

        /// follow chain of Patches through to find original patch
        class func originalPatch(for implementation: IMP) -> Patch? {
            var implementation = implementation
            var patch: Patch?
            while active[implementation] != nil {
                patch = active[implementation]
                implementation = patch!.implementation
            }
            return patch
        }

        /// string representing Swift or Objective-C method to user
        let name: String

        /// pointer to original function implementing method
        var implementation: IMP

        /// vtable slot patched for unpatching
        var vtableSlot: UnsafeMutablePointer<SIMP>?

        /// Original objc method swizzled
        let objcMethod: Method?

        /// Closure that can be called instead of original implementation
        let nullImplmentation: UnsafeMutableRawPointer?

        /// designated initialiser
        ///
        /// - Parameters:
        ///   - name: string representing method being traced
        ///   - vtableSlot: pointer to vtable slot patched
        ///   - objcMethod: pointer to original Method patched
        ///   - replaceWith: implementation to replace that of class
        required init?(name: String,
                       vtableSlot: UnsafeMutablePointer<SIMP>? = nil,
                       objcMethod: Method? = nil,
                       replaceWith: UnsafeMutableRawPointer? = nil) {
            self.name = name
            self.vtableSlot = vtableSlot
            self.objcMethod = objcMethod
            if let vtableSlot = vtableSlot {
                implementation = autoBitCast(vtableSlot.pointee)
            }
            else {
                implementation = method_getImplementation(objcMethod!)
            }
            nullImplmentation = replaceWith
        }

        /// Called from assembly code on entry to Patched method
        static var onEntry: @convention(c) (_ patch: Patch, _ returnAddress: UnsafeRawPointer, _ stackPointer: UnsafeMutablePointer<UInt64>) -> IMP? = {
                (patch, returnAddress, stackPointer) -> IMP? in
                let invocation = patch.invocationFactory.init(stackDepth: MethodTimeMonitor.threadLocal.value.count, patch: patch,
                                              returnAddress: returnAddress, stackPointer: stackPointer )

                MethodTimeMonitor.threadLocal.value.append(invocation)
                patch.onEntry(stack: &invocation.entryStack.pointee)
                return patch.nullImplmentation != nil ?
                    autoBitCast(patch.nullImplmentation) : patch.implementation
        }

        /// Called from assembly code when Patched method returns
        static var onExit: @convention(c) () -> UnsafeRawPointer = {
            let invocation = Invocation.current!
            invocation.patch.onExit(stack: &invocation.exitStack.pointee)
            MethodTimeMonitor.threadLocal.value.removeLast()
            return invocation.returnAddress
        }

        /// Return a unique pointer to a trampoline that will callback the oneEntry() and onExit() method in this class
        func forwardingImplementation() -> SIMP {
            // create trampoline
            let impl = imp_implementationForwardingToTracer(autoBitCast(self),
                                autoBitCast(Patch.onEntry), autoBitCast(Patch.onExit))
            Patch.active[impl] = self // track Patches by trampoline and retain them
            return autoBitCast(impl)
        }

        /// method called before trampoline enters the target "Patch"
        func onEntry(stack: inout EntryStack) {
        }

        /// method called after trampoline exits the target "Patch"
        func onExit(stack: inout ExitStack) {
            if let invocation = Invocation.current {
                let elapsed = Invocation.usecTime() - invocation.timeEntered
                let timeCost = String(format: "%.1fms", elapsed * 1000.0)
                let methodName = "\(String(repeating: "  ", count: invocation.stackDepth))\(name)"
                let record = MethodTimeMonitorRecord(timeCost: timeCost, methodName: methodName)
                MethodTimeMonitor.delegate?.methodTimeMonitor(record)
            }
        }

        /// Class used to create a specific "Invocation" of the "Patch" on entry
        var invocationFactory: Invocation.Type {
            return defaultInvocationFactory
        }

        /// The inner invocation instance on the stack of the current thread.
        func invocation() -> Invocation! {
            return Invocation.current
        }

        /// Remove this patch
        func remove() {
            if let vtableSlot = vtableSlot {
                vtableSlot.pointee = autoBitCast(implementation)
            }
            else if let objcMethod = objcMethod {
                method_setImplementation(objcMethod, implementation)
            }
        }

        /// Remove all patches recursively
        func removeAll() {
            (Patch.originalPatch(for: implementation) ?? self).remove()
        }

        /// find "self" for the current invocation
        func getSelf<T>(as: T.Type = T.self) -> T {
            return autoBitCast(invocation().swiftSelf)
        }

        /// pointer to memory for return of struct
        func structReturn<T>(as: T.Type = T.self) -> UnsafeMutablePointer<T> {
            return invocation().structReturn!.assumingMemoryBound(to: T.self)
        }

        /// convert arguments & return results to a specifi type
        func rebind<IN,OUT>(_ pointer: UnsafeMutablePointer<IN>, to: OUT.Type = OUT.self) -> UnsafeMutablePointer<OUT> {
            return pointer.withMemoryRebound(to: OUT.self, capacity: 1) { $0 }
        }

        /// Represents a specific call to a member function on the "ThreadLocal" stack
        class Invocation {
            /// Time call was started
            let timeEntered: Double

            /// Number of calls above this on the stack of the current thread
            let stackDepth: Int

            /// "Patch" related to this call
            let patch: Patch

            /// Original return address of call to trampoline
            let returnAddress: UnsafeRawPointer

            /// Architecture depenent place on stack where arguments stored
            let entryStack: UnsafeMutablePointer<EntryStack>

            var exitStack: UnsafeMutablePointer<ExitStack> {
                return patch.rebind(entryStack)
            }

            /// copy of struct return register in case function throws
            var structReturn: UnsafeMutableRawPointer? = nil
            
            /// "self" for method invocations
            let swiftSelf: intptr_t

            /// for use relaying data from entry to exit
            var userInfo: AnyObject?

            /// micro-second precision time.
            static public func usecTime() -> Double {
                var tv = timeval()
                gettimeofday(&tv, nil)
                return Double(tv.tv_sec) + Double(tv.tv_usec)/1_000_000.0
            }

            /// designated initialiser
            ///
            /// - Parameters:
            ///   - stackDepth: number of calls that have been made on the stack
            ///   - patch: associated Patch instance
            ///   - returnAddress: adress in process trampoline was called from
            ///   - stackPointer: stack pointer of thread with saved registers
            required init(stackDepth: Int,
                          patch: Patch,
                          returnAddress: UnsafeRawPointer,
                          stackPointer: UnsafeMutablePointer<UInt64>) {
                timeEntered = Invocation.usecTime()
                self.stackDepth = stackDepth
                self.patch = patch
                self.returnAddress = returnAddress
                self.entryStack = patch.rebind(stackPointer)
                self.swiftSelf = patch.objcMethod != nil ?
                    self.entryStack.pointee.intArg1 : self.entryStack.pointee.swiftSelf
                self.structReturn = UnsafeMutableRawPointer(bitPattern: self.entryStack.pointee.structReturn)
            }

            /// The inner invocation instance on the current thread.
            static var current: Invocation! {
                return MethodTimeMonitor.threadLocal.value.last
            }
        }
    }


    /// default pattern of symbols to be excluded from tracing
    static public let defaultMethodExclusions = "\\.getter|retain]|release]|_tryRetain]|.cxx_destruct]|initWithCoder|_isDeallocating]|^\\+\\[(Reader_Base64|UI(NibStringIDTable|NibDecoder|CollectionViewData|WebTouchEventsGestureRecognizer)) |^.\\[UIView |UIButton _defaultBackgroundImageForType:andState:|RxSwift.ScheduledDisposable.dispose"

    static var inclusionRegexp: NSRegularExpression?
    static var exclusionRegexp: NSRegularExpression? = NSRegularExpression(pattern: defaultMethodExclusions)

    /// Include symbols matching pattern only
    ///
    /// - Parameter pattern: regexp for symbols to include
    public class func include(_ pattern: String) {
        inclusionRegexp = NSRegularExpression(pattern: pattern)
    }

    /// Exclude symbols matching this pattern. If not specified a default pattern in swiftTraceDefaultExclusions is used.
    ///
    /// - Parameter pattern: regexp for symbols to exclude
    public class func exclude(_ pattern: String) {
        exclusionRegexp = NSRegularExpression(pattern: pattern)
    }

    class func included(symbol: String) -> Bool {
        return (inclusionRegexp?.matches(symbol) != false) && (exclusionRegexp?.matches(symbol) != true)
    }

    /// Intercepts and tracess all classes linked into the bundle containing a class.
    ///
    /// - Parameter theClass: the class to specify the bundle
    @objc open class func traceBundle(containing theClass: AnyClass) {
        trace(bundlePath: class_getImageName(theClass))
    }

    /// Trace all user developed classes in the main bundle of an app
    @objc open class func traceMainBundle() {
        let main = dlsym(UnsafeMutableRawPointer(bitPattern: -2), "main")
        var info = Dl_info()
        if main != nil && dladdr(main, &info) != 0 && info.dli_fname != nil {
            trace(bundlePath: info.dli_fname)
        } else {
            fatalError("Could not locate main bundle")
        }
    }

    /// Trace a classes defined in a specific bundlePath (executable image)
    @objc public class func trace(bundlePath: UnsafePointer<Int8>?) {
        var registered = Set<UnsafeRawPointer>()
        forAllClasses { aClass, _ in
            if class_getImageName(aClass) == bundlePath {
                trace(aClass: aClass)
                registered.insert(autoBitCast(aClass))
            }
        }
        // This should pick up and Pure Swift classes
        findPureSwiftClasses(bundlePath, { aClass in
            if !registered.contains(aClass) {
                trace(aClass: autoBitCast(aClass))
            }
        })
    }

    /// Lists Swift classes in an app or framework.
    ///
    /// - Parameter bundlePath: bundlePath
    /// - Returns: all the Swift classes
    open class func swiftClassList(bundlePath: UnsafePointer<Int8>) -> [AnyClass] {
        var classes = [AnyClass]()
        findPureSwiftClasses(bundlePath, { aClass in
            classes.append(autoBitCast(aClass))
        })
        return classes
    }

    /// Intercepts and tracess all classes with names matching regexp pattern
    ///
    /// - Parameter pattern: regexp patten to specify classes to trace
    @objc public class func traceClassesMatching(pattern: String) {
        if let regexp = NSRegularExpression(pattern: pattern) {
            forAllClasses { aClass, _ in
                let className = NSStringFromClass(aClass) as NSString
                if regexp.firstMatch(in: String(describing: className) as String, range: NSMakeRange(0, className.length)) != nil {
                    trace(aClass: aClass)
                }
            }
        }
    }

    /// Specify an individual classs to trace
    ///
    /// - Parameter aClass: the class, the methods of which to trace
    @objc public class func trace(aClass: AnyClass) {
        let className = NSStringFromClass(aClass)
        if className.hasPrefix("Swift.") || className.hasPrefix("__") {
            return
        }

        var tClass: AnyClass? = aClass
        while tClass != nil {
            if NSStringFromClass(tClass!).contains("SwiftTrace") {
                return
            }
            tClass = class_getSuperclass(tClass)
        }

        interceptObjcMethods(of: object_getClass(aClass)!, which: "+")
        interceptObjcMethods(of: aClass, which: "-")

        iterateVtableMethods(of: aClass) { name, vtableSlot, _ in
            if included(symbol: name),
                let patch = Patch(name: name, vtableSlot: vtableSlot) {
                vtableSlot.pointee = patch.forwardingImplementation()
            }
        }
    }

    @objc public class func removeAllPatches() {
        for (_, patch) in Patch.active {
            patch.removeAll()
        }
    }
}

extension MethodTimeMonitor {

    /// Iterate over all methods in the vtable that follows the class information of a Swift class (TargetClassMetadata)
    @discardableResult
    class func iterateVtableMethods(of aClass: AnyClass,
                                    callback: @escaping (_ name: String, _ vtableSlot: UnsafeMutablePointer<SIMP>, _ stop: inout Bool) -> Void) -> Bool {
        let swiftMeta: UnsafeMutablePointer<SwiftClassMetada> = autoBitCast(aClass)
        let className = NSStringFromClass(aClass)
        var stop = false

        guard (className.hasPrefix("_Tt") || className.contains(".")) && !className.hasPrefix("Swift.") else {
            return false
        }

        withUnsafeMutablePointer(to: &swiftMeta.pointee.ivarDestroyer) { vtableStart in
            swiftMeta.withMemoryRebound(to: Int8.self, capacity: 1) {
                let endMeta = ($0 - Int(swiftMeta.pointee.classAddressPoint) + Int(swiftMeta.pointee.classSize))
                endMeta.withMemoryRebound(to: Optional<SIMP>.self, capacity: 1) { vtableEnd in

                    var info = Dl_info()
                    for i in 0..<(vtableEnd - vtableStart) {
                        if var impl: IMP = autoBitCast(vtableStart[i]) {
                            if let patch = Patch.originalPatch(for: impl) {
                                impl = patch.implementation
                            }
                            let voidPtr: UnsafeMutableRawPointer = autoBitCast(impl)
                            if fast_dladdr(voidPtr, &info) != 0 && info.dli_sname != nil,
                                let demangled = demangle(symbol: info.dli_sname) {
                                callback(demangled, &vtableStart[i]!, &stop)
                                if stop {
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }

        return stop
    }

    /// Intercept Objective-C class' methods using swizzling
    ///
    /// - Parameters:
    ///   - aClass: meta-class or class to be swizzled
    ///   - which: "+" for class methods, "-" for instance methods
    class func interceptObjcMethods(of aClass: AnyClass, which: String) {
        var mc: UInt32 = 0
        guard let methods = class_copyMethodList(aClass, &mc) else {
            return
        }
        for method in (0..<Int(mc)).map({ methods[$0] }) {
            let sel = method_getName(method)
            let selName = NSStringFromSelector(sel)
            let type = method_getTypeEncoding(method)
            let name = "\(which)[\(aClass) \(selName)] -> \(String(cString: type!))"

            if !included(symbol: name) || (which == "+" ? selName.hasPrefix("shared") : dontSwizzleProperty(aClass: aClass, sel:sel)) {
                continue
            }

            if let info = Patch(name: name, objcMethod: method) {
                method_setImplementation(method, autoBitCast(info.forwardingImplementation()))
            }
        }
        free(methods)
    }
}

extension MethodTimeMonitor {

    /// Iterate over all known classes in the app
    @discardableResult
    class func forAllClasses( callback: (_ aClass: AnyClass, _ stop: inout Bool) -> Void ) -> Bool {
        var stopped = false
        var nc: UInt32 = 0
        guard let classes = objc_copyClassList(&nc) else {
            return stopped
        }

        for aClass in (0..<Int(nc)).map({ classes[$0] }) {
            callback(aClass, &stopped)
            if stopped {
                break
            }
        }
        free(UnsafeMutableRawPointer(classes))
        return stopped
    }

    /// Legacy code intended to prevent property accessors from being traced
    ///
    /// - Parameters:
    ///   - aClass: class of method
    ///   - sel: selector of method being checked
    /// - Returns: Bool
    class func dontSwizzleProperty(aClass: AnyClass, sel: Selector) -> Bool {
        var name = [Int8](repeating: 0, count: 5000)
        strcpy(&name, sel_getName(sel))
        if strncmp(name, "is", 2) == 0 && isupper(Int32(name[2])) != 0 {
            name[2] = Int8(towlower(Int32(name[2])))
            return class_getProperty(aClass, &name[2]) != nil
        } else if strncmp(name, "set", 3) != 0 || islower(Int32(name[3])) != 0 {
            return class_getProperty(aClass, name) != nil
        } else {
            name[3] = Int8(tolower(Int32(name[3])))
            name[Int(strlen(name))-1] = 0
            return class_getProperty(aClass, &name[3]) != nil
        }
    }

    class func demangle(symbol: UnsafePointer<Int8>) -> String? {
        if let demangledNamePtr = _stdlib_demangleImpl(
            symbol, mangledNameLength: UInt(strlen(symbol)),
            outputBuffer: nil, outputBufferSize: nil, flags: 0) {
            let demangledName = String(cString: demangledNamePtr)
            free(demangledNamePtr)
            return demangledName
        }
        return nil
    }
}

@_silgen_name("swift_demangle")
private
func _stdlib_demangleImpl(
    _ mangledName: UnsafePointer<CChar>?,
    mangledNameLength: UInt,
    outputBuffer: UnsafeMutablePointer<UInt8>?,
    outputBufferSize: UnsafeMutablePointer<UInt>?,
    flags: UInt32
    ) -> UnsafeMutablePointer<CChar>?

extension EntryStack {
    var invocation: MethodTimeMonitor.Patch.Invocation! {
        return MethodTimeMonitor.Patch.Invocation.current
    }
}

extension ExitStack {
    var invocation: MethodTimeMonitor.Patch.Invocation! {
        return MethodTimeMonitor.Patch.Invocation.current
    }
}

/// Convenience extension to trap regex errors and report them
private extension NSRegularExpression {

    convenience init?(pattern: String) {
        do {
            try self.init(pattern: pattern, options: [])
        } catch let error as NSError {
            fatalError(error.localizedDescription)
        }
    }

    func matches(_ string: String) -> Bool {
        return rangeOfFirstMatch(in: string, options: [], range: NSMakeRange(0, string.utf16.count)).location != NSNotFound
    }
}
