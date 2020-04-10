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
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCollectionViewCell else { fatalError() }
        let photoReference = photoReferences[indexPath.item]
        cell.indexPath = indexPath
        cell.photoId = photoReference.id
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
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photoReference = photoReferences[indexPath.item]
        opDic[photoReference.id]?.cancel()
        print("Cancelled opdic entry for id: \(photoReference.id)")
        
    }
    
    // MARK: - Private
    
    private var opDic: [Int : FetchPhotoOperation] = [ : ]
    
    private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photoReference = photoReferences[indexPath.item]
//         TODO: Implement image loading here
        
        let fetchOp = FetchPhotoOperation(marsReference: photoReference)
        
        let storeCache = BlockOperation {
            if let data = fetchOp.imageData {
                self.cache.cache(value: data, for: photoReference.id)
            } else {
                print("NO DATA TO STORE IN STORECAHCE OP")
            }
            
        }
        storeCache.addDependency(fetchOp)
        
        let lastOp = BlockOperation {
//            var visibleIndexPath: [IndexPath] = []
            var visibleCells: [UICollectionViewCell] = []
            DispatchQueue.main.sync {
//                visibleIndexPath = self.collectionView.indexPathsForVisibleItems
                visibleCells = self.collectionView.visibleCells
            }
            DispatchQueue.main.async {
                
//                guard let checkIndex = visibleIndexPath.firstIndex(where: {
//                    let tempCell = self.collectionView.cellForItem(at: $0) as! ImageCollectionViewCell
//                    print("Looking for tempcell with a photo ID of \(cell.photoId)")
//                    return tempCell.photoId == cell.photoId
//                }) else {
//                    print("Couldn't find cell with photo ID \(cell.photoId).")
//                    print("Here's' what I could find")
//                    for path in visibleIndexPath {
//                        let tempCell = self.collectionView.cellForItem(at: path) as! ImageCollectionViewCell
//                        print(tempCell.photoId)
//                    }
//                    return
//                }
                
                
//                guard let checkCell = checkCellExistence as? ImageCollectionViewCell else {
//                    print("Error casting existing cell")
//                    return
//                }
                guard let data = self.cache.value(for: photoReference.id) else {
                        NSLog("ERROR UNWRAPPING DATA ")
                        return }
                for visibleCell in visibleCells {
                    guard let visibleCell = visibleCell as? ImageCollectionViewCell else {
                        print("Couldn't cast cell")
                        return
                    }
                    if visibleCell.photoId == cell.photoId {
                        visibleCell.imageView.image = UIImage(data: data)
                    }
                }
//                guard let foundCell = self.collectionView.cellForItem(at: visibleIndexPath[checkIndex]) as? ImageCollectionViewCell else {
//                    print("Found index, but couldn't turn it into a cell")
//                    return
//                }
//                foundCell.imageView.image = UIImage(data: data)
//                if  checkCell.photoId == cell.photoId {
//                    checkCell.imageView.image = UIImage(data: data)
//                }
            }
        }
        lastOp.addDependency(fetchOp)
        
        photoFetchQueue.addOperations([fetchOp, storeCache, lastOp], waitUntilFinished: false)
        
        
        if opDic[photoReference.id] == nil {
            opDic[photoReference.id] = fetchOp
            print("created a dictionary entry for id \(photoReference.id)")
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell else { return }
        print(cell.photoId)
        loadImage(forCell: cell, forItemAt: indexPath)
        print("Fetched for index path: \(indexPath)")
    }
    
    // Properties
    
    private var photoFetchQueue = OperationQueue()
    
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
