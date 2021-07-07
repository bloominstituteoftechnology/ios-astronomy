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
        super.start()
        self.state = .isExecuting
        
        guard let imageURL = model.imageURL.usingHTTPS else { return }
        
        let dataTask = URLSession.shared.dataTask(with: imageURL) { data, _, error in
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
        super.cancel()
        self.dataTask?.cancel()
        print("Cancel the operation")
    }
}
