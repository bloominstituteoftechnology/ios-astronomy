import Foundation

class DownloadOperation: ConcurrentOperation {
    
    let url: URL
    private var task: URLSessionDataTask?
    
    init(url: URL) {
        self.url = url
        super.init()
    }
    
    override func start() {
        self.state = .isExecuting
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
