//
//  ImageCollectionViewCell.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    
    // MARK: IBOutlets
    
    @IBOutlet var imageView: UIImageView!
    
    override func prepareForReuse() {
        imageView.image = #imageLiteral(resourceName: "MarsPlaceholder")
        
        super.prepareForReuse()
    }
    

}
