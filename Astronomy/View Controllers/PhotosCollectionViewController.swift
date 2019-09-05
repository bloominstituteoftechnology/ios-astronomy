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
    
    let cache = Cache<Int, Data>()
    
    private let photoFetchQueue = OperationQueue()
    private var fetchDictionary: [Int: Operation] = [:]
    
    
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
        
        let photoReference = photoReferences[indexPath.item]
        
        let photoFetchOperation = FetchPhotoOperation(marsPhotoReference: photoReference)
        let saveCacheOperation = BlockOperation {
            self.cache.cache(value: photoFetchOperation.imageData!, for: photoReference.id)
        }
        let setUpImageViewOperation = BlockOperation {
            DispatchQueue.main.async {
                
                cell.imageView.image = UIImage(data: photoFetchOperation.imageData!)
                
            }
        }
        if let imageData = cache.value(for: photoReference.id) {
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                cell.imageView.image = image
                print("loaded cache image")
                return
            }
        }

        saveCacheOperation.addDependency(photoFetchOperation)
        setUpImageViewOperation.addDependency(photoFetchOperation)
        photoFetchQueue.addOperations([photoFetchOperation, saveCacheOperation, setUpImageViewOperation], waitUntilFinished: true)
        
        fetchDictionary[photoReference.id] = photoFetchOperation
//        let url = photoReference.imageURL
//        let photoId = photoReference.id
//        guard let httpURL = url.usingHTTPS else {
//            NSLog("cant make httpURL")
//            return
//        }
//
//        if let imageData = cache.value(for: photoId) {
//            let image = UIImage(data: imageData)
//            DispatchQueue.main.async {
//                cell.imageView.image = image
//                print("loaded cache image")
//            }
//        } else {
//            URLSession.shared.dataTask(with: httpURL) { (data, response, error) in
//                if let error = error {
//                    NSLog("Error doing load image dataTask: \(error)")
//                    return
//                }
//
//                guard let data = data else {
//                    NSLog("no data return on load image")
//                    return
//                }
//                DispatchQueue.main.async {
//                    let image = UIImage(data: data)
//                    cell.imageView.image = image
//                    print("load from internet")
//                    self.cache.cache(value: data, for: photoId)
//                }
//            }.resume()
//        }
    }
    
    @IBOutlet var collectionView: UICollectionView!
}
extension PhotosCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photoReference = photoReferences[indexPath.item]
        let id = photoReference.id
        let operation = fetchDictionary[id]
        operation?.cancel()
    }

}
