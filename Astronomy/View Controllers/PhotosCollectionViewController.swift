//
//  PhotosCollectionViewController.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
    
    private var cache = Cache<Int, Data>()
    private var photoFetchQueue = OperationQueue()
    var photoDictionary = [Int : FetchPhotoOperation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("no")
        
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
        
        print("ITS ABOUT TO LOAD IMAGE")
        loadImage(forCell: cell, forItemAt: indexPath)
        print("OK ITS LOADED")
        
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
        
        if let image = self.cache.value(for: indexPath.item) {
            cell.imageView.image = UIImage(data: image)
        } else {
               let photoReference = photoReferences[indexPath.item]
                let loadOperation = FetchPhotoOperation(reference: photoReference)
                let updateCache = BlockOperation {
                    print("it called this update block")
                    self.cache.cache(value: loadOperation.imageData!, for: indexPath.item)
                }
                let setImages = BlockOperation {
                    print("CALLS THE IMAGE BLOCK")
                    if self.collectionView.indexPath(for: cell) == indexPath {
                    if let image = self.cache.value(for: indexPath.item) {
                        cell.imageView.image = UIImage(data: image)
                    }
                    }
                }
                
                updateCache.addDependency(loadOperation)
                setImages.addDependency(loadOperation)
                
                photoFetchQueue.addOperation(loadOperation)
                photoFetchQueue.addOperation(updateCache)
                OperationQueue.main.addOperation(setImages)
            
            photoDictionary[indexPath.item] = loadOperation
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let operation = photoDictionary[indexPath.item] {
            print("it found the operation")
            operation.cancel()
        }
    }
    
    @IBOutlet var collectionView: UICollectionView!
}
