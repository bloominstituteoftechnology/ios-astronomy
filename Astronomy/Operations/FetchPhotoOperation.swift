//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Vici Shaweddy on 11/8/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class FetchPhotoOperation: ConcurrentOperation {
    private let model: MarsPhotoReference
    private var dataTask: URLSessionDataTask?
    var image: UIImage?
    
    init(model: MarsPhotoReference) {
        self.model = model
        super.init()
    }
    
    override func start() {
        self.state = .isExecuting
        
        let dataTask = URLSession.shared.dataTask(with: model.imageURL) { data, _, error in
            // this will happen at the end, no matter what
            defer { self.state = .isFinished }
            
            guard error == nil else { return }
            
            if let data = data {
                self.image = UIImage(data: data)
            }
        }
        self.dataTask = dataTask
        self.dataTask?.resume()
    }
    
    override func cancel() {
        self.dataTask?.cancel()
    }
}
