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
    
    //implement cancellation
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //get the associated fetch operaton and cancel it
        let photoReference = photoReferences[indexPath.item]
        storedFetchOperations[photoReference.id]?.cancel()
    }
    
    // MARK: - Private
    
    private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photoReference = photoReferences[indexPath.item]
        
        // TODO: Implement image loading here
        //check to see if the cache already contains data for the given photo reference's id. if it exists, set the cell's image immediately without doing a network request.
        if let image = cache.value(for: photoReference.id){
            cell.imageView.image = image
            return
        } else {
            
            //create three operations
            //one should be a photoFEtchOperation to fetch the image data from the network
            let fetchPhotoOperation = FetchPhotoOperation(marsPhotoReference: photoReference)
            
            //one should be used to store the received data in the cache
            let cacheOperation = BlockOperation {
                guard let data = fetchPhotoOperation.imageData,
                    let image = UIImage(data: data) else { print("cacheOperation: Error unwrapping data"); return }
                self.cache.cache(value: image, forKey: photoReference.id)
            }
            
            //one should check if the cell has been reused, and if not, set its image veiws image
            let cellReuseOperation = BlockOperation {
                guard let data = fetchPhotoOperation.imageData,
                    let image = UIImage(data: data) else { print("cacheOperation: Error unwrapping data"); return }
                
                if self.collectionView.indexPath(for: cell) == indexPath {
                    cell.imageView.image = image
                }
            }
            
            //make the cache and completion operations both depend on completion of the fetch operation
            cacheOperation.addDependency(fetchPhotoOperation)
            cellReuseOperation.addDependency(fetchPhotoOperation)
            
            //add each operation to the appropriate queue. Note that the last operation above uses uikit api and must run on the main queue
            photoFetchQueue.addOperations([fetchPhotoOperation, cacheOperation], waitUntilFinished: false)
            OperationQueue.main.addOperation(cellReuseOperation)
            
            //when you finish creating and starting the operations for a cell, add the fetch operation to your dictionary that way you can retrieve it later to cancel if need be.
            storedFetchOperations[photoReference.id] = fetchPhotoOperation
        }
        
        //commented out so that we can use operations to do image loading.
        //        let imageURL = photoReference.imageURL
        //        guard let url = imageURL.usingHTTPS else { print("Error with constructing url"); return }
        //        URLSession.shared.dataTask(with: url) { (data, response, error) in
        //            if let response = response as? HTTPURLResponse {
        //                print("response from loading image: \(response.statusCode)")
        //            }
        //            if let error = error {
        //                print("Error loading image: \(error.localizedDescription), real error message: \(error)")
        //                return
        //            }
        //            guard let data = data else {
        //                print("Error unwraping data loading images")
        //                return
        //            }
        //
        //            //in the network completionhandler save the just received image data to the cache so it is available later
        //            if let imageDataForCache = UIImage(data: data){
        //                self.cache.cache(value: imageDataForCache, forKey: photoReference.id)
        //            }
        //            if let imageData = UIImage(data: data) {
        //                DispatchQueue.main.async {
        //                    cell.imageView.image = imageData
        //                }
        //            }
        //
        //        }.resume()
    }
    
    // Properties
    
    var storedFetchOperations: [ Int : FetchPhotoOperation ] = [:]
    
    private let photoFetchQueue = OperationQueue()
    
    //add a cache property. its key should be Int as you'll use MarsPhotoReference ids for the keys. its values should be Data objects, as you'll be caching image data.
    private var cache: Cache<Int, UIImage> = Cache() //int is hashable
    
    private let client = MarsRoverClient()
    
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
    
    @IBOutlet var collectionView: UICollectionView!
}
