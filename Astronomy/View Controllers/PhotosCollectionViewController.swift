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
		solSelectorVC.delegate = self
        
        client.fetchMarsRover(named: "curiosity") { (rover, error) in
            if let error = error {
                NSLog("Error fetching info for curiosity: \(error)")
                return
            }
            
            self.roverInfo = rover
        }
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		collectionView.reloadData()
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
		let reference = photoReferences[indexPath.item]
		let operation = storedFetchOperations[reference.id]
		queue.sync {
			operation?.cancel()
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
		let photoURL = photoReference.imageURL.usingHTTPS
		guard let url = photoURL else { return }

		if let imageData = cache.value(for: url) {
			let image = UIImage(data: imageData)
			cell.imageView.image = image
			return
		}

		let fetchPhotoOperation = FetchPhotoOperation(marsPhotoReference: photoReference)

		let storeDataInCache = BlockOperation {
			guard let imageData = fetchPhotoOperation.imageData else { return }
			self.cache.cache(value: imageData, for: url)
		}

		let setImage = BlockOperation {
			defer {
				self.storedFetchOperations.removeValue(forKey: photoReference.id)
			}

			if let currentIndexPath = self.collectionView.indexPath(for: cell),
				currentIndexPath != indexPath {
				return
			}
			guard let imageData = fetchPhotoOperation.imageData else { return }
			cell.imageView.image = UIImage(data: imageData)
		}


		storeDataInCache.addDependency(fetchPhotoOperation)
		setImage.addDependency(fetchPhotoOperation)

		photoFetchQueue.addOperation(fetchPhotoOperation)
		photoFetchQueue.addOperation(storeDataInCache)
		OperationQueue.main.addOperation(setImage)

		storedFetchOperations[photoReference.id] = fetchPhotoOperation

	}


    
    // Properties

	let cache = Cache<URL, Data>()

	let solSelectorVC = SolSelectViewController()

	private let photoFetchQueue = OperationQueue()

	let queue = DispatchQueue(label: "CancelOperationQueue")

	var storedFetchOperations: [Int: FetchPhotoOperation] = [:]
    
    private let client = MarsRoverClient()
    
    private var roverInfo: MarsRover? {
        didSet {
            solDescription = roverInfo?.solDescriptions[1006]
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

extension PhotosCollectionViewController: SolSelectViewControllerDelegate {
	func didSelect(solarDay: Int) {
		print(solarDay)
		solDescription = roverInfo?.solDescriptions[solarDay]
		collectionView.reloadData()
	}
}
