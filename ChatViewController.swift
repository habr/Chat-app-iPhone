//
//  ChatViewController.swift
//  Chat
//
//  Created by Kobalt on 12.01.16.
//  Copyright © 2016 Kobalt. All rights reserved.
//
import SwiftyJSON
import Alamofire
import UIKit


class ChatViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var collectionView: ZHDynamicCollectionView!
    @IBOutlet weak var messageText: UITextField!
    let identifier1 = "messageCell"
    let identifier2 = "messageCell2"
    let identifier3 = "messageCell3"
    let identifier4 = "messageCell4"
    let kHorizontalInsets: CGFloat = 10.0
    let kVerticalInsets: CGFloat = 10.0
    private var dataSource = [Message]()
    private var currentPage = 0
    private var currentPageNew = 0
    private var currentPageOld = 0
    private var pageIsLoading = false
    private var flagMyMessage = false
    private var flagImage = false
    var varNickForMyMess = 0
    var varForAPIEndMessages = [Param]()
    let transform = CGAffineTransformMake(1, 0, 0, -1, 0, 0)
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet var newWordField: UITextField?
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        toolBar.clipsToBounds = false
        toolBar.layer.borderWidth = 0.4
        toolBar.layer.borderColor = UIColor.grayColor().CGColor
        messageText.addRightLeftOnKeyboardWithTarget(self, leftButtonTitle:"Фото", rightButtonTitle:"Фото по ссылке", rightButtonAction:  Selector("funcFotoUrl"), leftButtonAction: Selector("funcFoto"), titleText: nil)
        // Register cells
        collectionView.dataSource = self
        collectionView.delegate = self
        let allCellNib = UINib(nibName: "ChatCollectionViewCell", bundle: nil)
        collectionView.registerNib(allCellNib, forCellWithReuseIdentifier: identifier1)
        let nibMyMess = UINib(nibName: "ChatMyMessageCell", bundle: nil)
        collectionView.registerNib(nibMyMess, forCellWithReuseIdentifier: identifier2)
        let myCellImgNib = UINib(nibName: "CellMyImage", bundle: nil)
        collectionView.registerNib(myCellImgNib, forCellWithReuseIdentifier: identifier3)
        let allCellImgNib = UINib(nibName: "CellGeneralImage", bundle: nil)
        collectionView.registerNib(allCellImgNib, forCellWithReuseIdentifier: identifier4)
        // получаем Id нашего юзера
        Messages.idForMyMessage (currentPage,
            success: {
                idNickForMyMessages in
                self.varNickForMyMess=idNickForMyMessages[0].idNikForMyMessage!
            }
        )
        messageText.delegate = self
        self.collectionView!.transform = transform
        takeTotalMessages()
    }
    
    func funcFoto() {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    
    @IBAction func buttonChange(sender: AnyObject) {

    }
    
    func funcFotoUrl() {
        let alertController = UIAlertController(title: "Введите url картинки", message: "для отправки", preferredStyle:UIAlertControllerStyle.Alert)
        alertController.view.setNeedsLayout()
        alertController.addTextFieldWithConfigurationHandler(addTextField)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
            { action -> Void in
              dispatch_async(dispatch_get_main_queue(), {
                self.proverkaImage()
              })
            })
        dispatch_async(dispatch_get_main_queue(), {
        self.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    func addTextField(textField: UITextField!){
        // add the text field and make the result global
        textField.placeholder = "http://example.ru/image.jpg"
        self.newWordField = textField

    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true;
        
    }

    func proverkaImage () {
        let imgURL: NSURL = NSURL(string: (newWordField?.text)!)!
        let imData: NSData = NSData(contentsOfURL: imgURL)!
        let imageViewForChekSize = UIImage(data: imData)
        let widthImage = imageViewForChekSize!.size.width
        let heightImage = imageViewForChekSize!.size.height
        let imStrParamUrl : String = imgURL.absoluteString
        if widthImage < 600 || heightImage < 600 || imData.length < 200000 {
            
            print("ok image")
             Messages.sendImageMessage(imStrParamUrl,
                success: {
                    sending in
                    print("takeTotalMessagesRigthNow()")
                    self.takeTotalMessagesRigthNow()
                    self.view.endEditing(true)
                }
                
            )
            
        } else {print("чтото не так с картинкой ")}
         view.endEditing(true)
    }
    
    @IBAction func buttonAction() {
        
        if messageText.text!.characters.count < 255 {
            if messageText.text! == "" {
                view.endEditing(true)
                return
            } else {
                Messages.sendMessage(self.messageText.text!,
                    success: {
                        sending in
                        print("takeTotalMessagesRigthNow()")
                        self.takeTotalMessagesRigthNow()
                        self.messageText.text=""
                        self.view.endEditing(true)
                    }
                )
            }
        } else {
            let alert = UIAlertController(title: "Ошибка", message:"Максимальная длинна текста 255 символов", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default) { _ in })
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(alert, animated: true, completion: nil)
            })
            
        }

    }
 
    func doneAction() { // called when 'return' key pressed. return NO to ignore.

        view.endEditing(true)
     //   return true
    }
    
    @IBAction func selectPhotoButtonTapped(sender: AnyObject) {
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(myPickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
    let image = (info[UIImagePickerControllerOriginalImage] as? UIImage)
    let widthImage = image!.size.width
    let heightImage = image!.size.height
    let imgData: NSData = UIImageJPEGRepresentation(image!, 0)!
        if widthImage < 600 || heightImage < 600 || imgData.length < 200000 {
            createMultipart(image!)
            let alert = UIAlertController(title: "Функция не реализована", message:"Т. к. описание API для загрузки картинки на сервер с устройства не дает представления о том какой параметр отвечает за получение данных. Но работает загрузка по ссылке(соседняя кнопка). Детали в логе", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default) { _ in })
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(alert, animated: true, completion: nil)
            })
        } else {
            let alert = UIAlertController(title: "Ошибка", message:"Картинка должна быть размером не более 600x600 и весом не более 200кб", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default) { _ in })
            dispatch_async(dispatch_get_main_queue(), {
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    self.dismissViewControllerAnimated(true, completion: nil)
    }

    func takeTotalMessages() {
        Messages.messagesStart (currentPage,
            success: {
                total_items_count in
                self.currentPage=total_items_count[0].total_items_count
                self.currentPageNew = self.currentPage
                self.currentPageOld = self.currentPage
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
    
    func takeTotalMessagesRigthNow() {
        Messages.messagesStart (currentPage,
            success: {
                total_items_count in
                if self.currentPageNew < total_items_count[0].total_items_count {
                    self.currentPageNew = total_items_count[0].total_items_count
                    self.pageIsLoading = false
                    self.loadMessagesUP()
                }
            },
            failure: {
                error in
                print(error)
                self.pageIsLoading = false
            }
        )
    }
    
    func loadMessages() {
        // print(self.currentPage)
        pageIsLoading = true
        if currentPage > 0 {
            Messages.messagesForPage(currentPage,
                success: {
                    messages in
                    self.addMessages(messages)
                    self.currentPage=self.currentPage-20
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
    
    func loadMessagesUP () {
        pageIsLoading = true
        if currentPageNew > currentPageOld  {
            let kolvo = currentPageNew - currentPageOld
            Messages.messagesNewAdd(currentPageNew, kolvo: kolvo,
                success: {
                    messages in
                    self.addMessagesUp(messages)
                    self.currentPageOld=self.currentPageOld + kolvo
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
    
    func addMessagesUp(messages: [Message]) {
        var indexPaths = [NSIndexPath]()
        // let oldSize = dataSource.count
        for i in 0..<messages.count {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            indexPaths.append(indexPath)
            dataSource.insert(messages[i], atIndex:i)
        }
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
        let message = self.dataSource[indexPath.row]
        let messIdNick = message.idnick
        //varNickForMyMess=398
        let letForDebugImageURL=message.image_url
        if letForDebugImageURL == " " {
            self.flagImage = false
        } else {
            self.flagImage = true
        }
        if varNickForMyMess == messIdNick { ////// Если User:ID мой то выводим identifier2
            self.flagMyMessage = true
        }   else    {
            self.flagMyMessage =  false
        }
        if flagMyMessage == true{
            if flagImage == true {
                // My Image
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier3, forIndexPath: indexPath) as! CellMyImage
                cell.transform=transform
                cell.imageMess.image = nil
                cell.configCell(message.updated_at as String, imageURL: NSURL(string: message.image_url as String)!)
                self.flagImage = false
                self.flagMyMessage =  false
                return cell
            }
            // My Message
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier2, forIndexPath: indexPath) as! ChatMyMessageCell
            cell.transform=transform
            let textM = message.text
            cell.configCell(message.nickname as String, updated_at: message.updated_at as String, text: textM! as String)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            flagMyMessage=false
            return cell
        } else {
            if flagImage == true {
                //General Image
                let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier4, forIndexPath: indexPath) as! CellGeneralImage
                cell.transform=transform
                cell.imageMess.image = nil
                cell.configCell(message.updated_at as String, imageURL: NSURL(string: message.image_url as String)!)
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                self.flagImage = false
                self.flagMyMessage =  false
                return cell
            }
            //General Message
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.identifier1, forIndexPath: indexPath) as! ChatCollectionViewCell
            cell.transform=self.transform
            // let message = self.dataSource[indexPath.row]
            let textM = message.text
            cell.configCell(message.nickname as String, updated_at: message.updated_at as String, text: textM! as String)
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // Set up desired width
        let targetWidth: CGFloat = self.collectionView!.bounds.width //////@IBOutlet weak var collectionView: ZHDynamicCollectionView!
        let message = dataSource[indexPath.row]
        // Use fake cell to calculate height
        let textM = message.text
        let messIdNick = message.idnick
        //varNickForMyMess=398
        let letForDebugImageURL=message.image_url
        if letForDebugImageURL == " " {
            self.flagImage = false
        } else {
            self.flagImage = true
        }
        if varNickForMyMess == messIdNick {
            self.flagMyMessage = true
        }   else    {
            self.flagMyMessage =  false
        }

        if flagMyMessage == true{
            if flagImage == true {
                let cell: CellMyImage = self.collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(identifier3) as! CellMyImage
                cell.configCell(message.updated_at as String, imageURL: NSURL(string: message.image_url as String)!)
                flagImage=false
                flagMyMessage=false
                cell.bounds = CGRectMake(0, 0, targetWidth, cell.bounds.height)
                cell.contentView.bounds = cell.bounds
                // print(cell.contentView.bounds)
                // Layout subviews, this will let labels on this cell to set preferredMaxLayoutWidth
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                var size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                // Still need to force the width, since width can be smalled due to break mode of labels
                size.width = targetWidth-20
                // print(size)
                return size
            }
            let cell: ChatMyMessageCell = self.collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(identifier2) as! ChatMyMessageCell
            cell.configCell(message.nickname as String, updated_at: message.updated_at as String, text: textM! as String)
            flagMyMessage=false
            cell.bounds = CGRectMake(0, 0, targetWidth, cell.bounds.height)
            cell.contentView.bounds = cell.bounds
            // print(cell.contentView.bounds)
            // Layout subviews, this will let labels on this cell to set preferredMaxLayoutWidth
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            var size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            // Still need to force the width, since width can be smalled due to break mode of labels
            size.width = targetWidth-20
          //   print("my: \(size)")
            return size
        } else {
            if flagImage == true {
                let cell: CellGeneralImage = self.collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(identifier4) as! CellGeneralImage
                cell.configCell(message.updated_at as String, imageURL: NSURL(string: message.image_url as String)!)
                flagImage=false
                flagMyMessage=false
                cell.bounds = CGRectMake(0, 0, targetWidth, cell.bounds.height)
                cell.contentView.bounds = cell.bounds
                // print(cell.contentView.bounds)
                // Layout subviews, this will let labels on this cell to set preferredMaxLayoutWidth
                cell.setNeedsLayout()
                cell.layoutIfNeeded()
                var size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                // Still need to force the width, since width can be smalled due to break mode of labels
                size.width = targetWidth-20
                // print(size)
                return size
            }
            
            let cell: ChatCollectionViewCell = self.collectionView.dequeueReusableOffScreenCellWithReuseIdentifier(identifier1) as! ChatCollectionViewCell
            // Config cell and let system determine size
            cell.configCell(message.nickname as String, updated_at: message.updated_at as String, text: textM! as String)
            cell.bounds = CGRectMake(0, 0, targetWidth, cell.bounds.height)
            cell.contentView.bounds = cell.bounds
            // print(cell.contentView.bounds)
            // Layout subviews, this will let labels on this cell to set preferredMaxLayoutWidth
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            var size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            // Still need to force the width, since width can be smalled due to break mode of labels
            size.width = targetWidth-20
            //print("all: \(size)")
            return size
        }
        // Cell's size is determined in nib file, need to set it's width (in this case), and inside, use this cell's width to set label's preferredMaxLayoutWidth, thus, height can be determined, this size will be returned for real cell initialization
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
    
        // print(pathPersents)
        if pathPersents >= 0.8 {
            loadMessages()
        }
        if pathPersents <= 0.22 {
            takeTotalMessagesRigthNow()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    func createMultipart(image: UIImage){
        let imageData = UIImagePNGRepresentation(image)
        let base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        let imageasd = ["image": base64String]
        let parameters = ["session": "5694cde0-d2dc-4cc4-b2d5-7506ac1f0216", "image": base64String]
        Alamofire.request(.POST, "http://52.192.101.131/image", parameters: parameters, encoding: .JSON)
            .responseJSON {
                response in switch response.result{
                case .Success(let JSON):
                    print("id JSON: \(JSON)")
                    print("parameters: \(parameters)")
                    print("response: \(response)")
                
                case .Failure(let error):print("Error: \(error)")
                }
            }
       }

}
