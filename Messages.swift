//
//  AppDelegate.swift
//  Chat
//
//  Created by Kobalt on 12.01.16.
//  Copyright © 2016 Kobalt. All rights reserved.
//

import Alamofire
import Foundation


class Messages {
    typealias Success = ([Message]) -> ()
    typealias Success2 = ([Param]) -> ()
    typealias Success3 = ([structParam2]) -> ()
    typealias Success4 = ([structParam3]) -> ()
    private var messIsLoading = false
    private var asd:Int = 0
    static func messagesForPage(page: Int, success: Success, failure: Session.Failure) {
        let parameters = [
            "paging_size=20&oldest_message_id": String(page)
        ]
                print(parameters)
        Session.instance.GET("messages", parameters: parameters,
            success: {
                data in
                guard let actualData = data else {
                    return
                }
                do {
                    let JSON = try NSJSONSerialization.JSONObjectWithData(actualData, options: [.AllowFragments])
                    let results = JSON["messages"] as? [AnyObject]
                    guard let actualResults = results else {
                        return
                    }
                    var messages = [Message]()
                    for rawMessage in actualResults {
                        let mess = rawMessage["Message"] as! NSDictionary
                        var mes = mess["text"] as? NSString ?? " "
                        if mes == "" {mes=" "}
                        let idmes = (mess["id"] as! NSString).integerValue
                        let imgmes = mess["image_url"] as? NSString ?? " "
                        let dateAsString = mess["updated_at"] as! NSString
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date = dateFormatter.dateFromString(dateAsString as String)
                        dateFormatter.dateFormat = "h:mm a"
                        let timemes = dateFormatter.stringFromDate(date!)
                        let users = rawMessage["User"] as! NSDictionary
                        let idname = (users["id"] as! NSString).integerValue
                        let nickname = users["nickname"] as! NSString
                        let ava = users["avatar_image"] as? NSURL
                        let message = Message(id: idmes, updated_at:timemes as String, image_url:imgmes, text: mes as String, idnick: idname, nickname:nickname as String, avatar_image:ava)
                        messages.append(message)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        success(messages)
                    }
                } catch {
                    print(error)
                    dispatch_async(dispatch_get_main_queue()) {
                        failure(error)
                    }
                }
            },
            failure: {
                error in
                print(error)
                dispatch_async(dispatch_get_main_queue()) {
                    failure(error)
                }
            }
        )
    }
    
    static func messagesNewAdd(page: Int, kolvo: Int, success: Success, failure: Session.Failure) {
        let parameters = [
            "paging_size=\(kolvo)&oldest_message_id": String(page)
        ]
    
        print(parameters)
        Session.instance.GET("messages", parameters: parameters,
            success: {
                data in
                guard let actualData = data else {
                    return
                }
                do {
                    let JSON = try NSJSONSerialization.JSONObjectWithData(actualData, options: [.AllowFragments])
                    let results = JSON["messages"] as? [AnyObject]
                    guard let actualResults = results else {
                        return
                    }
                    var messages = [Message]()
                    for rawMessage in actualResults {
                        let mess = rawMessage["Message"] as! NSDictionary
                        var mes = mess["text"] as? NSString ?? " "
                        if mes == "" {mes=" "}
                        let idmes = (mess["id"] as! NSString).integerValue
                        let imgmes = mess["image_url"] as? NSString ?? " "
                        let dateAsString = mess["updated_at"] as! NSString
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date = dateFormatter.dateFromString(dateAsString as String)
                        dateFormatter.dateFormat = "h:mm a"
                        let timemes = dateFormatter.stringFromDate(date!)
                        let users = rawMessage["User"] as! NSDictionary
                        let idname = (users["id"] as! NSString).integerValue
                        let nickname = users["nickname"] as! NSString
                        let ava = users["avatar_image"] as? NSURL
                        let message = Message(id: idmes, updated_at:timemes as String, image_url:imgmes, text: mes as String, idnick: idname, nickname:nickname as String, avatar_image:ava)
                        messages.append(message)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        success(messages)
                    }
                } catch {
                    print(error)
                    dispatch_async(dispatch_get_main_queue()) {
                        failure(error)
                    }
                }
            },
            failure: {
                error in
                print(error)
                dispatch_async(dispatch_get_main_queue()) {
                    failure(error)
                }
            }
        )
    }

