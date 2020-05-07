//
//  ConcurrentOperation.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class ConcurrentOperation: Operation {
    
    
     private(set) var imageData: Data?
        let id: Int
        let sol: Int
        let camera: Camera
        let earthDate: Date
        let imageURL: URL

        init(marsPhotoReference: MarsPhotoReference) {
            self.id = marsPhotoReference.id
            self.camera = marsPhotoReference.camera
            self.sol = marsPhotoReference.sol
            self.earthDate = marsPhotoReference.earthDate
            self.imageURL = marsPhotoReference.imageURL
        }

       
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
