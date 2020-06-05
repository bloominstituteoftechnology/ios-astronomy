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




class FetchPhotoOperation: ConcurrentOperation {
    
    // MARK: - Properties
    var reference: MarsPhotoReference
    var data: Data?
    private var task: URLSessionDataTask?
    
    // MARK: - INIT
    init(reference: MarsPhotoReference) {
        self.reference = reference
        super.init()
    }
    
    // MARK: - Methods/Overrides
    
    override func start() {
        state = .isExecuting
        task?.resume()
    }
    
    override func cancel() {
        state = .isFinished
        fetchPhoto()
        task?.cancel()
    }
        
    func fetchPhoto() {
            guard let url = reference.imageURL.usingHTTPS else { return }
            task = URLSession.shared.dataTask(with: url) { (data, _, error) in
                defer {
                    self.state = .isFinished
                }
                if let error = error {
                    print(error)
                    return
                }
                guard let data = data else {
                    print("No data")
                    return
                }
                self.data = data
            }
        }
    }
