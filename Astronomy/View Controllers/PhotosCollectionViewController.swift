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
        
        cell.indexLabel.text = "\(indexPath.row)"
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
        if let fetchOperation = fetchOperations[photoReference.id] {
            fetchOperation.cancel()
            print("Canceling operation at \(indexPath)")
        }
    }
    
    // MARK: - Private
    
    private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photoReference = photoReferences[indexPath.item]
        
        if let imageData = cache.value(for: photoReference.id) {
            let image = UIImage(data: imageData)
            cell.imageView.image = image
            return
        }
            
        let fetchPhotoOperation = FetchPhotoOperation(photoReference: photoReference)
        
        let storeDataInCacheOperation = BlockOperation{
            guard let data = fetchPhotoOperation.imageData else { return }
            self.cache.cache(value: data, for: photoReference.id)
        }
        
        let updateCellImageOperation = BlockOperation{
            guard let imageData = fetchPhotoOperation.imageData else { return }
            let image = UIImage(data: imageData)
            if self.collectionView.indexPath(for: cell) == indexPath {
                    cell.imageView.image = image
            }
            print("Updating cell at \(indexPath)")
        }
        
        storeDataInCacheOperation.addDependency(fetchPhotoOperation)
        updateCellImageOperation.addDependency(fetchPhotoOperation)
        
        photoFetchQueue.addOperation(fetchPhotoOperation)
        photoFetchQueue.addOperation(storeDataInCacheOperation)
        OperationQueue.main.addOperation(updateCellImageOperation)
        
        fetchOperations[photoReference.id] = fetchPhotoOperation
            
//            URLSession.shared.dataTask(with: photoURL) { (data, _, error) in
//                if let error = error {
//                    NSLog("Error fetching image: \(error)")
//                    return
//                }
//
//                guard let data = data else {
//                    NSLog("No data was returned.")
//                    return
//                }
//
//                self.cache.cache(value: data, for: photoReference.id)
//                let image = UIImage(data: data)
//
//                DispatchQueue.main.async {
//                    if self.collectionView.indexPath(for: cell) == indexPath {
//                        cell.imageView.image = image
//                    }
//                }
//            }.resume()
    }
    
    // Properties
    
    private var fetchOperations: [Int : FetchPhotoOperation] = [:]
    private var photoFetchQueue = OperationQueue()
    private var cache = Cache<Int, Data>()
    
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
