//
//  PhotosCollectionViewController.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class PhotosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var solIndex = 3
    
    private let client = MarsRoverClient()
    
    private var roverInfo: MarsRover? {
        didSet {
            solDescription = roverInfo?.solDescriptions[solIndex]
        }
    }
    private var solDescription: SolDescription? {
        didSet {
            if let rover = roverInfo,
                let sol = solDescription?.sol {
                DispatchQueue.main.async {
                    self.setUpForNewSol()
                }
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
    lazy private var cache = Cache<Int, Data>()
    
    lazy private var photoFetchQueue = OperationQueue()
    lazy private var photoFetchOps = [Int: FetchPhotoOperation]()
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var solDayLabel: UILabel!
    
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
    
    private func setUpForNewSol() {
        for (_, op) in photoFetchOps {
            op.cancel()
        }
        photoReferences = []
        cache = Cache<Int, Data>()
        solDayLabel.text = "Sol \(solDescription?.sol.description ?? "?")"
//        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
    }
    
    // MARK: - IB Actions
    
    @IBAction func previousButtonTapped(_ sender: UIButton) {
        changeSol(incrementing: false)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        changeSol(incrementing: true)
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
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // cancel fetch operation for cell at indexPath
        if !photoReferences.isEmpty {
            photoFetchOps[photoReferences[indexPath.item].id]?.cancel()
        }
    }
    
    // MARK: - Private Methods
    
    private func loadImage(forCell cell: ImageCollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let photoReference = photoReferences[indexPath.item]
        
        // check first if image is already cached
        if let imageData = cache[photoReference.id] {
            cell.imageView.image = UIImage(data: imageData)
            return
        }
        
        // otherwise, fetch the image
        let photoFetchOp = FetchPhotoOperation(photoReference)
        let storeImageToCacheOp = BlockOperation {
            guard let imageData = photoFetchOp.imageData else {
                return
            }
            self.cache[photoReference.id] = imageData
        }
        let checkCellReuseOp = BlockOperation {
            // if present, use cached image for cell & return
            if let imageData = self.cache[photoReference.id],
                let image = UIImage(data: imageData)
            {
                photoFetchOp.cancel()
                cell.imageView.image = image
            }
        }
        
        checkCellReuseOp.addDependency(storeImageToCacheOp)
        storeImageToCacheOp.addDependency(photoFetchOp)
        
        photoFetchQueue.addOperations([photoFetchOp, storeImageToCacheOp], waitUntilFinished: false)
        OperationQueue.main.addOperation(checkCellReuseOp)
        
        photoFetchOps[photoReference.id] = photoFetchOp
    }
    
    private func changeSol(incrementing: Bool) {
        let changeAmount: Int = incrementing ? 1 : -1
        
        guard let roverInfo = roverInfo
            else { return }
        
        solIndex += changeAmount
        if solIndex < 0 {
            solIndex = 0
        } else if solIndex >= roverInfo.solDescriptions.count {
            solIndex = roverInfo.solDescriptions.count - 1
        }
        
        print("new sol index: \(solIndex)")
        solDescription = roverInfo.solDescriptions[solIndex]
    }
}
