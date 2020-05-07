//
//  PhotosCollectionViewController.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //MARK: - Properties

    private let client = MarsRoverClient()
    private let photoDataCache = Cache<Int, Data>() // photo ID and related photo data.
    private let photoFetchQueue = OperationQueue() // OperationQueue for fetch in background.
    private var operations = [Int : Operation]()  // holding each photos Operation in a dictionary.
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

    // MARK: - View Lifecycle
    
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

        if let cachedData = photoDataCache.value(key: photoReference.id),
            let image = UIImage(data: cachedData) {
                cell.imageView.image = image
                return
            }

         // fetch operation
        let fetchOperation = FetchPhotoOperation(photo: photoReference)

        // cache data we've fetched
        let cacheOperation = BlockOperation {
            if let data = fetchOperation.imageData {
                self.photoDataCache.cache(key: photoReference.id, value: data)
            }
        }

        let displayImageOperation = BlockOperation {
            defer {self.operations.removeValue(forKey: photoReference.id)} // clears the operation from the dictionary.
            if let currentIndexPath = self.collectionView.indexPath(for: cell),
                currentIndexPath != indexPath {
                print("Image for reused cell.")
                return
            }
            if let data = fetchOperation.imageData {
                cell.imageView.image = UIImage(data: data)
            }
        }

        photoFetchQueue.addOperation(fetchOperation) // fetching operation
        photoFetchQueue.addOperation(cacheOperation)
        cacheOperation.addDependency(fetchOperation) // can't cache until we have an image to cache
        displayImageOperation.addDependency(fetchOperation)
        OperationQueue.main.addOperation(displayImageOperation) // moving our finished images to the main queue
        }

        // commenting this out and moving to blockoperations...
//        // TODO: Implement image loading here
//        guard let url = photoReference.imageURL.usingHTTPS else { return }
//
//        let dataTask = URLSession.shared.dataTask(with: url) { (data, _, error) in
//            if let error = error {
//                NSLog("Error getting image: \(error)")
//                return
//            }
//            guard let data = data else {
//                NSLog("No data.")
//                return
//            }
//
//            let image = UIImage(data: data)
//            DispatchQueue.main.async {
//                if self.collectionView.indexPath(for: cell) == indexPath {
//                    cell.imageView.image = image
//                }
//            }
//        }
//
//        dataTask.resume()
    }


