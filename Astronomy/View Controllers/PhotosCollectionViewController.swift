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
	
	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		guard let photoUrl = photoReferences[indexPath.item].imageURL.usingHTTPS,
			let fetchOp = storedFetchOps[photoUrl.absoluteString] else { return }
		
		cancelQueue.sync {
			fetchOp.cancel()
		}
	}
    
    // MARK: - Private
    
    private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
		let photoRef = photoReferences[indexPath.item]
		guard let photoUrl = photoRef.imageURL.usingHTTPS else { return }
		
		if let photoData = self.storage.value(for: photoUrl.absoluteString) {
			cell.imageView.image =  UIImage(data: photoData)
		}
		
		let fetchPhotoOp = FetchPhotoOperation(photoRef: photoRef)
		let cacheOp = BlockOperation {
			if let photoData = fetchPhotoOp.imageData {
				self.storage.cache(value: photoData, for: photoUrl.absoluteString)
			}
		}
		
		let cellCheckOp = BlockOperation {
			if let cellPath = self.collectionView.indexPath(for: cell), cellPath != indexPath {
				return
			}
			if let photoData = fetchPhotoOp.imageData {
				cell.imageView.image =  UIImage(data: photoData)
			}
		}
		
		cacheOp.addDependency(fetchPhotoOp)
		cellCheckOp.addDependency(fetchPhotoOp)
		
		photofetchQueue.addOperations([fetchPhotoOp, cacheOp], waitUntilFinished: false)
		OperationQueue.main.addOperation(cellCheckOp)
		
		storedFetchOps.updateValue(fetchPhotoOp, forKey: photoUrl.absoluteString)
    }
    
    // Properties
	private let cancelQueue = DispatchQueue(label: "MyCancelationOps")
	private var storedFetchOps = [String:FetchPhotoOperation]()
	private let photofetchQueue = OperationQueue()
	private var storage = Cache<String, Data>()
	
    private let client = MarsRoverClient()
    private var roverInfo: MarsRover? {
        didSet {
            solDescription = roverInfo?.solDescriptions[55]
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
