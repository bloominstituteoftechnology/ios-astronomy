//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Hector Steven on 6/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation


class FetchPhotoOperation: ConcurrentOperation {
	
	override func start() {
		state = .isExecuting
		guard let url = marsPhotoReference.imageURL.usingHTTPS else { return }
		
		task = URLSession.shared.dataTask(with: url) { data, response, error in
			if let response = response as? HTTPURLResponse {
				NSLog("loadImage Response Code: ", response.statusCode)
			}
			
			if let error = error {
				NSLog("Error grabbing image data: \(error)")
				return
			}
			
			guard let data = data else { return }
			self.imageData = data
		}
		defer { self.state = .isFinished }
		task?.resume()
	}
	
	override func cancel() {
		task?.cancel()
	}
	
	init(marsPhotoReference: MarsPhotoReference ) {
		self.marsPhotoReference = marsPhotoReference
	}
	
	let marsPhotoReference: MarsPhotoReference
	var imageData: Data?
	private var task: URLSessionDataTask?
}
