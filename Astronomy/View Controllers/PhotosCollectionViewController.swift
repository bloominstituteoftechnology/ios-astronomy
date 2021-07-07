//
//  PhotosCollectionViewController.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let cache = Cache<Int, Data>()

    private let photoFetchQueue = OperationQueue()

    var operation: [Int : Operation] = [:]

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
        let photoReference = photoReferences[indexPath.item]
        let key = photoReference.id
        operation[key]?.cancel()
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
        let key = photoReference.id
        

        if let cachedData = cache.value(for: key) {
            let image = UIImage(data: cachedData)
            cell.imageView.image = image
        } else {
            let fetchImage = FetchPhotoOperation(reference: photoReference)
            let storeCacheData = BlockOperation {
                if let data = fetchImage.imageData {
                    self.cache.cache(value: data, for: key)
                }
            }

            let setCellImage = BlockOperation {
                if let imageData = fetchImage.imageData {
                    cell.imageView.image = UIImage(data: imageData)
                }
            }
            storeCacheData.addDependency(fetchImage)
            setCellImage.addDependency(fetchImage)
            photoFetchQueue.addOperations([fetchImage, storeCacheData], waitUntilFinished: false)
            OperationQueue.main.addOperation(setCellImage)

            operation[key] = fetchImage
        }
    }


//        guard let request = photoReference.imageURL.usingHTTPS else { return }
//        let key = photoReference.id
//        if let cachedData = cache.value(for: key),
//            let image = UIImage(data: cachedData) {
//            cell.imageView.image = image
//        } else {
//            URLSession.shared.dataTask(with: request) { data, _, error in
//                if let error = error {
//                    NSLog("Error retrieving photo from server. \(error)")
//                    return
//                }
//                guard let data = data else {
//                    NSLog("Error bad data")
//                    return
//                }
//                self.cache.cache(value: data, for: key)
//                let image = UIImage(data: data)
//                DispatchQueue.main.async {
//                    if cell == self.collectionView.cellForItem(at: indexPath) {
//                        DispatchQueue.main.async {
//                            cell.imageView.image = image
//                        }
//                    } else {
//                        return
//                    }
//                }
//            }.resume()
//        }
//    }
    
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
    
    @IBOutlet var collectionView: UICollectionView!
}
