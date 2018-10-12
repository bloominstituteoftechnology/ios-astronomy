//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Ilgar Ilyasov on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class FetchPhotoOperation: ConcurrentOperation {
    
    // Properties
    var marsPhoto: MarsPhotoReference!
    var image: UIImage!
    var imageData: Data?
    
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhoto = marsPhotoReference
    }
    
    override func start() {
        super.start()
        state = .isExecuting
        
        URLSession.shared.dataTask(with: marsPhoto.imageURL) { (data, _, error) in
            if error != nil {
                NSLog("Error performing data task")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned")
                return
            }
            
            self.imageData = data
            defer { self.state = .isFinished }
            self.cancel()
        }
    }
    
    override func cancel() {
        super.cancel()
    }
    
}
