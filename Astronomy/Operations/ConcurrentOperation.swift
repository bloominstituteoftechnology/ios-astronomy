//
//  ConcurrentOperation.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class ConcurrentOperation: Operation {
    
    // MARK: Types
    
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
    
    class FetchPhotoOperation: ConcurrentOperation {
        var marsPhotoReference: MarsPhotoReference
        var imageData: URL?
        private var session: URLSessionDataTask
        
        init(marsPhotoReference: MarsPhotoReference) {
            self.marsPhotoReference = marsPhotoReference
        }
        
        override func start() {
            state = .isExecuting
            
            guard let url = imageData else { return }
            
            session = URLSession.shared.dataTask(with: url) { (data, _, error) in
                if let error = error {
                    NSLog("Error: \(error)")
                    return
                }
                
                guard let data = data else {
                    NSLog("Error")
                    return
                }
                
                let receivedImageData = UIImage(data: data)
                

            }
            state = .isFinished
        }
        
        override func cancel() {
            session.cancel()
        }
            
        
        
        
    }
    
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
