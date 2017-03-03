//
//  TwitterClient.swift
//  TwitterDemo
//
//  Created by Benny Singer on 2/24/17.
//  Copyright © 2017 Benjamin Singer. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com") as! URL, consumerKey: "FLhihEpb75CKXUY1SrHyxP5Ql", consumerSecret: "NfMAqGXSKx1ZvTfguzOaYrf9QAVwpMJbeSMcel4vI5q7HiWCiF")
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil,
            success: { (task: URLSessionDataTask, response: Any?) -> Void in
                print("account: \(response)")
                let userDictionary = response as! NSDictionary
                
                let user = User(dictionary: userDictionary)
                
                success(user)
                
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        let twitterClient = TwitterClient.sharedInstance
        twitterClient?.deauthorize()
        
        twitterClient?.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: NSURL(string: "twitterdemo://oauth") as URL!, scope: nil,
                                         success: { (requestToken: BDBOAuth1Credential?) -> Void in
                                            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken!.token!)")!
                                            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }) { (error: Error?) -> Void in
            print("error: \(error?.localizedDescription)")
            self.loginFailure?(error!)
        }
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
    }
    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
            
            self.currentAccount(success: { (user: User) in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: Error) in
                self.loginFailure?(error)
            })
            
        }, failure: { (error: Error?) in
            
            self.loginFailure?(error!)
            
        })
    }
    
    func homeTimeline(tweets: [Tweet]?, reload: Bool, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        if tweets == nil || reload == true {
            get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (
                task: URLSessionDataTask, response: Any?) -> Void in
                let dictionaries = response as! [NSDictionary]
                
                let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
                
                success(tweets)
                
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
            })
        }
        else {
            get("1.1/statuses/home_timeline.json?since_id=\(tweets![0].id!)", parameters: nil, progress: nil, success: { (
                task: URLSessionDataTask, response: Any?) -> Void in
                let dictionaries = response as! [NSDictionary]
                
                let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
                
                success(tweets)
                
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
            })
        }
    }
    
    //h/t: http://stackoverflow.com/questions/24551816/swift-encode-url
    func postTweet(tweet: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        
        var paramName: [String: String] = [String: String]()
        paramName.updateValue(tweet, forKey: "status")
        
        post("1.1/statuses/update.json", parameters: paramName, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    func retweet(id: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post("1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func getRetweet(id: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/statuses/show/id=\(id).json?include_my_retweet=true", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func unRetweet(id: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post("1.1/statuses/destroy/\(id).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })

    }
    
    func favorite(id: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post("https://api.twitter.com/1.1/favorites/create.json?id=" + String(id), parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func getUser(screenname: String, success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/users/show.json?screen_name=\(screenname)", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            success(user)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
        
    }
    
    func cleanForURL(string: String) -> String {
        var cleanedString = string
        cleanedString = cleanedString.replacingOccurrences(of: " ", with: "%20")
        cleanedString = cleanedString.replacingOccurrences(of: "\"", with: "%22")
        cleanedString = cleanedString.replacingOccurrences(of: "#", with: "%23")
        cleanedString = cleanedString.replacingOccurrences(of: "$", with: "%24")
        cleanedString = cleanedString.replacingOccurrences(of: "%", with: "%25")
        cleanedString = cleanedString.replacingOccurrences(of: "&", with: "%26")
        cleanedString = cleanedString.replacingOccurrences(of: "\'", with: "%27")
        cleanedString = cleanedString.replacingOccurrences(of: "(", with: "%28")
        cleanedString = cleanedString.replacingOccurrences(of: ")", with: "%29")
        cleanedString = cleanedString.replacingOccurrences(of: "+", with: "%2B")
        cleanedString = cleanedString.replacingOccurrences(of: ",", with: "%2C")
        cleanedString = cleanedString.replacingOccurrences(of: "-", with: "%2D")
        cleanedString = cleanedString.replacingOccurrences(of: ".", with: "%2E")
        cleanedString = cleanedString.replacingOccurrences(of: "//", with: "%2F")
        
        return cleanedString
    }
}
