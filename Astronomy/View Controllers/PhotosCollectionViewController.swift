//
//  PhotosCollectionViewController.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    let cache = Cache<Int, Data>()
    
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
        
       //cell.imageView.image =
        
        
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
        
        // TODO: Implement image loading here
        
        if let value = cache.value(forKey: photoReference.id) {

            let imageData = value
            cell.imageView.image = UIImage(data: imageData)
        } else {

            let url = photoReference.imageURL.usingHTTPS
        guard let guardedURL = url else { fatalError("bad URL \(String(describing: url))")}
//            // 3 Operations
//            let photoFetchOperation = FetchPhotoOperation(photoReferences: photoReference)
//            let storeReceivedDataInCache = BlockOperation {
//                guard let imageData = photoFetchOperation.imageData else { fatalError("No image data")}
//                self.cache.cache(value: imageData, forKey: photoReference.id)
//            }
//            let reuseOperation = BlockOperation {
//
//                    if indexPath == self.collectionView.indexPath(for: cell) {
//                        guard let imageData = photoFetchOperation.imageData else { fatalError("No image data")}
//                        let image = UIImage(data: imageData)
//                        cell.imageView.image = image
//
//            }
//            }
//            storeReceivedDataInCache.addDependency(photoFetchOperation)
//            reuseOperation.addDependency(photoFetchOperation)
//
//            photoFetchQueue.addOperations([photoFetchOperation], waitUntilFinished: false)
//            activeOperations[photoReference.id] = photoFetchOperation
//        }
    

        URLSession.shared.dataTask(with: guardedURL) { (data, _, error) in

            if let error = error {
                NSLog("\(error)")
                return
            }

            guard let photoData = data else { return }

            self.cache.cache(value: photoData, forKey: photoReference.id)

           let image = UIImage(data: photoData)
            DispatchQueue.main.async {
                if indexPath == self.collectionView.indexPath(for: cell) {
                cell.imageView.image = image
            }
            }
        }.resume()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // cancel()
    }

    // Properties
    
    private let client = MarsRoverClient()
    private var photoFetchQueue = OperationQueue()
    private var allOperations: [Int : FetchPhotoOperation] = [:]
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
