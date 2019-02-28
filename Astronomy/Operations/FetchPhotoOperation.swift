//
//  FetchPhotoOperation.swift
//  Astronomy
//
//  Created by Lambda_School_Loaner_34 on 2/28/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    //Add properties to store an instance of MarsPhotoReference for which an image should be loaded as well as imageData that has been loaded
    var marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    
    //Implement an initializer that takes a MarsPhotoReference
    init(marsPhotoReference: MarsPhotoReference) {
        self.marsPhotoReference = marsPhotoReference
    }
}
