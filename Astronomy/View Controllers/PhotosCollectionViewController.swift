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
    
    //MARK: - Properties
    let cache = Cache<Int, Data>()
    
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
        
        //TODO: Check if the current index path for cell is the same one you were asked to load
        
        
        let photoReference = photoReferences[indexPath.item]
        
        //Unwrap URL
        guard let url = photoReference.imageURL.usingHTTPS else {
            print("Bad URL in Load Image")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        //Image isn't stored in the Cache
        if cache.value(for: photoReference.id) == nil {
            // Load in Image
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                
                //Check for error's
                if let error = error {
                    print("Error with URL in loadImage: \(error)")
                    return
                }
                
                //Unwrap Data
                guard let tempData = data else {
                    print("Bad Data in Load Image")
                    return
                }
                
                //Go Back to the main thread and assign the image to the cell imageView.image
                DispatchQueue.main.async {
                    
                    //Store Data in Cache
                    let photoReference = self.photoReferences[indexPath.item]
                    self.cache.cache(value: tempData, for: photoReference.id)
                    
                    let currentIndex = self.collectionView.indexPath(for: cell)
                    if currentIndex == indexPath {
                        let image = UIImage(data: tempData)
                        cell.imageView.image = image
                    } else {
                        return
                    }
                }
                
            }.resume()
        } else {
            //Assign Cached Image
            let imageData = cache.value(for: photoReference.id)
            guard let tempData = imageData else {
                print("Error Image Data was nil")
                return
            }
            
            let image = UIImage(data: tempData)
            cell.imageView.image = image
        }
        
    }
    
    //Check if the current index path for cell is the same one you were asked to load
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
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
            DispatchQueue.main.async { self.collectionView?.reloadData() }
        }
    }
    
    @IBOutlet var collectionView: UICollectionView!
}
