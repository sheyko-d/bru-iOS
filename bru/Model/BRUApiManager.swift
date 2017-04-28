//
//  BRUApiManager.swift
//  bru
//
//  Created by Huateng Ma on 4/18/17.
//  Copyright © 2017 Ma Huateng. All rights reserved.
//

import Foundation
import Bolts
import AFNetworking

class BRUApiManager: NSObject {
    
    static let sharedInstance = BRUApiManager()
    
    let baseApiPath = "http://moyersoftware.com/bru/api/v1"
    
    func signup(name: String, email: String, password: String) -> BFTask<AnyObject>! {
        var signupData: Dictionary<String, String> = [:]
        signupData["name"] = name
        signupData["email"] = email
        signupData["password"] = password
        
        let taskCompletonSource = BFTaskCompletionSource<AnyObject>()
        let manager = AFHTTPRequestOperationManager.init()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(baseApiPath + "/user/register.php", parameters: signupData, success: { (requestOperation, responseObject) in
            do {
                var responseDictionary = try JSONSerialization.jsonObject(with: responseObject as! Data) as! Dictionary<String, Any>
                responseDictionary["id"] = String(responseDictionary["id"] as! Int)
                let user = BRUUser(fromJSONDictionary: responseDictionary)
                setUser(user: user)
                taskCompletonSource.trySetResult(["success": true] as AnyObject)
            } catch {
                let message = String(data: responseObject as! Data, encoding: .utf8)!
                taskCompletonSource.trySetResult(["success": false, "message": message] as AnyObject)
            }
            
        }) { (requestOperation, error) in
            taskCompletonSource.trySetResult(["success": false, "error": error.localizedDescription] as AnyObject)
        }
        
        return taskCompletonSource.task
    }
    
    func loginWithEmail(email: String, password: String) -> BFTask<AnyObject>! {
        var loginData: Dictionary<String, String> = [:]
        loginData["email"] = email
        loginData["password"] = password
        
        let taskCompletonSource = BFTaskCompletionSource<AnyObject>()
        let manager = AFHTTPRequestOperationManager.init()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(baseApiPath + "/user/login.php", parameters: loginData, success: { (requestOperation, responseObject) in
            do {
                let responseDictionary = try JSONSerialization.jsonObject(with: responseObject as! Data) as! Dictionary<String, Any>
                let user = BRUUser(fromJSONDictionary: responseDictionary)
                setUser(user: user)
                taskCompletonSource.trySetResult(["success": true] as AnyObject)
            } catch {
                let message = String(data: responseObject as! Data, encoding: .utf8)!
                taskCompletonSource.trySetResult(["success": false, "message": message] as AnyObject)
            }
            
        }) { (requestOperation, error) in
            taskCompletonSource.trySetResult(["success": false, "error": error.localizedDescription] as AnyObject)
        }
        
        return taskCompletonSource.task
    }
    
    func loginWithFacebook(id: String, name: String, email: String, photo: String) -> BFTask<AnyObject>! {
        var loginData: Dictionary<String, String> = [:]
        loginData["id"] = id
        loginData["name"] = name
        loginData["email"] = email
        loginData["photo"] = photo
        
        let taskCompletonSource = BFTaskCompletionSource<AnyObject>()
        let manager = AFHTTPRequestOperationManager.init()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(baseApiPath + "/user/sign_in_facebook.php", parameters: loginData, success: { (requestOperation, responseObject) in
            do {
                let responseDictionary = try JSONSerialization.jsonObject(with: responseObject as! Data) as! Dictionary<String, Any>
                let user = BRUUser(fromJSONDictionary: responseDictionary)
                setUser(user: user)
                taskCompletonSource.trySetResult(["success": true] as AnyObject)
            } catch {
                let message = String(data: responseObject as! Data, encoding: .utf8)!
                taskCompletonSource.trySetResult(["success": false, "message": message] as AnyObject)
            }
            
        }) { (requestOperation, error) in
            taskCompletonSource.trySetResult(["success": false, "error": error.localizedDescription] as AnyObject)
        }
        
        return taskCompletonSource.task
    }
    
