//
//  MarsImageFetchOperation.swift
//  Astronomy
//
//  Created by William Bundy on 9/6/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import UIKit

class MarsImageFetchOperation: ConcurrentOperation
{
	var photoRef:MarsPhotoReference
	var image:UIImage?

	var task:URLSessionDataTask?

	init(_ photo:MarsPhotoReference) {
		photoRef = photo
		super.init()
	}
	override func start() {
		state = .isExecuting
		task = URLSession.shared.dataTask(with: photoRef.imageURL.usingHTTPS!) { data, _, error in
			if let error = error {
				NSLog("There was an error: \(error)");
			}

			guard let data = data else {
				NSLog("There was an error: no data");
				return
			}

			if let img = UIImage(data:data) {
				self.image = img
				self.state = .isFinished
				self.completionBlock?()
			}
		}
		task?.resume()
	}

	override func cancel() {
		task?.cancel()
	}
}
