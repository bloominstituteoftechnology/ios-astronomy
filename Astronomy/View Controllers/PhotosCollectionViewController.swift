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

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
           if photoReferences.count > 0 {
               let photoRef = photoReferences[indexPath.item]
               operations[photoRef.id]?.cancel()
           } else {
               for (_, operation) in operations {
                   operation.cancel()
               }
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

        if let cachedImage = cache.value(for: photoReference.id), let image = UIImage(data: cachedImage) {
                cell.imageView.image = image
                return
            }

        let fetchOp = FetchPhotoOperation(photoReference: photoReference)
          let cacheOp = BlockOperation {
              if let data = fetchOp.imageData {
                self.cache.cache(value: data, for: photoReference.id)
              }
          }
          let completionOp = BlockOperation {
              defer { self.operations.removeValue(forKey: photoReference.id) }

              if let currentIndexPath = self.collectionView?.indexPath(for: cell),
                  currentIndexPath != indexPath {
                  return
              }

              if let data = fetchOp.imageData {
                  cell.imageView.image = UIImage(data: data)
              }
          }

          cacheOp.addDependency(fetchOp)
          completionOp.addDependency(fetchOp)

          photoFetchQueue.addOperation(fetchOp)
          photoFetchQueue.addOperation(cacheOp)
          OperationQueue.main.addOperation(completionOp)

          operations[photoReference.id] = fetchOp


    }
    
    // Properties
    
    private let client = MarsRoverClient()
    private let cache = Cache<Int, Data>()
    private let photoFetchQueue = OperationQueue()
    private var operations = [Int : Operation]()

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
