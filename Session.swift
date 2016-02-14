//
//  AppDelegate.swift
//  Chat
//
//  Created by Kobalt on 12.01.16.
//  Copyright © 2016 Kobalt. All rights reserved.
//

import Foundation


class Session: NSObject {
    
    // MARK: - Types
    
    typealias Success = (NSData?) -> Void
    typealias Failure = (ErrorType) -> Void
    
    // MARK: - Class Properties
    
    static let instance = Session()
    
    // MARK: - Properties
    
    private let baseURL = NSURL(string: "http://52.192.101.131")!
    private let token = "5694cde0-d2dc-4cc4-b2d5-7506ac1f0216"
    private var session = NSURLSession(configuration: .defaultSessionConfiguration())
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
    }
    deinit {
        session.invalidateAndCancel()
    }
    
    // MARK: - Requests GET
    
    func GET(path: String, parameters: [String: String]?, success: Success?,
        failure: Failure?) -> NSURLSessionDataTask {
        let request = requestWithPath(path, method: "GET", parameters: parameters)
        return GET(request, success: success, failure: failure)
    }
    
    func GET(URL: NSURL, parameters: [String: String]?, success: Success?,
        failure: Failure?) -> NSURLSessionDataTask {
        let request = requestWithURL(URL, method: "GET", parameters: parameters)
        return GET(request, success: success, failure: failure)
    }
    
    private func GET(request: NSURLRequest, success: Success?, failure: Failure?) -> NSURLSessionDataTask {
        let task = session.dataTaskWithRequest(request) { (data, _, error) -> Void in
            guard error == nil else {
                failure?(error!)
                return
            }
            success?(data)
        }
        task.resume()
        return task
    }
    
    // MARK: - Creating Request
    
    private func requestWithPath(path: String, method: String,
        parameters: [String: String]?) -> NSURLRequest {
        let URL = baseURL.URLByAppendingPathComponent(path)
        return requestWithURL(URL, method: method, parameters: parameters)
    }
    
    private func requestWithURL(var URL: NSURL, method: String,
        parameters: [String: String]?) -> NSURLRequest {
        if var actualParameters = parameters {
            var parametersString = "?"
            actualParameters["session"] = token
            for (parameter, value) in actualParameters {
                parametersString += parameter + "=" + value + "&"
            }
            parametersString.removeAtIndex(parametersString.endIndex.predecessor())
            if let newURL = NSURL(string: URL.absoluteString + parametersString) {
                URL = newURL
            }
        }
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = method
        return request
    }
}
