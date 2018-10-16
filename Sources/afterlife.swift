import Foundation
#if !PMKCocoaPods
import PromiseKit
#endif

/**
 - Returns: A promise that resolves when the provided object deallocates
 - Important: The promise is not guarenteed to resolve immediately when the provided object is deallocated. So you cannot write code that depends on exact timing.
 - Note: cancelling this guarantee will cancel the underlying task
 - SeeAlso: [Cancellation](http://promisekit.org/docs/)
 */
public func after(life object: NSObject) -> Guarantee<Void> {
    var reaper = objc_getAssociatedObject(object, &handle) as? GrimReaper
    if reaper == nil {
        reaper = GrimReaper()
        objc_setAssociatedObject(object, &handle, reaper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        reaper!.promise.setCancellableTask(CancellableReaperTask(object: object))
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

private class CancellableReaperTask: CancellableTask {
    weak var object: NSObject?
    
    var isCancelled = false

    init(object: NSObject) {
        self.object = object
    }
    
    func cancel() {
        if !isCancelled {
            if let obj = object {
                objc_setAssociatedObject(obj, &handle, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            isCancelled = true
        }
    }
}
