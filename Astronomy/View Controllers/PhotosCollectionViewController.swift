//
//  PhotosCollectionViewController.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Outlets
    
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    private let client = MarsRoverClient()
    private let cache = Cache<Int, Data>()
    private let photoFetchQueue = OperationQueue()
    private var fetchOperations: [Int: FetchPhotoOperation] = [:]
    private var roverInfo: MarsRover? {
        didSet {
            solDescription = roverInfo?.solDescriptions[100]
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

    // MARK: - Lifecycle Methods
    
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
    
    // MARK: - UICollectionViewDataSource/Delegate
    
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
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        fetchOperations[photoReferences[indexPath.item].id]?.cancel()
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
        
        // let photoReference = photoReferences[indexPath.item]
        
        // TODO: Implement image loading here
        if let imageData = cache.value(for: indexPath.row), let image = UIImage(data: imageData) {
            cell.imageView.image = image
            return
        }
        
        let photoFetchOperation = FetchPhotoOperation(marsPhotoReference: photoReferences[indexPath.item])
        
        let storeData = BlockOperation {
            if let imageData = photoFetchOperation.imageData {
                self.cache.cache(value: imageData, for: indexPath.item)
            }
        }
        
        let setImage = BlockOperation {
            if self.collectionView.indexPath(for: cell) != indexPath {
                return
            } else {
                guard let data = photoFetchOperation.imageData else { return }
                let image = UIImage(data: data)
                cell.imageView.image = image
            }
        }
        
        setImage.addDependency(photoFetchOperation)
        storeData.addDependency(photoFetchOperation)
        photoFetchQueue.addOperations([photoFetchOperation, storeData], waitUntilFinished: false)
        OperationQueue.main.addOperations([setImage], waitUntilFinished: false)
        
        fetchOperations[photoReferences[indexPath.item].id] = photoFetchOperation
        
        
        
        
//        guard let photoURL = photoReferences[indexPath.row].imageURL.usingHTTPS else { return }
        
//        if let imageData = cache.value(for: indexPath.row) {
//            let image = UIImage(data: imageData)
//            cell.imageView.image = image
////            print("Cached Image")
//            return
//        }
        
        
//        let fetchImage = URLSession.shared.dataTask(with: photoURL) { data, _, error in
//
//            if let error = error {
//                print("Error fetching image data: \(error)")
//                return
//            }
//
//            if let data = data {
//                guard let image = UIImage(data: data) else { return }
//                DispatchQueue.main.async {
//                if self.collectionView.indexPath(for: cell) != indexPath {
//                    return
//                }
//                    cell.imageView.image = image
////                    print("fetched an image")
//                    self.cache.cache(value: data, for: indexPath.row)
//                }
//            }
//        }.resume()
    }
    
    
    
}
