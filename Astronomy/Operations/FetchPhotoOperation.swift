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
	}
	
	let fetchImageOperatopm = BlockOperation {
//		let url = marsPhotoReference.imageURL.usingHTTPS
//		URLSession.shared.dataTask(with: "") { data, response, error in
//			if let response = response as? HTTPURLResponse {
//				NSLog("loadImage Response Code: ", response.statusCode)
//			}
//			
//			if let error = error {
//				NSLog("Error grabbing image data: \(error)")
//				return
//			}
//			
//			guard let data = data else { return }
////			self.imageData = data
//		}.resume()
		
	}
	
	
	
	
	init(marsPhotoReference: MarsPhotoReference, imageData: Data? = nil ) {
		self.marsPhotoReference = marsPhotoReference
		self.imageData = imageData
	}
	
	let marsPhotoReference: MarsPhotoReference
	let imageData: Data?
}
