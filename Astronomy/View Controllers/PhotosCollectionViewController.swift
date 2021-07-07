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
    
    // MARK: - Private
    
    private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // TODO: Implement image loading here
        
        let photoReference = photoReferences[indexPath.item]
        let photoURL = photoReference.imageURL.usingHTTPS
        
        if let cacheImage = cache.value(for: photoReference.id){
            
            cell.imageView = UIImageView(image: UIImage(data: cacheImage))
            
        } else {
            
            let fetchPhotoOp = FetchPhotoOperation(marsPR: photoReference)
            
            let storeDataOp = BlockOperation {
                self.cache.cache(value: fetchPhotoOp.imageData!, for: photoReference.id)
            }
            
            let reuseOp = BlockOperation {
                guard let currentIndex = self.collectionView.indexPath(for: cell) else { return }
                
                
                if currentIndex == indexPath {
                    
                    cell.imageView.image = UIImage(data: fetchPhotoOp.imageData!)
                    
                } else {
                    return
                }
            }
            
            storeDataOp.addDependency(fetchPhotoOp)
            reuseOp.addDependency(fetchPhotoOp)
            
            photoFetchQueue.addOperation(fetchPhotoOp)
            photoFetchQueue.addOperation(storeDataOp)
            OperationQueue.main.addOperation(reuseOp)
            
            
            
           /* let dataTask = URLSession.shared.dataTask(with: photoURL!) { (photoData, _, error) in
                
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                guard let photoData = photoData else { return }
                
                let photo = UIImage(data: photoData)
                
                self.cache.cache(value: photoData, for: photoReference.id)
                
                DispatchQueue.main.async {
                    guard let currentIndex = self.collectionView.indexPath(for: cell) else { return }
                    
                    if currentIndex == indexPath {
                        
                        cell.imageView.image = photo
                        
                    } else {
                        return
                    }
                }
            }
            dataTask.resume()*/
        }
     
    }
    
    // Properties
    
    let photoFetchQueue = OperationQueue()
    
    let cache = Cache<Int, Data>()
    
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