    static func messagesStart(page: Int, success: Success2, failure: Session.Failure) {
        let parameters = [
            "paging_size=20&oldest_message_id": String(page)
        ]
        Session.instance.GET("messages", parameters: parameters,
            success: {
                data in
                guard let actualData = data else {
                    return
                }
                do {
                    let JSON = try NSJSONSerialization.JSONObjectWithData(actualData, options: [.AllowFragments])
                    let totalItemsCount = Param(total_items_count: ((JSON["total_items_count"] as! NSString).integerValue + 2))
                    var totalItemParam = [Param]()
                    totalItemParam.append(totalItemsCount)
                    dispatch_async(dispatch_get_main_queue()) {
                        success(totalItemParam)
                    }
                } catch {
                    print(error)
                    dispatch_async(dispatch_get_main_queue()) {
                        failure(error)
                    }
                }
            },
            failure: {
                error in
                print(error)
                dispatch_async(dispatch_get_main_queue()) {
                    failure(error)
                }
            }
        )
        }

    static func messagesSend(/*textMess: String, urlImage: String, success: Success2, failure: Session.Failure*/) {

    }
    
    static func idForMyMessage(page: Int, success: Success3)  {
        let parameters = ["session": "5694cde0-d2dc-4cc4-b2d5-7506ac1f0216"]
        var idNickForMyMessages=[structParam2]()
        Alamofire.request(.POST, "http://52.192.101.131/session", parameters: parameters, encoding: .JSON)
            .responseJSON {
                response in switch response.result{
                    case .Success(let JSON):
                   //     print("id JSON: \(JSON)")
                        let response = JSON["User"] as! NSDictionary
                        let idname = (response["id"] as! NSString).integerValue
                        let idNickForMyMessage=structParam2(idNikForMyMessage: idname)
                        idNickForMyMessages.append(idNickForMyMessage)

                     //   print("response: \(response)")
 
                        dispatch_async(dispatch_get_main_queue()) {
                            success(idNickForMyMessages)
                        }
                    case .Failure(let error):print("Error: \(error)")
                }
            }
    }
    
    static func sendImageMessage(urlImage: String, success: Success4)  {
        
        let image = ["image_url": urlImage]
        let parameters = ["session": "5694cde0-d2dc-4cc4-b2d5-7506ac1f0216", "message": image]
        var sending=[structParam3]()
        Alamofire.request(.POST, "http://52.192.101.131/messages/message", parameters: parameters as? [String : AnyObject], encoding: .JSON)
            .responseJSON {
                response in switch response.result{
                case .Success(let JSON):
                         print("id JSON: \(JSON)")
                         print("parameters: \(parameters)")
                         print("response: \(response)")
                         let sendingParam=true
                         let sendingBool=structParam3(sending: sendingParam)
                         sending.append(sendingBool)
                         dispatch_async(dispatch_get_main_queue()) {
                            success(sending)
                         }
                case .Failure(let error):print("Error: \(error)")
                }
        }
    }
    
    static func sendMessage(textMess: String, success: Success4)  {
        let textMessParam = ["text": textMess]
        let parameters = ["session": "5694cde0-d2dc-4cc4-b2d5-7506ac1f0216", "message": textMessParam]
        var sending=[structParam3]()
        Alamofire.request(.POST, "http://52.192.101.131/messages/message", parameters: parameters as? [String : AnyObject], encoding: .JSON)
            .responseJSON {
                response in  dispatch_async(dispatch_get_main_queue(), { switch response.result{
                case .Success(let JSON):
                    print("id JSON: \(JSON)")
                    print("parameters: \(parameters)")
                    print("response: \(response)")
                    let sendingParam=true
                    let sendingBool=structParam3(sending: sendingParam)
                    sending.append(sendingBool)
                    dispatch_async(dispatch_get_main_queue()) {
                        success(sending)
                    }
                case .Failure(let error):print("Error: \(error)")
                }
                })
        }
    }
}