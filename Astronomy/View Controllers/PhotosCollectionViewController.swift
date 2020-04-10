//
//  PhotosCollectionViewController.swift
//  Astronomy
//
//  Created by Andrew R Madsen on 9/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum NetworkError: Error {
    case noAuth
    case badAuth
    case otherNetworkError
    case badData
    case noDecode
    case badUrl
}

class PhotosCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    // MARK: - Properties
    private var imageCache = Cache<Int, UIImage>()
    private let photoFetchQueue = OperationQueue()
    private var fetchOperations: [Int: FetchPhotoOperation] = [:]
    
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
    
    // MARK: - Outlets

    @IBOutlet var collectionView: UICollectionView!

    // MARK: - Functions

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
        
        // Cache the indexPath for fetchImage completion to know whether cell has moved
        cell.originalIndexPath = indexPath
        let cachedIndexPath = cell.originalIndexPath
        
        // Which photo information do we need to load?
        let photoReference = photoReferences[cachedIndexPath.item]

        // Is the image cached? ... avoiding a network lookup.
        if let image = imageCache.value(for: cachedIndexPath.item) {
            print("Cached Image: \(cachedIndexPath.item)")
            cell.imageView.image = image
            return
        }
        
        // Don't have image. Need to retrieve it.
        // ---- Operation to grab photo ---------------------------
        let fetchPhotoOp = FetchPhotoOperation(marsPhotoReference: photoReference)
        fetchOperations[photoReference.id] = fetchPhotoOp
        
        // ---- Operation to cache photo --------------------------
        let cachePhotoOp = BlockOperation {
            if let image = fetchPhotoOp.imageData {
                // TODO: Is this tread safe? Yes?
                self.imageCache.cache(value: image, for: cachedIndexPath.item)
            }
        }
        
        // ---- Operation to place photo in cell ------------------
        let setImageOp = BlockOperation {
            if cachedIndexPath != cell.originalIndexPath {
                // Cell was reused before image finished loading
                // print("\(cachedIndexPath) != \(cell.indexPath)")
                return
            }
                
            if let image = fetchPhotoOp.imageData {
                DispatchQueue.main.async {
                    cell.imageView.image = image
                }
            }
        }
        
        cachePhotoOp.addDependency(fetchPhotoOp)
        setImageOp.addDependency(fetchPhotoOp)
        
        photoFetchQueue.addOperations([fetchPhotoOp, cachePhotoOp, setImageOp], waitUntilFinished: false)
    }

    /// Fetch an image from the Internet via a URL
    /// - Parameters:
    ///   - imageUrl: A secure URL to the image you want to load
    ///   - completion: What do you want done with the downloaded image?
    private func fetchImage(of imageUrl: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        
        var request = URLRequest(url: imageUrl)
        request.httpMethod = HTTPMethod.get.rawValue
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("Error receiving mars image data: \(error)")
                completion(.failure(.otherNetworkError))
                return
            }
            
            guard let data = data else {
                NSLog("nasa.gov responded with no image data.")
                completion(.failure(.badData))
                return
            }
            
            guard let image = UIImage(data: data) else {
                NSLog("Image data is incomplete or corrupt.")
                completion(.failure(.badData))
                return
            }

            completion(.success(image))

        }.resume()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        // What photo were we trying to load
        let photoReference = photoReferences[indexPath.item]

        if let fetchPhotoOperation = fetchOperations[photoReference.id] {
            // A photo is trying to be loaded.
            fetchPhotoOperation.cancel()
        }
    }
}
