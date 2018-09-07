//
//  PhotosCollectionViewController.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client.fetchMarsRover(named: "curiosity") { (rover, error) in
            if let error = error {
                NSLog("Error fetching info for curiosity: \(error)")
                return
            }
            
            self.roverInfo = rover
        }
    }
    
    // UICollectionViewDataSource/Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoReferences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        
        loadImage(forCell: cell, forItemAt: indexPath)
        
        return cell
    }
    
    // Make collection view cells fill as much available width as possible
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        var totalUsableWidth = collectionView.frame.width
        let inset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        totalUsableWidth -= inset.left + inset.right
        
        let minWidth: CGFloat = 150.0
        let numberOfItemsInOneRow = Int(totalUsableWidth / minWidth)
        totalUsableWidth -= CGFloat(numberOfItemsInOneRow - 1) * flowLayout.minimumInteritemSpacing
        let width = totalUsableWidth / CGFloat(numberOfItemsInOneRow)
        return CGSize(width: width, height: width)
    }
    
    // Add margins to the left and right side
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 10.0)
    }
    
    // MARK: - Private
    
    private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photoReference = photoReferences[indexPath.item]
        guard let url = photoReference.imageURL.usingHTTPS else { return }
        
        // Check if the cache already has the image with the id, tthe key is the image's id from MarsPhotoReference
        if let image = cache.value(for: photoReference.id) { // Subscript: cache[photoReference.id]
            cell.imageView.image = image
        } else {
            URLSession.shared.dataTask(with: url) { (data, _, error) in
                if let error = error {
                    NSLog("Error retrieving url data: \(error)")
                    return  // Bail out if there is an error
                    // No completion handler to deal with here
                }
                
                guard let data = data else { return }   // No completion handler to deal with here
                guard let image = UIImage(data: data) else { return }   // data might not actually be an image
                
                // If calling cache is out here, then we would run into a thread-safe problem.
                // Put this code inside DispatchQueue.main.async will fix the problem for this case. However, when we have a more complexed app, we should use GCD or NSOperation to make it more thread-safe that way we can call it anywhere we want and not have to worry about it.
                self.cache.cache(value: image, for: photoReference.id)
                
                DispatchQueue.main.async {  // modifying a property here
                    // If the currentIndexPath is nil, then we ignore the fact that the index paths don't match and set the image anyways. If it isn't nil, then we make sure the index paths match, otherwise we don't set the image
                    if let currentIndexPath = self.collectionView.indexPath(for: cell), currentIndexPath != indexPath {
                        return
                    }
                    
                    cell.imageView.image = image
                    
                    // save the image to the cache
//                    self.cache.cache(value: image, for: photoReference.id)
                    
                    // Get the cell at the indexPath we loaded the image for
//                    guard let cell = self.collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else { return }
//                    cell.imageView.image = image
                }
            }.resume()
        }
    }
    
    // Properties
    
    private let client = MarsRoverClient()
    
    private var cache: Cache<Int, UIImage> = Cache()
    
    private var photoFetchQueue: OperationQueue?
    
    private var roverInfo: MarsRover? {
        didSet {
            solDescription = roverInfo?.solDescriptions[3]
        }
    }
    private var solDescription: SolDescription? {
        didSet {
            if let rover = roverInfo,
                let sol = solDescription?.sol {
                client.fetchPhotos(from: rover, onSol: sol) { (photoRefs, error) in
                    if let e = error { NSLog("Error fetching photos for \(rover.name) on sol \(sol): \(e)"); return }
                    self.photoReferences = photoRefs ?? []
                }
            }
        }
    }
    private var photoReferences = [MarsPhotoReference]() {
        didSet {
            DispatchQueue.main.async { self.collectionView?.reloadData() }
        }
    }
    
    @IBOutlet var collectionView: UICollectionView!
}
