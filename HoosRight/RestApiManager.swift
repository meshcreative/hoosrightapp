//
//  RestApiManager.swift
//  HossRight
//
//  Created by ios on 06/02/17.
//  Copyright © 2017 koios. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire


typealias ServiceResponsePost = (JSON) -> Void
typealias ServiceResponse = ([JSON]) -> Void
typealias ImageServiceResponse = (_ obj:DataResponse<String>?, _ success: Error?) -> Void
typealias notificationServiceResponse = (_ result:[JSON]) -> Void
typealias friendsList = ([JSON],Error?) -> Void

class RestApiManager:NSObject {
    
    static let sharedInstance = RestApiManager()
    var postResults = [JSON]()
    var hasMore = false
    let validator = Validation()
    
    func postRandomPosts(path:String, Parameters:[String:AnyObject]!, onCompletion:@escaping (JSON) -> Void ){
        makeHTTPPostRequest(path: path, parameters: Parameters, onCompletion: { json -> Void in
            onCompletion(json)
        })
    }


    func makeHTTPPostRequest(path:String,parameters:[String:AnyObject]!, onCompletion: @escaping ServiceResponsePost)  {
        print("Helloworld\(path)\(parameters)")
        Alamofire.request(path,method: .post, parameters:parameters!).validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("Post Result::\(json)")
                    onCompletion([json])
                case .failure(let error):
                    onCompletion([JSON.null])
                    print(error)
                }
        }
    }

    
    func getRandomPosts(path:String, onCompletion:@escaping ([JSON]) -> Void ){
        makeHTTPGetRequest(path: path, onCompletion: { json -> Void in
            onCompletion(json)
            
        })
    }
    
    
    func makeHTTPGetRequest(path:String, onCompletion: @escaping ServiceResponse)  {
        Alamofire.request(path).validate().responseJSON { response in
            switch response.result {
            case .success:
                if let results = response.result.value as? [String:AnyObject]{
                    print("Results: \(results)")
                    guard let profit = results["posts"] else {
                        print("GuardResults: \(results)")
                        onCompletion([JSON.null])
                        return
                    }
                    if profit is Array<Any> {
                        let items = JSON(results["posts"]!).arrayValue
                        self.hasMore = true
                        self.postResults += items
                        onCompletion(self.postResults)
                    } else {
                        print("No..............")
                    }
                    
                }
            case .failure(let error):
                print(error)
            }
            
            
        }
        
    }
    
    
    
    func postRandomNotification(path:String, Parameters:[String:AnyObject]!, onCompletion:@escaping ([JSON]) -> Void ){
        makeNoteHTTPPostRequest(path: path, parameters: Parameters, onCompletion: { json -> Void in
            onCompletion(json)
        })
    }
    
    
    func makeNoteHTTPPostRequest(path:String,parameters:[String:AnyObject]!, onCompletion: @escaping notificationServiceResponse)  {
        print("Helloworld\(path)\(parameters)")
        Alamofire.request(path,method: .post, parameters:parameters!).validate()
            .responseJSON { (response) in
                
                switch response.result {
                case .success:
                    if let results = response.result.value as? [String:AnyObject]{
                        print("Results: \(results)")
                        guard let profit = results["userNotifications"] else {
                            print("Results: \(results)")
                            onCompletion([JSON.null])
                            return
                        }
                        if profit is Array<Any> {
                            let items = JSON(results["userNotifications"]!).arrayValue
                            self.hasMore = true
                            self.postResults += items
                            onCompletion(self.postResults)
                        } else {
                            print("No..............")
                        }
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }

    
    func friendsList(path:String,parameters:[String:AnyObject]!, onCompletion: @escaping friendsList) {
        Alamofire.request(path,method: .post, parameters:parameters!).validate()
            .responseJSON { response in
                switch response.result {
                case .success( _):
                    if let results = response.result.value as? [String:AnyObject]{
                        let json = JSON(results)
                        onCompletion([json], nil)
                    }
                case .failure(let error):
                    onCompletion([JSON.null], error)
                    print(error)
                }
        }
        
    }
    
    
    
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    
    
    func uploadSingelImage(image:UIImage, onCompletion:@escaping ImageServiceResponse)  {
        
        let newImge = RBResizeImage(image: image, targetSize:CGSize(width: 200.0, height: 200.0))
        let imageData = UIImageJPEGRepresentation(newImge, 0.75)!
        
        let imgData: NSData = NSData(data: imageData)
        let imageSize: Int = imgData.length
        print("size of image in KB:\(imageSize/1024)KB")
        
        Alamofire.upload(multipartFormData: { fromData in
            fromData.append(imageData, withName: "userfile", fileName: "filename.jpg", mimeType: "image/jpeg")
        }, to: "\(ConstantsAPI.HoosRightServer)imageUpload.php", encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseString { response in
                    if let JSON = response.result.value {
                        print("Success::\(JSON)")
                        return onCompletion(response, nil)
                    }
                    else {
                        print("ErrorReport\(response.result.error)")
                        return onCompletion(nil, response.result.error)
                    }
                }
            case .failure(let encodingError):
                print("ErrorReport\(encodingError)")
                return onCompletion(nil, encodingError)
            }
        })
    }

    
    func search(_ searchText: String) {
        Alamofire.request(searchText, method: .post).validate() .responseJSON { response in
            switch response.result {
            case .success:
                if let results = response.result.value as? [String:AnyObject]{
                    print("Results: \(results)")
                    guard let profit = results["posts"] else {
                        print("Results: \(results)")
 
                        return
                    }
                    if profit is Array<Any> {
                        let items = JSON(results["posts"]!).arrayValue
                        self.hasMore = true
                        self.postResults += items
                        print("items: \(items)")
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "searchResultsUpdated"), object: nil)
                    } else {
                        print("No..............")
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func searchFriends(_ searchText: String) {
        Alamofire.request(searchText, method: .post).validate() .responseJSON { response in
            switch response.result {
            case .success:
            print("Friends:\(response)")
            case .failure(let error):
                print(error)
            }
        }
    }

    
    

    func resetSearch() {
        postResults = []
    }
    
}
