import TinyConstraints
import UIKit
import WebKit

final class SimpleWebViewController: UIViewController {
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        return webView
    }()
    
    private(set) var url: URL
    
    var changeTitleWithPage = false
    
    init(_ url: URL, title: String? = nil) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
        if let title = title {
            self.title = title
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        view.addSubview(webView)
        renderLayout()
        let request = URLRequest(url: url)
        webView.load(request)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
    }
    
    func renderLayout() {
        webView.edgesToSuperview(usingSafeArea: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" && changeTitleWithPage {
            if let title = webView.title {
                self.title = title
            }
        }
    }
}



