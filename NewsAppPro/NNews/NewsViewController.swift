import Foundation
import UIKit
import WebKit

class NewsViewController: UIViewController{
    var contentUrl: String?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        loadWeb(path: thisUrl )
    }
    
    func loadWeb(path: String){
        let url=URL(string: path)
        let request=URLRequest(url:url!)
        webView?.load(request)
    }
    
    @IBOutlet weak var webView: WKWebView!
    @IBAction func bkItem(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

