//
//  ChatViewController.swift
//  Chat
//
//  Created by Kobalt on 12.01.16.
//  Copyright © 2016 Kobalt. All rights reserved.
//

import Alamofire
import UIKit



class ChatViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    @IBOutlet weak var collectionView: ZHDynamicCollectionView!
    @IBOutlet weak var messageText: UITextField!
    let reuseIdentifier = "messageCell"
    
    let kHorizontalInsets: CGFloat = 10.0
    let kVerticalInsets: CGFloat = 10.0
 //   var sizeCellY = CGFloat(0.0)
   // var odlCellY = CGFloat(0.0)
    private var dataSource = [Message]()
    private var currentPage = 0
    private var pageIsLoading = false
    //private var cellSizeChange = false
  //  private var checkY = false
    var varForAPIEndMessages = [Param]()
//    let transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0)

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
   /*
        Alamofire.request(.GET, "http://httpbin.org/get", parameters: ["foo": "bar"])
            .responseJSON { response in
                debugPrint(response)     // prints detailed description of all response properties
                
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
        }
        
        */
        // Register cells
        collectionView.dataSource = self
        collectionView.delegate = self
        let myCellNib = UINib(nibName: "ChatCollectionViewCell", bundle: nil)
        collectionView.registerNib(myCellNib, forCellWithReuseIdentifier: reuseIdentifier)
        Messages.messagesSend()
        messageText.delegate = self
//        self.collectionView!.transform = transform
        takeTotalMessages()
        

        
    }
 
    
    
    @IBAction func buttonAction() {
        view.endEditing(true)
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        view.endEditing(true)
        return true;
    }



    func takeTotalMessages() {
   
        Messages.messagesStart (currentPage,
            success: {
                total_items_count in
                self.currentPage=total_items_count[0].total_items_count
                self.pageIsLoading = false
                self.loadMessages()
            },
            failure: {
                error in
                print(error)
                self.pageIsLoading = false
            }
        )
        
    }
    
    func loadMessages() {
        print(self.currentPage)
        pageIsLoading = true
        if currentPage > 0 {
        Messages.messagesForPage(currentPage,
                    success: {
                        messages in
                        self.addMessages(messages)
                        self.currentPage=self.currentPage-5
                        self.pageIsLoading = false
            },
                    failure: {
                        error in
                        print(error)
                        self.pageIsLoading = false
                    }
                )
        }
    
    }
    
    func addMessages(messages: [Message]) {
        var indexPaths = [NSIndexPath]()
        let oldSize = dataSource.count
        for i in 0..<messages.count {
            let indexPath = NSIndexPath(forRow: oldSize + i, inSection: 0)
            indexPaths.append(indexPath)
        }
        dataSource.appendContentsOf(messages)
         collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
        

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ChatCollectionViewCell
      //  print(cell)
   //     cell.transform=transform
        let message = dataSource[indexPath.row]
        var textM = message.text
        if textM == nil
        {
            textM  = " "
        }
        cell.configCell(message.nickname as String, updated_at: message.updated_at as String, text: textM! as String)
        

        
      /*
        cell.nameNick?.text = message.nickname
        cell.timeMess?.text = message.updated_at
        cell.textMess?.text = message.text
        */
        /*
        var text = message.text
        if text == nil
            {
                cell.textMess?.text = " "
                text  = " "
            }*/
  /*      if cellSizeChange == true
            {
                cell.frame.origin.y=sizeCellY
                odlCellY=sizeCellY
            //    cellSizeChange = false
    //            checkY=true
            }
        
  /*      if checkY==true
            {
                odlCellY
            }*/
        
        //    print(cell.textMess?.frame.size.width)
    //    let shirina1 = CGFloat((cell.textMess?.frame.size.width)!)
        
        let visota=heightForLabel(text!, font: UIFont.systemFontOfSize(17), width: shirina1)
        
        
        cell.imageMess?.frame = CGRect(x: 0, y:61, width: shirina1+40, height: visota+40)
        
        // сюда нужно положить высоту
        cell.textMess?.frame = CGRect(x: 30, y: 81, width: shirina1, height: visota)
        
        

        
        /*
        if let imageURL = movie.posterURL
            where cell.posterImageView?.setCachedImageForURL(imageURL) == false {
                ImageDownloader.downloadImageWithURL(imageURL, forIndexPath: indexPath)
        }*/
     
        if visota > 21
        {
            let visotaCell = CGFloat((cell.frame.size.height))
            cell.frame.size.height=visotaCell+visota-20.0
        
            sizeCellY = cell.frame.origin.y+visotaCell+visota-10.0 //значение предидущей высоты ячейки + Y
            cellSizeChange = true
        }else{
            let visotaCell = CGFloat((cell.frame.size.height))
            sizeCellY = cell.frame.origin.y+visotaCell+visota-10.0
        }
        

        
  //      sizeCellY = cell.frame.origin.y+CGFloat((cell.frame.size.height))+visota-10.0
        print(cell.textMess?.text)
        print(cell)
        */
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // Set up desired width
        let targetWidth: CGFloat = self.collectionView!.bounds.width
        let message = dataSource[indexPath.row]
        // Use fake cell to calculate height
        var textM = message.text
        if textM == nil
        {
            textM  = " "
        }
        //var cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ChatCollectionViewCell
       
        var cell: ChatCollectionViewCell = self.collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(reuseIdentifier) as! ChatCollectionViewCell
        // Config cell and let system determine size
        cell.configCell(message.nickname as String, updated_at: message.updated_at as String, text: textM! as String)
        
        // Cell's size is determined in nib file, need to set it's width (in this case), and inside, use this cell's width to set label's preferredMaxLayoutWidth, thus, height can be determined, this size will be returned for real cell initialization
        cell.bounds = CGRectMake(0, 0, targetWidth, cell.bounds.height)
        cell.contentView.bounds = cell.bounds
        print(cell.bounds)
        // Layout subviews, this will let labels on this cell to set preferredMaxLayoutWidth
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        var size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        // Still need to force the width, since width can be smalled due to break mode of labels
        size.width = targetWidth
        print(size)
        return size
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(kVerticalInsets, kHorizontalInsets, kVerticalInsets, kHorizontalInsets)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return kHorizontalInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return kVerticalInsets
    }
    
    // MARK: - Rotation
    // iOS7
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // iOS8
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
 
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
       
        guard let collectionView = self.collectionView else {
            return
        }
        guard pageIsLoading == false else {
            return
        }
        
        let currentBottonPosition = collectionView.contentOffset.y + collectionView.bounds.height
        let contentHeight = collectionView.contentSize.height
        
        let pathPersents = currentBottonPosition / contentHeight
        if pathPersents >= 0.8 {
           // if currentPage > 0{
            loadMessages()
          //  }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}