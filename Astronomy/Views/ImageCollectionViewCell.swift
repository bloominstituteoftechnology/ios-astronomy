//
//  ImageCollectionViewCell.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    var photoId: Int = 0
    var indexPath = IndexPath()
    
    override func prepareForReuse() {
        imageView.image = #imageLiteral(resourceName: "MarsPlaceholder")
        photoId = 0
        super.prepareForReuse()
    }
    
    // MARK: Properties
    
    // MARK: IBOutlets
    
    @IBOutlet var imageView: UIImageView!
}
