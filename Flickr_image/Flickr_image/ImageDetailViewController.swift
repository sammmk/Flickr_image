//
//  ImageDetailViewController.swift
//  Flickr_image
//
//  Created by Mohan Kurera on 2021/10/28.
//

import Foundation
import UIKit

class ImageDetailViewController: UIViewController {
    
    var flickr: Flickr?
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var imageTitle: UILabel!
    @IBOutlet weak var detailView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable keyboard
        detailView.isEditable = false
        
        let url = URL(string: flickr?.imageUrl ?? "")
        do {
            let data = try Data(contentsOf: url!)
            mainImage.image = UIImage(data: data)
        } catch {
            print(error)
        }
        imageTitle.text = flickr?.imageTitle
        var str = ""
        if let author = flickr?.details?.author_name {
            str += "Author : " + author + "\n"
        }
        if let publish = flickr?.details?.publishDate {
            str += "Published : " + dateToString(date: publish) + "\n"
        }
        if let taken = flickr?.details?.dateTaken {
            str += "Taken : " + dateToString(date: taken) + "\n"
        }
        
        detailView.text = str
    }
    
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        
        return dateFormatter.string(from: date)
    }
}

extension DateFormatter {
    public enum Style : UInt {
        case none = 0
        case short = 1
        case medium = 2
        case long = 3
        case full = 4
    }
}
