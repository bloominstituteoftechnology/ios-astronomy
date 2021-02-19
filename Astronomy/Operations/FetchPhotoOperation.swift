import Foundation

class FetchPhotoOperation: ConcurrentOperation {
    
    let url: URL
    let reference: MarsPhotoReference
    var imageData: Data?
    private var task: URLSessionDataTask?
    
    init(reference: MarsPhotoReference) {
        self.reference = reference
        self.url = reference.imageURL.usingHTTPS!
        super.init()
    }
    
    override func start() {
        self.state = .isExecuting
        task = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            //unwrap the data
            guard error == nil, let data = data else {
                if let error = error {
                    NSLog("Error unwarapping data: \(error)")
                    return
                }
                NSLog("Unable to fetch data")
                return
            }
            //test
            print("no error and have data: \(data)")
            
            self.imageData = data
            
            defer{
            self.state = .isFinished
            }
        })
        task?.resume()
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
}
