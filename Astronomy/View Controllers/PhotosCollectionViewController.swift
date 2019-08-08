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
        
        let photoReference = photoReferences[indexPath.item]
        cancelQ.sync {
            if let storedOp = storedFetchOperations[photoReference.id] {
                storedOp.cancel()
            }
        }
    }
    
    // MARK: - Private
    
    private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
        
         let photoReference = photoReferences[indexPath.item]
        
        // TODO: Implement image loading here
        if let imageData = cache.value(for: photoReference.id) {
            cell.imageView.image = UIImage(data: imageData)
            return
        }
        
        
        let fetchPhotoOp = FetchPhotoOp(marsPhotoReference: photoReference)
//        let fetchPhotoImageData = fetchPhotoOp.imageData
        let cacheOp = BlockOperation {
            if let data = fetchPhotoOp.imageData {
                self.cache.cache(value: data, key: photoReference.id)
            }
        }
        cacheOp.addDependency(fetchPhotoOp)
   
        let cellReuseOp = BlockOperation {
            if let cellIndexPath = self.collectionView.indexPath(for: cell),
                cellIndexPath != indexPath {
                return
            }

            if let imageData = fetchPhotoOp.imageData {
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(data: imageData)
                    
                }
            }
            
        }
        cellReuseOp.addDependency(fetchPhotoOp)
        
        photoQueue.addOperations([fetchPhotoOp, cacheOp], waitUntilFinished: false)
        OperationQueue.main.addOperation(cellReuseOp)
     
        self.storedFetchOperations[photoReference.id] = fetchPhotoOp
    }
    
    // Properties
    
    private let client = MarsRoverClient()
    private var cache: Cache<Int, Data> = Cache()
    var storedFetchOperations: [ Int : FetchPhotoOp ] = [:]
    private let photoQueue = OperationQueue()
    private let cancelQ = DispatchQueue(label: "Cancel Queue")
    
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
