
import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    override func prepareForReuse() {
        imageView.image = #imageLiteral(resourceName: "MarsPlaceholder")
        
        super.prepareForReuse()
    }
    
    // MARK: Properties
    
    // MARK: IBOutlets
    
    @IBOutlet var imageView: UIImageView!
}
