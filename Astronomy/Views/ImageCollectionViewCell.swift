//
//  ImageCollectionViewCell.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    override func prepareForReuse() {
        imageView.image = #imageLiteral(resourceName: "MarsPlaceholder")
        photoReferenceID = nil
        super.prepareForReuse()
    }
    
    // MARK: Properties
    var photoReferenceID: Int?
    
    // MARK: IBOutlets
    
    @IBOutlet var imageView: UIImageView!
}
