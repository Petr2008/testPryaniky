//
//  ViewController.swift
//  testPryaniky
//
//  Created by Petr Gusakov on 14.10.2020.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, URLSessionDelegate, URLSessionDownloadDelegate {

    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var tableView: UITableView!
    
    let serverName = "https://pryaniky.com/static/json/sample.json"
    var pryaniky: Pryaniky?
    var viewList = [String]()
    
    var pathCaches: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cachesDirectory = FileManager.SearchPathDirectory.cachesDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        self.pathCaches = NSSearchPathForDirectoriesInDomains(cachesDirectory, nsUserDomainMask, true).first!
    }

    // MARK: - IBAction
    @IBAction func loadDataFromServer(_ sender: Any) {

        self.progressView.progress = 0
        
        let requestURL = URL(string: serverName)!
        let urlRequest = URLRequest(url: requestURL)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        
        let downloads = session.downloadTask(with: urlRequest)
        
        downloads.resume()
    }

    // MARK: - loadImageFromServer
    func loadImageFromServer(indexPath: IndexPath, path: String) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.configuration.timeoutIntervalForRequest = 50
        
        let requestStr = path
        let url = URL(string: requestStr)
        
        let task = session.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                let name = URL(string: requestStr)?.lastPathComponent
                let imageURL = URL(fileURLWithPath: self.pathCaches).appendingPathComponent(name!)
                do {
                    try data!.write(to: imageURL)
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                } catch {
                    print(error.localizedDescription as Any)
                }
            }
        }
        task.resume()

    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = viewList[indexPath.row]
        let datum = self.pryaniky?.data!.first(where: {$0.name == key})
        
        self.title = datum?.name

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Text", for: indexPath)
        let key = viewList[indexPath.row]
        let datum = self.pryaniky?.data!.first(where: {$0.name == key})
        
        switch key {
        case "hz":
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = datum?.data.text
        case "picture":
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath) as! PictureCell
            cell.label.text = datum?.data.text
            //cell.detailTextLabel?.text = datum?.data.url
            let name = URL(string: (datum?.data.url)!)?.lastPathComponent
            let imageURL = URL(fileURLWithPath: self.pathCaches).appendingPathComponent(name!)
            
            if FileManager.default.fileExists(atPath: imageURL.path) {
                let data = try! Data(contentsOf: imageURL)
                cell.iView.image = UIImage(data: data)
                cell.activityIndicatorView.stopAnimating()
            } else {
                loadImageFromServer(indexPath: indexPath, path: (datum?.data.url)!)
                cell.activityIndicatorView.startAnimating()
            }
            
            return cell
        case "selector":
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "Selector", for: indexPath) as! SelectorCell
            let selectedId = datum?.data.selectedId!
            let variants: [Variant]! = datum?.data.variants
            let finalWord = NSMutableAttributedString(string: "")

            for index in 0..<variants.count {
                let variant = variants[index]
                let endStr = NSAttributedString(string: "\n", attributes: nil)
                if variant.id == selectedId {
                    let word = NSAttributedString(string: variant.text,
                                                  attributes: [
                                                    .font: UIFont.boldSystemFont(ofSize: UIFont.systemFontSize),
                                                    .foregroundColor: UIColor.red
                                                 ])
                    finalWord.append(word)
                } else {
                    let word = NSAttributedString(string: variant.text,
                                                  attributes: [
                                                    .font: UIFont.systemFont(ofSize: UIFont.systemFontSize)//,
                                                    //.foregroundColor: UIColor.blue
                                                    ])
                    finalWord.append(word)
                }
                if index + 1 != variants.count {
                    finalWord.append(endStr)
                }
            }
            //cell.textView.attributedText = finalWord
            cell.label.attributedText = finalWord
            return cell
        default:
            cell.textLabel?.text = key
        }
        return cell
    }
    
    // MARK: - URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL){
        let data = try? Data(contentsOf: location)
        print("download finished! - \(location)")
        if data != nil {
            createContent(data: data!)
            DispatchQueue.main.async {
                self.progressView.progress = 1.0
                self.title = ""
            }
        } else {
            print("error save from \(location)")
            return
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = totalBytesWritten / totalBytesExpectedToWrite
        //print(progress)

        DispatchQueue.main.async {
            self.progressView.progress = Float(progress)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print("error load data - \(String(describing: error?.localizedDescription))")
        }
    }
    
    // MARK: - Create Content
    func createContent(data: Data) {print("createContent")
        //let str = String(data: data, encoding: .utf8)
        self.pryaniky = try? newJSONDecoder().decode(Pryaniky.self, from: data)
        if self.pryaniky != nil {
            self.viewList = (self.pryaniky?.view)!
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

//        print(pryaniky as Any)
    }

    func newJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            encoder.dateEncodingStrategy = .iso8601
        }
        return encoder
    }

    func newJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
            decoder.dateDecodingStrategy = .iso8601
        }
        return decoder
    }

}

