//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Marlon Raskin on 9/5/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {

	var marsPhotoReference: MarsPhotoReference
	var imageData: Data?
	private var dataTask: URLSessionDataTask?

	init(marsPhotoReference: MarsPhotoReference) {
		self.marsPhotoReference = marsPhotoReference
		super.init()
	}
	
	override func start() {
		state = .isExecuting
		fetchPhoto()
	}

	private func fetchPhoto() {
		guard let url = marsPhotoReference.imageURL.usingHTTPS else {
			fatalError("Error modifying URL")
		}

		dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in

			defer { self.state = .isFinished }

			if let error = error {
				print("Error fetching photo: \(error)")
				return
			}
			self.imageData = data
		})
		dataTask?.resume()
	}

	override func cancel() {
		dataTask?.cancel()
	}

}
