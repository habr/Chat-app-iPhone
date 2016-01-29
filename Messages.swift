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
    private var messIsLoading = false
    
    static func messagesForPage(page: Int, success: Success, failure: Session.Failure) {
        let parameters = [
            "paging_size=5&oldest_message_id": String(page)
        ]
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
                        let mes = mess["text"] as? NSString
                        let idmes = (mess["id"] as! NSString).integerValue
                        let imgmes = mess["image_url"] as? NSURL
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
                        let message = Message(id: idmes, updated_at:timemes as String, image_url:imgmes, text: mes as? String, idnick: idname, nickname:nickname as String, avatar_image:ava)
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
            "paging_size=5&oldest_message_id": String(page)
        ]
        Session.instance.GET("messages", parameters: parameters,
            success: {
                data in
                guard let actualData = data else {
                    return
                }
                
                do {
                    let JSON = try NSJSONSerialization.JSONObjectWithData(actualData, options: [.AllowFragments])
                    
                    let totalItemsCount = Param(total_items_count: ((JSON["total_items_count"] as! NSString).integerValue - 90)) //+2 не забыть поставить обратно!!!!

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
}