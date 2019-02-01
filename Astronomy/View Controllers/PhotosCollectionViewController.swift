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
    
    // Implements Cancellation of Operations
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photoReference = photoReferences[indexPath.item]
        q.sync {
            let operationToCancel = self.fetchDict[photoReference.id]
            operationToCancel?.cancel()
            //print("operation cancelled: \(String(describing: operationToCancel))")
        }
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
        let photoURL = photoReference.imageURL.usingHTTPS
        let indexPathAtCall = indexPath
        
        // FetchPhoto ConcurrentOperation
        let fetchPhotoOperation = FetchPhotoOperation(reference: photoReference)
        fetchPhotoOperation.completionBlock = {
            self.fetchDict[photoReference.id] = fetchPhotoOperation.self
            print(self.fetchDict.count)
        }
        photoFetchQueue.addOperation(fetchPhotoOperation)
        
        // Cache Image Block Operation
        let cacheImageBlockOperation = BlockOperation {
            let imageToCache = UIImage(data: fetchPhotoOperation.imageData!)
            self.cache.cache(value: imageToCache!, forKey: photoReference.id)
        }
        cacheImageBlockOperation.addDependency(fetchPhotoOperation)
        
        
        // Completion Block Operation
        let completionBlockOperation = BlockOperation {
            if (self.cache.value(forKey: photoReference.id) != nil) {
                guard indexPath == indexPathAtCall else { return }
                print("image from cache!")
                cell.imageView.image = self.cache.value(forKey: photoReference.id)
            }else {
                guard indexPath == indexPathAtCall else { return }
                cell.imageView.loadImageFrom(url: photoURL!)
            }
        }
        completionBlockOperation.addDependency(fetchPhotoOperation)
        
        photoFetchQueue.addOperation(cacheImageBlockOperation)
        OperationQueue.main.addOperation(completionBlockOperation)

        
        //        //test
//        let dummyOutside = self.cache.value(forKey: photoReference.id)
//        print(dummyOutside)
//
//        // TODO: Implement image loading
//        if (cache.value(forKey: photoReference.id) != nil) {
//            guard indexPath == indexPathAtCall else { return }
//            print("image from cache!")
//            cell.imageView.image = cache.value(forKey: photoReference.id)
//        }else {
//
////            let task = URLSession.shared.dataTask(with: photoURL!) {
////
////                data, _, error in
////                //unwrap the data
////                guard error == nil, let data = data else {
////                    if let error = error {
////                        NSLog("Error unwarapping data: \(error)")
////                        return
////                    }
////                    NSLog("Unable to fetch data")
////                    return
////                }
////                //test
////                print("no error and have data: \(data)")
////
////                //test
////                print("image from URL: \(photoReference.id), \(UIImage(data: data)!)")
////
////                //save image to cache
////                let imageToCache = UIImage(data: data)!
////                self.cache.cache(value: imageToCache, forKey: photoReference.id)
////
////                //test
////                let dummyInside = self.cache.value(forKey: photoReference.id)
////                print(dummyInside)
////            }
////            task.resume()
//
//            guard indexPath == indexPathAtCall else { return }
//            cell.imageView.loadImageFrom(url: photoURL!)
//
//        }
        
    }
    // Properties
    
    private let client = MarsRoverClient()
    
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
    
    
    private var cache = Cache<Int, UIImage>()
    private var fetchDict: [Int: Operation] = [:]
    private let photoFetchQueue = OperationQueue()
    private let q = DispatchQueue(label: "Cancelled Operation Fetch")
    
    
    
    @IBOutlet var collectionView: UICollectionView!
}
