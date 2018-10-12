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
        
        DispatchQueue.main.async {
            self.loadImage(forCell: cell, forItemAt: indexPath)
        }
        
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
    // TODO: Implement image loading here
    private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photoReference = photoReferences[indexPath.item]
    
        let fetchOperation = FetchPhotoOperation(photoReference: photoReference)
        let cacheOperation = BlockOperation {
            self.cache.cache(value: UIImage(data: fetchOperation.imageData!)!, key: photoReference.id)
        }
        let setOperation = BlockOperation {
            // ATTEMPTS TO SET FROM CACHE
            if self.cache.value(for: photoReference.id) != nil {
                cell.imageView.image = self.cache.value(for: photoReference.id)
                return
            }
        }
        
        cacheOperation.addDependency(fetchOperation)
        setOperation.addDependency(fetchOperation)
        
        photoFetchQueue.addOperation(fetchOperation)
        photoFetchQueue.addOperation(cacheOperation)
        
        OperationQueue.main.addOperation(setOperation)
        
        operations.updateValue(fetchOperation, forKey: photoReference.id)
        
//        DispatchQueue.main.async(execute: setOperation)
        
        //DEPRECATE BECAUSE WE ARE USING NSOPERATION INSTEAD
//        URLSession.shared.dataTask(with: photoReference.imageURL) { (data, _, error) in
//
//            if let error = error {
//                NSLog("Could not GET image: \(error)")
//                return
//            }
//
//            guard let data = data else {
//                NSLog("Data corrupted")
//                return
//            }
//
//            self.cache.cache(value: UIImage(data: data)!, key: photoReference.id)
//
//            DispatchQueue.main.sync {
//                if self.collectionView.indexPathsForVisibleItems.contains(indexPath){
//                    let marsImage = UIImage(data: data)
//                    cell.imageView.image = marsImage
//                } else {
//                   return
//                }
//            }
//
//        }.resume()
        
    }
    
    // Properties
    
    private var operations = [Int: Operation]()
    
    private var photoFetchQueue = OperationQueue()
    
    private var cache = Cache<Int, UIImage>()
    
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
    
    @IBOutlet var collectionView: UICollectionView!
}
