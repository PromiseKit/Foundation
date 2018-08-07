import Foundation
#if !PMKCocoaPods
import PMKCancel
import PromiseKit
#endif

/**
 - Returns: A promise that resolves when the provided object deallocates
 - Important: The promise is not guarenteed to resolve immediately when the provided object is deallocated. So you cannot write code that depends on exact timing.
 */
public func after(life object: NSObject) -> Guarantee<Void> {
    var reaper = objc_getAssociatedObject(object, &handle) as? GrimReaper
    if reaper == nil {
        reaper = GrimReaper()
        objc_setAssociatedObject(object, &handle, reaper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    return reaper!.promise
}

private var handle: UInt8 = 0

private class GrimReaper: NSObject {
    deinit {
        fulfill(())
    }
    let (promise, fulfill) = Guarantee<Void>.pending()
}

//////////////////////////////////////////////////////////// Cancellation

/**
 - Returns: A cancellable promise that resolves when the provided object deallocates, and can be unregistered and rejected by calling 'cancel'
 - Important: The promise is not guarenteed to resolve immediately when the provided object is deallocated. So you cannot write code that depends on exact timing.
 */
public func afterCC(life object: NSObject) -> CancellablePromise<Void> {
    var reaper = objc_getAssociatedObject(object, &cancellableHandle) as? CancellableGrimReaper
    if reaper == nil {
        reaper = CancellableGrimReaper()
        objc_setAssociatedObject(object, &cancellableHandle, reaper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        reaper!.promise.appendCancellableTask(task: CancellableReaperTask(object: object), reject: reaper!.resolver.reject)
    }
    return reaper!.promise
}

private var cancellableHandle: UInt8 = 0

private class CancellableGrimReaper: NSObject {
    let (promise, resolver) = CancellablePromise<Void>.pending()
    
    deinit {
        resolver.fulfill(())
    }
}

private class CancellableReaperTask: CancellableTask {
    weak var object: NSObject?
    
    var isCancelled = false

    init(object: NSObject) {
        self.object = object
    }
    
    func cancel() {
        if !isCancelled {
            if let obj = object {
                objc_setAssociatedObject(obj, &cancellableHandle, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            isCancelled = true
        }
    }
}
