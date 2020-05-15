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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCollectionViewCell ?? ImageCollectionViewCell()
        
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
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let currentFetchOperation = photoReferences[indexPath.row]
        guard let thisOperaion = operation[currentFetchOperation.id] else { return }
        thisOperaion.cancel()
    }
    // MARK: - Private
    
    private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // 1. Get the MarsPhotoReference instance for the passed in indexPath from the photoReferences array property.
        let photoReference = photoReferences[indexPath.item]
        
        // 2. Get the URL for the associated image using the imageURL property. Use .usingHTTPS (provided in URL+Secure.swift) to make sure the URL is an https URL. By default, the API returns http URLs.
//        guard let imageURL = photoReference.imageURL.usingHTTPS else {
//            NSLog("Error getting image URL")
//            return
//        }
        
        
        // Check to see if the cache already exists
        if let cacheData = cache.value(for: photoReference.id),
            let image = UIImage(data: cacheData) {
                cell.imageView.image = image
                return
            }
        
        let photoFetchOperation = FetchPhotoOperation(photoReference: photoReference)
        let store = BlockOperation {
            guard let data = photoFetchOperation.imageData else { return }
            self.cache.cache(value: data, for: photoReference.id)
        }

        let isReused = BlockOperation {
            let currentIndex = self.collectionView.indexPath(for: cell)
            guard currentIndex == indexPath, let data = photoFetchOperation.imageData else { return }
            cell.imageView.image = UIImage(data: data)
        }
        
        store.addDependency(photoFetchOperation)
        isReused.addDependency(photoFetchOperation)
        
        
        photoFetchQueue.addOperation(photoFetchOperation)
        photoFetchQueue.addOperation(store)
        OperationQueue.main.addOperation(isReused)
        operation[photoReference.id] = photoFetchOperation
        
        
//        // 3. Create and run a data task to load the image data from the imageURL.
//        let dataTask = URLSession.shared.dataTask(with: imageURL) { (data, _, error) in
//            // 4. In the data task's completion handler, check for an error, and return early if there is one. Otherwise, create a UIImage from the received data.
//            if let error = error {
//                NSLog("Error getting image \(error)")
//                return
//            }
//
//            // 6. If the cell hasn't been reused, set its imageView's image to the UIImage you just created.
//
//            guard let data = data else {
//                NSLog("No data received")
//                return
//
//            }
//
//            // Save the data in the cache
//            self.cache.cache(value: data, for: photoReference.id)
//
//            DispatchQueue.main.async {
//                // 5. Important: Check to see if the current index path for cell is the same one you were asked to load. If not, this means that that item has scrolled off screen and the UICollectionViewCell instance has been reused for a different index path. If this happens, abort setting the image.
//                guard self.collectionView.indexPath(for: cell) == indexPath else { return }
//
//                cell.imageView.image = UIImage(data: data)
//            }
//
//        }
//        dataTask.resume()
    }
    
    // Properties
    
    private let client = MarsRoverClient()
    
    private let cache = Cache<Int, Data>()
    
    private let photoFetchQueue = OperationQueue()
    
    var operation = [Int: Operation]()
     
    private var roverInfo: MarsRover? {
        didSet {
            solDescription = roverInfo?.solDescriptions[150]
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
