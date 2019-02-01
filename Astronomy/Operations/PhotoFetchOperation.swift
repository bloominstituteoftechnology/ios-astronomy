import Foundation

class PhotoFetchOperation: ConcurrentOperation {
    
    var fetchedPhoto: MarsPhotoReference
    var imageData: Data? = nil
    private var dataTask: URLSessionDataTask?
    
    init(fetchedPhoto: MarsPhotoReference) {
        self.fetchedPhoto = fetchedPhoto
        super.init()
    }
    
    override func start() {
        super.start()
        state = .isExecuting
        guard let url = fetchedPhoto.imageURL.usingHTTPS else { return }
        
        dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            
            if let error = error {
                NSLog("Error fetching data task \(self.fetchedPhoto.id): \(error)")
                return
            }
            guard let data = data else {
                NSLog("Error with image data task")
                return
            }
            self.imageData = data
            defer { self.state = .isFinished}
        })
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
}



