 
import Foundation

 // Create a download operation / FetchPhotoOperation
 
 class DownloadOperation: ConcurrentOperation {
    
    var marsPhotoReference: MarsPhotoReference
    var imageData: Data?
    
    // need a url to download
    let url: URL
    private var task: URLSessionDataTask?
    
    // initializer
    // must give a url to the url property before calling super
    // task doesn't matter because it's optional, meaning it's okay if it's nil
    init(url: URL, imageData: Data, marsPhotoReference: MarsPhotoReference) {
        self.url = url
        self.imageData = imageData
        self.marsPhotoReference = marsPhotoReference
        
        // not allowed to call super until all of my properties have been given a value
        super.init()
    }
    
    // override start
    override func start() {
        
        self.state = .isExecuting
        
        //create my task and download it
        task = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            // what should happen to the data parameter?
            
            if let error = error {
                NSLog("Error loading image: \(error)")
                return
            }
            
            guard let data = data else { return }
            
            // Set imageData with the received data
            self.imageData = data
            
            self.state = .isFinished
        
        })
        task?.resume()
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
 }
