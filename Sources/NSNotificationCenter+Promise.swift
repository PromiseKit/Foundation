import Foundation
#if !PMKCocoaPods
import PMKCancel
import PromiseKit
#endif

/**
 To import the `NSNotificationCenter` category:

    use_frameworks!
    pod "PromiseKit/Foundation"

 Or `NSNotificationCenter` is one of the categories imported by the umbrella pod:

    use_frameworks!
    pod "PromiseKit"

 And then in your sources:

    import PromiseKit
*/
extension NotificationCenter {
    /// Observe the named notification once
    public func observe(once name: Notification.Name, object: Any? = nil) -> Guarantee<Notification> {
        let (promise, fulfill) = Guarantee<Notification>.pending()
      #if !os(Linux)
        let id = addObserver(forName: name, object: object, queue: nil, using: fulfill)
      #else
        let id = addObserver(forName: name, object: object, queue: nil, usingBlock: fulfill)
      #endif
        promise.done { _ in self.removeObserver(id) }
        return promise
    }
}

//////////////////////////////////////////////////////////// Cancellation

extension NotificationCenter {
    /// Observe the named notification once
    public func observeCC(once name: Notification.Name, object: Any? = nil) -> CancellablePromise<Notification> {
        let (promise, resolver) = CancellablePromise<Notification>.pending()
#if !os(Linux)
        let id = addObserver(forName: name, object: object, queue: nil, using: resolver.fulfill)
#else
        let id = addObserver(forName: name, object: object, queue: nil, usingBlock: resolver.fulfill)
#endif
        
        promise.appendCancellableTask(task: ObserverTask { self.removeObserver(id) }, reject: resolver.reject)
 
        _ = promise.ensure { self.removeObserver(id) }
        return promise
    }
}

class ObserverTask: CancellableTask {
    let cancelBlock: () -> Void
    
    init(cancelBlock: @escaping () -> Void) {
        self.cancelBlock = cancelBlock
    }
    
    func cancel() {
        cancelBlock()
        isCancelled = true
    }
    
    var isCancelled = false
}
