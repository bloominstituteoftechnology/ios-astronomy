//
//  PhotoFetchOperation.swift
//  Astronomy
//
//  Created by Cameron Collins on 5/7/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    //MARK: - Properties
    var photoReference: MarsPhotoReference?
    private var task: URLSessionDataTask?
    var imageData: Data?
    var cache: Cache<Int, Data>?
    
    //MARK: - Overrides
    override func start() {
        state = .isExecuting
        
        let tempImageURL = photoReference?.imageURL.usingHTTPS
        guard let imageURL = tempImageURL else {
            return
        }
        var requestURL = URLRequest(url: imageURL)
        requestURL.httpMethod = "GET"
        
        task = URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
            
            //Error Checking
            if let error = error {
                print("Error requesting in FetchPhotoOperation: \(error)")
                return
            }
            
            guard let tempData = data else {
                print("Bad data in FetchPhotoOperation")
                return
            }
            
            guard let photoId = self.photoReference?.id else {
                print("Bad ID in \(#file)")
                return
            }
            
            self.imageData = tempData
            self.cache?.cache(value: tempData, for: photoId)
            self.state = .isFinished
        }
        
        task?.resume()
    }
    
    override func cancel() {
        task?.cancel()
    }
}
