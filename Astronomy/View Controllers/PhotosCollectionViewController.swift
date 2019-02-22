//
//  PhotosCollectionViewController.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    // Properties
    
    private let client = MarsRoverClient()
    
    //Add a private property called photoFetchQueue, which is an instance of OperationQueue
    private var photoFetchQueue = OperationQueue()
    
    //Add a dictionary property that you'll use to store fetch operations by the associated photo reference id.
    private var fetchOperations: [Int: FetchPhotoOperation] = [:]
    
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
    
    //Add a cache proeprty to PhotosCollectionViewController. Its keys should be Ints as you'll use MarsPhotoReference ids for the keys. Its values should be Data objects, as you'll be caching image data. (You could also cache UIImages directly.)
    var cache = Cache<Int, Data>()
    
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
    
    //Implement the UICollectionViewDelegate method collectionView(_:, didEndDisplaying:, forItemAt:), which is called when a given item scrolls off screen.
 
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //In your implementation, get the associated fetch operation and cancel it.
        let photoImg = photoReferences[indexPath.item]
        if let operation = fetchOperations[photoImg.id] {
            operation.cancel()
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
        
        // TODO: Implement image loading here
        
       // guard let imageUrl = photoReference.imageURL.usingHTTPS else {return}
        
        //One should be a PhotoFetchOperation to fetch the image data from the network.
        let photoFetchOperation = FetchPhotoOperation(marsPhotoReference: photoReference)
        
    
        //One should be used to store received data in the cache.
        if let imgData = cache.value(for: photoReference.id) {
            let image = UIImage(data: imgData)
            cell.imageView.image = image
            return
        }
        
        let cachePhotoOperation = BlockOperation {
            self.cache.cache(value: photoFetchOperation.imageData, for: photoReference.id)
        }
        
        // check if the cell has been reused, and if not, set its image view's image.
        let updateUIImageCellOperation = BlockOperation {
            if let imgData = photoFetchOperation.imageData {
                cell.imageView.image = UIImage(data: imgData)
            }
        }
        
        
        //Make the cache and completion operations both depend on completion of the fetch operation.
       
        cachePhotoOperation.addDependency(photoFetchOperation)
        updateUIImageCellOperation.addDependency(photoFetchOperation)
        
        fetchOperations[photoReference.id] = photoFetchOperation
        
        
        photoFetchQueue.addOperation(photoFetchOperation)
        photoFetchQueue.addOperation(cachePhotoOperation)
        
        
        //UIKit API and must run on the main queue.
        OperationQueue.main.addOperation(updateUIImageCellOperation)
    
        //Below not needed anymore.
        
//        //In your PhotosCollectionViewController.loadImage(forCell:, forItemAt:) method, before starting a data task, first check to see if the cache already contains data for the given photo reference's id. If it exists, set the cell's image immediately without doing a network request.
//
//        if let imageData = cache.value(for: photoReference.id) {
//                        DispatchQueue.main.async {
//                            cell.imageView.image = UIImage(data: imageData)
//                        }
//                    } else {
        
            
//In PhotosCollectionViewController.loadImage(forCell:, forItemAt:), delete the code that creates a data task.
//        URLSession.shared.dataTask(with: imageUrl) { (data, _, error) in
//            if let error = error {
//                print("Error with data task: \(error)")
//                return
//            }
//
//            guard let data = data else {
//                print("There is no data")
//                return
//            }
//
//            //In your network request completion handler, save the just-received image data to the cache so it is available later.
//            self.cache.cache(value: data, for: indexPath.item)
//
//            let image = UIImage(data: data)
//
//            DispatchQueue.main.async {
//                if self.collectionView.indexPath(for: cell) == indexPath {
//
//                    cell.imageView.image = image
//
//                }
//            }
//
//            }.resume()
      //  }
    }
    
   
    
    @IBOutlet var collectionView: UICollectionView!
}
