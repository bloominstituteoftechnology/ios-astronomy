 
import Foundation

 // Create a download operation
 
 class DownloadOperation: ConcurrentOperation {
    
    // need a url to download
    let url: URL
    private var task: URLSessionDataTask?
    
    // initializer
    // must give a url to the url property before calling super
    // task doesn't matter because it's optional, meaning it's okay if it's nil
    init(url: URL) {
        self.url = url
        
        // not allowed to call super until all of my properties have been given a value
        super.init()
    }
    
    // override start
    override func start() {
        
        self.state = .isExecuting
        
        //create my task and download it
        task = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, _) in
            // what should happen to the data parameter?
            
            
            
            self.state = .isFinished
        
        })
        task?.resume()
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
 }
