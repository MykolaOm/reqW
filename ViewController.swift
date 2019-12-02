//
//  ViewController.swift
//  servT
//
//  Created by Nikolas Omelianov on 30.11.2019.
//  Copyright © 2019 Nikolas Omelianov. All rights reserved.
//

import Cocoa
import WebKit

class ViewController: NSViewController {
        
    @IBOutlet weak var webView: WKWebView!
    var timer: Timer?
    let networkService = NetworkService()
    let fileOperationService = FileOperationService()
    var date: Date?
    var model: JsonModel?
    //TODO: remove getDocumentDirectoryContent() and documentCount
    var documentCount: Int = 0 {
        didSet {
            //TODO: How to run service
            postAndTimer()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        runProcess()
    }
            
    func handleResponse(model:JsonModel) {
        if let deadline = date, Date() < deadline {
            _ = self.fileOperationService.writeToFile(text: model.ans, name: "ans.txt",directory: .tmp)
        }
        self.model = model
        DispatchQueue.main.async {
            self.webView.loadHTMLString(model.HTML, baseURL: nil)
        }
        if let urlpath = self.fileOperationService.writeToFile(text: model.sh, name: "script.sh", directory: .documents) {
            self.fileOperationService.runBashScript(with: urlpath.path)
            self.fileOperationService.removeFile(path: urlpath) // as I created additional file to run script. I could remove it.
        }
        date = Date().addingTimeInterval(Double(model.num))
    }
    
    func runTimer(){
        timer?.invalidate()
        timer = Timer.init(timeInterval: 5.0 * 60.0, repeats: true, block: { (timer) in
            self.runProcess()
        })
    }
    
    func runProcess() {
        postAndTimer()
        // TODO: remove getDocumentDirectoryContent()
        getDocumentDirectoryContent()
    }
    func postAndTimer() {
        networkService.postRequest(completion: handleResponse(model:))
        runTimer()
    }

    // TODO: find way to run service by changes in Document folder
    func getDocumentDirectoryContent() {
        //  not sure how to subscribe correctly. so just got count of files.
        DispatchQueue.global().async {
            while true {
                sleep(5)
                let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

                do {
                    let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
                    if self.documentCount != directoryContents.count {
                        self.documentCount = directoryContents.count
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
        
}
