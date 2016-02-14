//
//  ChatCollectionViewCell.swift
//  Chat
//
//  Created by Kobalt on 12.01.16.
//  Copyright © 2016 Kobalt. All rights reserved.
//

import UIKit

// Check System Version
let isIOS7: Bool = !isIOS8
let isIOS8: Bool = floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1

class ChatCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameNick: UILabel?
    @IBOutlet weak var textMess: UILabel?
    @IBOutlet weak var timeMess: UILabel!
    @IBOutlet weak var imageMess: UIImageView!
    let kLabelVerticalInsets: CGFloat = 8.0
    let kLabelHorizontalInsets: CGFloat = 8.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if isIOS7 {
            textMess!.translatesAutoresizingMaskIntoConstraints = false
            // Need set autoresizingMask to let contentView always occupy this view's bounds, key for iOS7
            self.contentView.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        }
        self.layer.masksToBounds = true
    }
        // In layoutSubViews, need set preferredMaxLayoutWidth for multiple lines label
    override func layoutSubviews() {
        super.layoutSubviews()
        textMess!.translatesAutoresizingMaskIntoConstraints = false
        // Set what preferredMaxLayoutWidth you want
        // textMess!.preferredMaxLayoutWidth = self.bounds.width - 2 * kLabelHorizontalInsets  
    }
    
    func configCell(nickname: String, updated_at: String, text: String) {
        nameNick?.text = nickname
        timeMess?.text = updated_at
        textMess?.text = text
        let shirina1 = CGFloat((textMess?.frame.size.width)!)
        let visota=heightForLabel(text, font: UIFont.systemFontOfSize(17), width: shirina1)
        let oldVisota=CGFloat((textMess?.frame.size.height)!)
        let raznicaVisot=self.contentView.frame.height+visota-oldVisota
        textMess?.frame = CGRect(x: 30, y: 81, width: shirina1, height: visota)
        // imageMess?.frame = CGRect(x: (imageMess?.frame.origin.x)!, y: (imageMess?.frame.origin.y)!, width: (imageMess?.frame.width)!, height: (visota+20))
        self.contentView.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: raznicaVisot)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    



    func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
}
