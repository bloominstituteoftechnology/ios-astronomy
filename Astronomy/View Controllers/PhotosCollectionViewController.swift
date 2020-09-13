//
//  PhotosCollectionViewController.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //  MARK: - properties
    private let client = MarsRoverClient()
    //  will hold photo id + data
    private let photoDataCache = Cache<Int, Data>()
    //  need OperationQueue for fetch in background
    private let photoFetchQueue = OperationQueue()
    //  we'll collect photos in a dictionary
    private var operations = [Int : Operation]()
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
    
    //  MARK: - view lifecycle
    
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
    
    //  MARK: - UICollectionViewDataSource/Delegate
    
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
    
    // MARK: - Private
    
    private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
        //  access the MarsPhotoReference instance for the passed in indexPath from the array
        let photoReference = photoReferences[indexPath.item]
        //  check to see if the cache already contains data for the given photo reference's id
        if let cachedData = photoDataCache.value(key: photoReference.id),
            let image = UIImage(data: cachedData) {
            //  if the data already exists:
            cell.imageView.image = image
            return
        }
        
        let fetchOperation = FetchPhotoOperation(photo: photoReference)
        
        //  cache data from fetch
        let cacheOperation = BlockOperation {
            if let data = fetchOperation.imageData {
                self.photoDataCache.cache(key: photoReference.id, value: data)
            }
        }
        
        let displayImageOperation = BlockOperation {
            //  create a way to clear an operation from the dictionary
            defer {self.operations.removeValue(forKey: photoReference.id)}
            
            //  check to see if the current index path for the cell is the same one
            if let currentIndexPath = self.collectionView.indexPath(for: cell),
                currentIndexPath != indexPath {
                print("image for reused cell")
                //  abort setting the image
                return
            }
            
            if let data = fetchOperation.imageData {
                cell.imageView.image = UIImage(data: data)
            }
        }
        
        photoFetchQueue.addOperation(fetchOperation)
        photoFetchQueue.addOperation(cacheOperation)
        cacheOperation.addDependency(fetchOperation)
        displayImageOperation.addDependency(fetchOperation)
        //  move finished images to the main queue :-)
        OperationQueue.main.addOperation(displayImageOperation)
    }
    
    
}
