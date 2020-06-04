//
//  PhotosCollectionViewController.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let cache = Cache<Int,Data>()
    let photoFetchQueue = OperationQueue()
    var operationsDict: [Int : Operation] = [:]
    
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
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let op = operationsDict[photoReferences[indexPath.row].id] {
            op.cancel()
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
        
        if let cache = cache.value(for: photoReference.id) {
            cell.imageView.image = UIImage(data: cache)
            return
        } else {
            
            let fetchPhotoOperation = FetchPhotoOperation(photo: photoReference)
            
            let cacheImageData = BlockOperation {
                self.cache.cache(value: fetchPhotoOperation.imageData!, for: photoReference.id)
            }

            let setCellImage = BlockOperation {
                DispatchQueue.main.async {
                    if self.collectionView.indexPath(for: cell) == indexPath {
                        cell.imageView.image = UIImage(data: fetchPhotoOperation.imageData!)
                    } else {
                        return
                    }
                }
            }

            cacheImageData.addDependency(fetchPhotoOperation)
            setCellImage.addDependency(fetchPhotoOperation)

            photoFetchQueue.addOperations([fetchPhotoOperation, cacheImageData, setCellImage], waitUntilFinished: false)
            operationsDict[photoReference.id] = fetchPhotoOperation
        }
    
        
        
        
    /*
         if let cache = cache.value(for: photoReference.id) {
             cell.imageView.image = UIImage(data: cache)
             return
         }
         
         let imageURL = photoReference.imageURL.usingHTTPS!
         var request = URLRequest(url: imageURL)
         request.httpMethod = "GET"
         
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                NSLog("Error receiving pokemon image data: \(error)")
                return
            }
            guard let data = data else {
                NSLog("API responded with no image data")
                return
            }
            
            guard let image = UIImage(data: data) else {
                NSLog("Image data is incomplete or currupted.")
                return
            }
            
            DispatchQueue.main.async {
                if self.collectionView.indexPath(for: cell) == indexPath {
                    cell.imageView.image = image
                    self.cache.cache(value: data, for: photoReference.id)
                } else {
                    return
                }
            }
            
        }.resume()
         
   */
        
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
    
    @IBOutlet var collectionView: UICollectionView!
}
