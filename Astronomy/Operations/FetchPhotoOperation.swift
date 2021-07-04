//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Jeffrey Santana on 9/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
	var photoRef: MarsPhotoReference
	var imageData: Data?
	private var dataTask: URLSessionDataTask?
	
	init(photoRef: MarsPhotoReference) {
		self.photoRef = photoRef
	}
	
	override func start() {
		super.start()
		state = .isExecuting
		
		guard let requestUrl = photoRef.imageURL.usingHTTPS else { return }
		
		dataTask = URLSession.shared.dataTask(with: requestUrl) { (data, response, error) in
			defer {
				self.state = .isFinished
			}
			
			if self.isCancelled {
				return
			}
			
			if let error = error {
				print("Error fetching photos: \(error.localizedDescription)")
				return
			}
			
			guard let data = data else {
				print("No data found")
				return }
			
			self.imageData = data
		}
		dataTask?.resume()
	}
	
	override func cancel() {
		super.cancel()
		dataTask?.cancel()
	}
}