    func updateLocation(latitude: Double, longitude: Double) -> BFTask<AnyObject>! {
        var postData: Dictionary<String, Any> = [:]
        postData["latitude"] = latitude
        postData["longitude"] = longitude
        postData["token"] = getUser().token
        
        let taskCompletonSource = BFTaskCompletionSource<AnyObject>()
        let manager = AFHTTPRequestOperationManager.init()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(baseApiPath + "/user/update_location.php", parameters: postData, success: { (requestOperation, responseObject) in
            taskCompletonSource.trySetResult(["success": true] as AnyObject)
        }) { (requestOperation, error) in
            taskCompletonSource.trySetResult(["success": false, "error": error.localizedDescription] as AnyObject)
        }
        
        return taskCompletonSource.task
    }
    
    func getNewsFeed() -> BFTask<AnyObject>! {
        let taskCompletonSource = BFTaskCompletionSource<AnyObject>()
        let manager = AFHTTPRequestOperationManager.init()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.get(baseApiPath + "/news_feed/get_news_feed.php", parameters: nil, success: { (requestOperation, responseObject) in
            do {
                let responseArray = try JSONSerialization.jsonObject(with: responseObject as! Data) as! Array<Dictionary<String, Any>>
                var newsFeedArray: [BRUNewsFeed] = []
                for newsFeedDictionary in responseArray {
                    newsFeedArray.append(BRUNewsFeed(fromJSONDictionary: newsFeedDictionary))
                }
                taskCompletonSource.trySetResult(newsFeedArray as AnyObject?)
            } catch {
//                taskCompletonSource.trySetError(error)
                taskCompletonSource.trySetResult([] as AnyObject?)
            }
            
        }) { (requestOperation, error) in
//            taskCompletonSource.trySetError(error)
            taskCompletonSource.trySetResult([] as AnyObject?)
        }
        
        return taskCompletonSource.task
    }
    
    func postNews(text: String, image: UIImage?, imageURL: URL?) -> BFTask<AnyObject>! {
        var postData: Dictionary<String, String> = [:]
        postData["text"] = "\"" + text + "\""
        postData["token"] = "\"" + getUser().token + "\""
        
        let taskCompletonSource = BFTaskCompletionSource<AnyObject>()
        let manager = AFHTTPRequestOperationManager.init()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(baseApiPath + "/news_feed/add_post.php", parameters: postData, constructingBodyWith: { (formData) in
            if image != nil {
                let data = UIImagePNGRepresentation(image!)
                formData.appendPart(withFileData: data!, name: "file", fileName: (imageURL?.absoluteString)!, mimeType: "image/*")
            }
        }, success: { (requestOperation, responseObject) in
            taskCompletonSource.trySetResult(["success": true] as AnyObject)
        }) { (requestOperation, error) in
            taskCompletonSource.trySetResult(["success": false, "error": error.localizedDescription] as AnyObject)
        }
        
        return taskCompletonSource.task
    }
    
    func deleteNewsFeed(newFeedId: String) -> BFTask<AnyObject>! {
        var postData: Dictionary<String, String> = [:]
        postData["news_feed_id"] = newFeedId
        postData["token"] = getUser().token
        
        let taskCompletonSource = BFTaskCompletionSource<AnyObject>()
        let manager = AFHTTPRequestOperationManager.init()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(baseApiPath + "/news_feed/delete_news_feed_item.php", parameters: postData, success: { (requestOperation, responseObject) in
            taskCompletonSource.trySetResult(["success": true] as AnyObject)
        }) { (requestOperation, error) in
            taskCompletonSource.trySetResult(["success": false, "error": error.localizedDescription] as AnyObject)
        }
        
        return taskCompletonSource.task
    }
    
    func getOnTaps() -> BFTask<AnyObject>! {
        let taskCompletonSource = BFTaskCompletionSource<AnyObject>()
        let manager = AFHTTPRequestOperationManager.init()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.get(baseApiPath + "/on_tap/get_on_tap.php", parameters: nil, success: { (requestOperation, responseObject) in
            do {
                let responseDictionary = try JSONSerialization.jsonObject(with: responseObject as! Data) as! Dictionary<String, Any>
                var onTapArray: [BRUOnTap] = []
                for onTapDictionary in responseDictionary["on_tap_items"] as! Array<Dictionary<String, Any>> {
                    onTapArray.append(BRUOnTap(fromJSONDictionary: onTapDictionary))
                }
                let hours = responseDictionary["hours"] as! String
                let lastUpdated = responseDictionary["last_updated"] as! String
                taskCompletonSource.trySetResult(["success": true, "onTapArray": onTapArray, "hours": hours, "lastUpdated" : lastUpdated] as AnyObject)
            } catch {
                taskCompletonSource.trySetResult(["success": false] as AnyObject)
            }
            
        }) { (requestOperation, error) in
            taskCompletonSource.trySetResult(["success": false] as AnyObject)
        }
        
        return taskCompletonSource.task
    }
    
