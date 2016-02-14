//
//  CellMyImage.swift
//  Chat
//
//  Created by Kobalt on 04.02.16.
//  Copyright © 2016 Alamofire. All rights reserved.
//
import Alamofire
import UIKit


class CellMyImage: UICollectionViewCell {
    
    @IBOutlet weak var timeMess: UILabel!
    @IBOutlet weak var imageMess: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    func configCell(updated_at: String, imageURL: NSURL)  {
        timeMess?.text = updated_at
        indicator.startAnimating()
    
        Alamofire.request(.GET, imageURL).response() {
            (_, _, data, _) in dispatch_async(dispatch_get_main_queue()) {
            if self.imageMess.image == nil {
            let image = UIImage(data: data!)
            self.imageMess.image = image
            self.indicator.stopAnimating()
                }}}
    }
}

