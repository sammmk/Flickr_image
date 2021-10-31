//
//  ImageCollectionViewController.swift
//  Flickr_image
//
//  Created by Mohan Kurera on 2021/10/28.
//

import UIKit

private let reuseIdentifier = "Cell"

class ImageCollectionViewController: UICollectionViewController, XMLParserDelegate {

    let address = "https://www.flickr.com/services/feeds/photos_public.gne"
    
    var pictureInfo = [Flickr]()
    var singleData = Flickr()
    var detailData = Content()
    var check_element = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // show loading view until images downloaded
        let loadingVC = LoadingViewController()
        loadingVC.modalPresentationStyle = .overCurrentContext
        loadingVC.modalTransitionStyle = .crossDissolve
        present(loadingVC, animated: true, completion: nil)
        
        // call to API & get image data from public feed
        GetFlickrData() { data in
            let parser: XMLParser? = XMLParser(data: data)
            parser?.delegate = self
            parser?.parse()
            print(self.pictureInfo)
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.collectionView.performBatchUpdates(nil, completion: { result in
                    // dismiss loading view
                    if let TopVC = UIApplication.shared.topMostViewController() {
                        if TopVC.isKind(of: LoadingViewController.self) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                })
            }
        }
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
    }
    
    ///  show image detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPaths = collectionView.indexPathsForSelectedItems {
                let destinationController = segue.destination as! ImageDetailViewController
                destinationController.flickr = pictureInfo[indexPaths[0].row]
                collectionView.deselectItem(at: indexPaths[0], animated: false)
            }
        }
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue){
            
    }
    
    ///  Get image data
    func GetFlickrData(completion: @escaping (Data) -> Void) {

        let requestURL = URL(string: address)

        URLSession.shared.dataTask(with: requestURL!) { (data, response, error) -> Void in

            if let error = error {
                print("Error: \(String(describing: error))")
                return
            }
            else if let response = response as? HTTPURLResponse,
            let data = data {
                print(response.statusCode)
                //let XMLStr = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                //print(XMLStr)
                return completion(data)
            }
            
        }.resume()
        
    }
    
    func stringToDate(str: String?) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        if let date = str {
            return dateFormatter.date(from: date)
        }
        return nil
    }
    
    // MARK: XPL Parser Delegates
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "link" {
            if let type = attributeDict["type"] {
                if type == "image/jpeg" {
                    let url = attributeDict["href"]!
                    // filter only images (.jpg)
                    if url.contains(".jpg") {
                        singleData.imageUrl = url
                    }
                }
            }
        }
        check_element = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if string.range(of: "\n") == nil {
            if check_element == "title" {
                singleData.imageTitle = string
            }
            else if check_element == "name" {
                detailData.author_name = string
            }
            else if check_element == "published" {
                detailData.publishDate = stringToDate(str: string)
            }
            else if check_element == "flickr:date_taken" {
                detailData.dateTaken = stringToDate(str: string)
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if check_element == "displaycategories" && !singleData.imageUrl.isEmpty {
            singleData.details = detailData
            pictureInfo.append(singleData)
            detailData.reset()
            singleData.reset()
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
       // print("End Doc \(pictureInfo)")
    }
    
    // MARK: UICollectionView

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return pictureInfo.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
    
        if pictureInfo.count > 0 {
            let image = pictureInfo[indexPath.row]
            let url = URL(string: image.imageUrl)
            do {
                let data = try Data(contentsOf: url!)
                cell.flickrImageView.image = UIImage(data: data)
            } catch {
                print(error)
            }
            cell.imageName.text = image.imageTitle
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: nil)
    }

}

// MARK: Extensions

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if self.presentedViewController == nil {
            return self
        }
        if let navigation = self.presentedViewController as? UINavigationController {
            return navigation.visibleViewController!.topMostViewController()
        }
        if let tab = self.presentedViewController as? UITabBarController {
            if let selectedTab = tab.selectedViewController {
                return selectedTab.topMostViewController()
            }
            return tab.topMostViewController()
        }
        return self.presentedViewController!.topMostViewController()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return UIWindow.key!.rootViewController?.topMostViewController()
    }
}

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
