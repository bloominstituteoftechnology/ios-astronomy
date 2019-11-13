//
//  PhotoDetailViewController.swift
//  Astronomy
//
//  Created by Bobby Keffury on 11/13/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import Photos

class PhotoDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    
    @IBAction func saveTapped(_ sender: Any) {
        guard let image = imageView.image else { return }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }, completionHandler: { (success, error) in
            if let error = error {
                NSLog("Error saving photo: \(error)")
                return
            }
        })
    }
    
    // MARK: - Private
    
    private func updateViews() {
        guard let photo1 = photo,
            isViewLoaded else {
                return }
        do {
            let data = try Data(contentsOf: photo1.imageURL)
            imageView.image = UIImage(data: data)
            let dateString = dateFormatter.string(from: photo1.earthDate)
            detailLabel.text = "Taken by \(photo1.camera.roverId) on \(dateString) (Sol \(photo1.sol))"
            cameraLabel.text = photo1.camera.fullName
        } catch {
            NSLog("Error setting up views on detail view controller: \(error)")
        }
    }
    
    // MARK: - Properties
    
    var photo: MarsPhotoReference? {
        didSet {
            updateViews()
        }
    }
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .short
        return df
    }()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var cameraLabel: UILabel!
    
}
