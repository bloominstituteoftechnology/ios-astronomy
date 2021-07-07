//
//  ConcurrentOperation.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class ConcurrentOperation: Operation {
    
    // MARK: - Types
    
    enum State: String {
        case isReady, isExecuting, isFinished
    }
    
    // MARK: Properties
    
    private var _state = State.isReady
    
    private let stateQueue = DispatchQueue(label: "com.LambdaSchool.Astronomy.ConcurrentOperationStateQueue")
    var state: State {
        get {
            var result: State?
            let queue = self.stateQueue
            queue.sync {
                result = _state
            }
            return result!
        }
        
        set {
            let oldValue = state
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: oldValue.rawValue)
            
            stateQueue.sync { self._state = newValue }
            
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: newValue.rawValue)
        }
    }
    
    // MARK: NSOperation
    
    override dynamic var isReady: Bool {
        return super.isReady && state == .isReady
    }
    
    override dynamic var isExecuting: Bool {
        return state == .isExecuting
    }
    
    override dynamic var isFinished: Bool {
        return state == .isFinished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
}

class FetchPhotoOperation: ConcurrentOperation {
    let id: Int
    let sol: Int
    let camera: Camera
    let earthDate: Date
    let imageURL: URL
    var imageData: Data?
    let marsSession = URLSession()
    var marsDataTask = URLSessionDataTask()
    
    init(photoReference: MarsPhotoReference) {
        self.id        = photoReference.id
        self.sol       = photoReference.sol
        self.camera    = photoReference.camera
        self.earthDate = photoReference.earthDate
        self.imageURL  = photoReference.imageURL
    }
    
    override func start() {
        state = .isExecuting
        let task = marsSession.dataTask(with: imageURL) { data, _, error in
            if let error = error {
                NSLog("error in fetchPhotoOperation:\(error)")
                self.state = .isFinished
                return
            }
            
            guard let data = data else {
                NSLog("Bad data in FetchPhotoOperation:\(error)")
                self.state = .isFinished
                return
            }
            self.imageData = data
            self.state = .isFinished
        }
        task.resume()
        marsDataTask = task
    }

    override func cancel() {
        marsDataTask.cancel()
    }
}
