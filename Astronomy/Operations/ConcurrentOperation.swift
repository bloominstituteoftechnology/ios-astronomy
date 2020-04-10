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

// MARK: - Subclass

class FetchPhotoOperation: ConcurrentOperation {
    var marsReference: MarsPhotoReference
    var imageData: Data?
    private var sesh = URLSession(configuration: .default)
    private var task = URLSessionDataTask()
    
    init(marsReference: MarsPhotoReference) {
        self.marsReference = marsReference
    }
    
    
    
    override func start() {
//        print("Starting fetch for marsReference id: \(marsReference.id)")
        self.state = .isExecuting
        task = sesh.dataTask(with: marsReference.imageURL.usingHTTPS!) {d,r,e in
            defer { self.state = .isFinished}
            if let error = e {
                NSLog("Error  RECEIVING    DATA    FROM    MARS: \(error)")
                return
            }
            
            if let response = r as? HTTPURLResponse {
//                NSLog(" RE CE  IV  E D A RE S PO N SE   WITH   STATUS    CODE: \(response.statusCode)  FOR   ID   \(self.marsReference.id)")
            }
            
            if let data = d {
                self.imageData = data
                return
            }
        }
        task.resume()
    }
    
    override func cancel() {
        task.cancel()
//        print("Ending fetch for marsReference id: \(marsReference.id)")
    }
    
}