    func getBrus() -> BFTask<AnyObject>! {
        var postData: Dictionary<String, String> = [:]
        postData["token"] = getUser().token
        
        let taskCompletonSource = BFTaskCompletionSource<AnyObject>()
        let manager = AFHTTPRequestOperationManager.init()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(baseApiPath + "/bru/get_brus.php", parameters: postData, success: { (requestOperation, responseObject) in
            do {
                let responseArray = try JSONSerialization.jsonObject(with: responseObject as! Data) as! Array<Dictionary<String, Any>>
                var bruArray: [BRUBru] = []
                for bruDictionary in responseArray {
                    bruArray.append(BRUBru(fromJSONDictionary: bruDictionary))
                }
                taskCompletonSource.trySetResult(bruArray as AnyObject?)
            } catch {
                //                taskCompletonSource.trySetError(error)
                taskCompletonSource.trySetResult([] as AnyObject?)
            }
            
        }) { (requestOperation, error) in
            //            taskCompletonSource.trySetError(error)
            taskCompletonSource.trySetResult([] as AnyObject?)
        }
        
        return taskCompletonSource.task
    }
    
    func rateBru(bruId: String, rating: Float) -> BFTask<AnyObject>! {
        var postData: Dictionary<String, String> = [:]
        postData["token"] = getUser().token
        postData["bru_id"] = bruId
        postData["rating"] =  "\(rating)"
        
        let taskCompletonSource = BFTaskCompletionSource<AnyObject>()
        let manager = AFHTTPRequestOperationManager.init()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(baseApiPath + "/bru/rate_bru.php", parameters: postData, success: { (requestOperation, responseObject) in
            taskCompletonSource.trySetResult(["success": true] as AnyObject)
        }) { (requestOperation, error) in
            taskCompletonSource.trySetResult(["success": false, "error": error.localizedDescription] as AnyObject)
        }
        
        return taskCompletonSource.task
    }
    
    func updateUser(image: UIImage?, imageURL: URL?) -> BFTask<AnyObject>! {
        var postData: Dictionary<String, String> = [:]
        let user = getUser()
        postData["name"] = "\"" + user.name + "\""
        postData["email"] = "\"" + user.email + "\""
        postData["token"] = "\"" + user.token + "\""
        
        let taskCompletonSource = BFTaskCompletionSource<AnyObject>()
        let manager = AFHTTPRequestOperationManager.init()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(baseApiPath + "/user/update_profile.php", parameters: postData, constructingBodyWith: { (formData) in
//            formData.appendPart(withForm: user.name.data(using: .utf8)!, name: "name")
//            formData.appendPart(withForm: user.email.data(using: .utf8)!, name: "email")
//            formData.appendPart(withForm: user.token.data(using: .utf8)!, name: "token")
            if image != nil {
                let data = UIImagePNGRepresentation(image!)
                formData.appendPart(withFileData: data!, name: "file", fileName: (imageURL?.absoluteString)!, mimeType: "image/*")
            }
        }, success: { (requestOperation, responseObject) in
            taskCompletonSource.trySetResult(["success": true] as AnyObject)
        }) { (requestOperation, error) in
            taskCompletonSource.trySetResult(["success": false, "error": error.localizedDescription] as AnyObject)
        }
        
        return taskCompletonSource.task
    }
    
    func updateGoogleToken(googleToken: String) -> BFTask<AnyObject>! {
        var postData: Dictionary<String, String> = [:]
        postData["google_token"] = googleToken
        postData["token"] = getUser().token
        
        let taskCompletonSource = BFTaskCompletionSource<AnyObject>()
        let manager = AFHTTPRequestOperationManager.init()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.post(baseApiPath + "/user/update_google_token.php", parameters: postData, success: { (requestOperation, responseObject) in
            taskCompletonSource.trySetResult(["success": true] as AnyObject)
        }) { (requestOperation, error) in
            taskCompletonSource.trySetResult(["success": false, "error": error.localizedDescription] as AnyObject)
        }
        
        return taskCompletonSource.task
    }
    
}
