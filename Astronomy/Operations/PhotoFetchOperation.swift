//
//  PhotoFetchOperation.swift
//  Astronomy
//
//  Created by Carolyn Lea on 9/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

class PhotoFetchOperation: ConcurrentOperation
{
    var marsPhotoReference: MarsPhotoReference?
    var imageData: Data?
    private var dataTask: URLSessionDataTask?
    
    init(reference: MarsPhotoReference, imageData: Data)
    {
        self.imageData = imageData
    }
    
    override func start()
    {
        state = .isExecuting
        
        let url = marsPhotoReference?.imageURL.usingHTTPS
        
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error
            {
                NSLog("error fetching images from server \(error)")
                
                return
            }
            
            guard let data = data else { return }
            
            DispatchQueue.main.async() {
                
                self.imageData = data
                
                self.state = .isFinished
            }
        }
        .resume()
    }
    
    override func cancel()
    {
        dataTask?.cancel()
    }
}
