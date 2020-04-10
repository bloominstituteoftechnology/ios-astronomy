//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Bradley Diroff on 4/9/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class FetchPhotoOperation: ConcurrentOperation {
    
    var reference: MarsPhotoReference
    var imageData: Data?
    var id: Int
    
    private(set) var session = URLSession()
    
    init(reference: MarsPhotoReference) {
        self.reference = reference
        self.id = reference.id
        
        super.init()
        
        runDataTask()
        
    }
    
    func runDataTask() {
        session.dataTask(with: reference.imageURL.usingHTTPS!) { (data, _, error) in
             if let error = error {
                 print("Error downloading picture: \(error)")
                 return
             } else {
                if let data = data {
                    self.imageData = data
                    self.state = .isFinished
            }
            }
        }
    }
    
    override func start() {
        state = .isExecuting
    }
    
    override func cancel() {
        session.invalidateAndCancel()
    }
    
}
