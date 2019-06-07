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
    
    // MARK: - Private
    
    private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
		// MARK: - check your on the right cell
		
//		let lock = NSLock()
//		lock.lock()
		
		if let imageIndexPath = self.collectionView.indexPath(for: cell), imageIndexPath.item != indexPath.item {
			return
		}
		
//		print("\(imageIndexPath.item) \(imageIndexPath.item == indexPath.item) \(indexPath.item)")
		
//		lock.unlock()
		
		if iscached(indexPath.item, cell) { return }
		
        let photoReference = photoReferences[indexPath.item]
		
		let task = URLSession.shared.dataTask(with: photoReference.imageURL.usingHTTPS!) { (data, response, error) in
			if let response = response as? HTTPURLResponse , response.statusCode != 200{
				print("Response code: \(response.statusCode)")
			}
			
			if let error = error {
				print("Error getting image: \(error)")
				return
			}
			
			guard let data = data else {
				print("Error fetching image data.")
				return
			}
			
			//print(data)
			let image = UIImage(data: data)
			DispatchQueue.main.sync {
				cell.imageView.image = image
				self.cache.cache(value: data, for: indexPath.item)
				//print("cashed \(indexPath.item)")
			}
		}
		
		task.resume()
		
        // TODO: Implement image loading here
    }
    
    // Properties
    
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
            DispatchQueue.main.async { self.collectionView?.reloadData()
				//print(self.photoReferences.count)
			}
        }
    }
    
    @IBOutlet var collectionView: UICollectionView!
	var cache = Cache<Int, Data>()
}

extension PhotosCollectionViewController {
	func iscached(_ item: Int, _ cell: ImageCollectionViewCell) -> Bool {
		if let getData = cache.value(for: item) {
			cell.imageView.image = UIImage(data: getData)
			//print("Found cache")
			return true
		}

		return false
	}
	
	
	
}
