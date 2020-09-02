//
//  PhotosCollectionViewController.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - IBOutlets
    
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: - View Lifecycle
    
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
    
    // MARK: - Private Properties
    
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
    
    private var cache = Cache<Int, Data>()
    
    private let photoFetchQueue: OperationQueue = {
        let pfq = OperationQueue()
        pfq.name = "Photo Fetch Queue"
        return pfq
    }()
    
    private var fetchOperations: [Int: FetchPhotoOperation] = [:]
    
    // MARK: - Private Methods
    
    private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
        let photoReference = photoReferences[indexPath.item]
        
        let cachedData = cache.value(for: photoReference.id)
        if let cachedData = cachedData, let image = UIImage(data: cachedData) {
            DispatchQueue.main.async {
                cell.imageView.image = image
            }
            
            return
        }
        
        let fetchOperation = FetchPhotoOperation(photoReference: photoReference)
        
        let cacheOperation = BlockOperation {
            guard let imageData = fetchOperation.imageData else { return }
            let size = imageData.count
            self.cache.cache(imageData, ofSize: size, for: photoReference.id)
        }
        
        cacheOperation.addDependency(fetchOperation)
        
        let updateCellOperation = BlockOperation {
            self.fetchOperations.removeValue(forKey: photoReference.id)
            guard let imageData = fetchOperation.imageData,
                let image = UIImage(data: imageData),
                cell.photoReferenceID == photoReference.id else { return }
            
            cell.imageView.image = image
        }
        
        updateCellOperation.addDependency(fetchOperation)
        
        photoFetchQueue.addOperations([fetchOperation, cacheOperation], waitUntilFinished: false)
        OperationQueue.main.addOperation(updateCellOperation)
        
        fetchOperations[photoReference.id] = fetchOperation
    }
    
    // MARK: - Collection View Data Source & Delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoReferences.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCollectionViewCell ?? ImageCollectionViewCell()
        
        cell.photoReferenceID = photoReferences[indexPath.item].id
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
    
    // Cancel fetch operations for cells off-screen
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photoReference = photoReferences[indexPath.item]
        
        fetchOperations[photoReference.id]?.cancel()
        fetchOperations.removeValue(forKey: photoReference.id)
    }
}
