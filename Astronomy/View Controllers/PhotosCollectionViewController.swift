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
    private let cache = Cache<Int, Data>() // identifer and the the data that goes w/ that identifier, can also use strings, strings can be indicative of keys
    private let photoFetchQueue = OperationQueue()
    // background queue, dispatch is main/ serial queue, aka whenever you're ready change it to the main thread
    // serial queue is main thread, want photo fetch to do in the background queue then switch them to the main queue when they load.
    
    private var operations = [Int : Operation]()
    
    // mars rover structs that gathers the rover
    private var roverInfo: MarsRover? {
        didSet {
            solDescription = roverInfo?.solDescriptions[3]
        }
    }
    
    // talks about the particular day that the picture was taken on
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
    
    // depending on the rover and the day it was taken it will populate and reload the table view with that information.
    private var photoReferences = [MarsPhotoReference]() {
        didSet {
            DispatchQueue.main.async { self.collectionView?.reloadData() }
        }
    }
    
    @IBOutlet var collectionView: UICollectionView!
    
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
        
//        let photoReference = photoReferences[indexPath.item]
        // TODO: Implement image loading here
        //create the url and set it equal to the photoReference's imageURL and then adding .usingHTTPS
        //        if let imageURL = photoReference.imageURL.usingHTTPS {
        //
        // this is the slow way of doing it
        //            let task = URLSession.shared.dataTask(with: imageURL) { (data, _, error) in
        //                if let error = error {
        //                    print("Error fetching image: \(error)")
        //                    return
        //                }
        //                guard let data = data else {
        //                    print("No data returned from fetch")
        //                    return
        //                }
        //                let image = UIImage(data: data)
        //                DispatchQueue.main.async {
        //                    if self.collectionView.indexPath(for: cell) == indexPath {
        //                        cell.imageView.image = image
        //                    }
        //                }
        //            }
        //            task.resume()
        
        let photoReference = photoReferences[indexPath.item]
        
        // Check if there is cached data
        if let cachedData = cache.value(key: photoReference.id),
        let image = UIImage(data: cachedData) {
            cell.imageView.image = image
            return
        }
        
        // Start our fetch operations
        let fetchOp = FetchPhotoOperation(photoReference: photoReference)
        
        // saving
        let cacheOp = BlockOperation {
            if let data = fetchOp.imageData {
                self.cache.cache(key: photoReference.id, value: data)
            }
        }
        
        // populating the image
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: photoReference.id) }
            if let currentIndexPath = self.collectionView.indexPath(for: cell),
                // refering to the for item at indexpath that is passed in above, not in the line of code below
                currentIndexPath != indexPath {
                print("Got image for reused cell")
                return
            }
            
            if let data = fetchOp.imageData {
                cell.imageView.image = UIImage(data: data)
            }
        }
        
        // cache op is dependent on fetch op before it can go
        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)
        photoFetchQueue.addOperation(fetchOp)
        photoFetchQueue.addOperation(cacheOp)
        
        // when completion op is ready to go then we can move back to the main queue to ensure that all the other work on the background thread has completed.
        OperationQueue.main.addOperation(completionOp)
        
        operations[photoReference.id] = fetchOp // line up the fetch up w/ the cell it is trying to pull up if it ends up canceling.
        
    }
}

