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
            var paramName: [String: String] = [String: String]()
            print(tweets![(tweets?.count)! - 1].id!)
            paramName.updateValue("\(tweets![(tweets?.count)! - 1].id!)", forKey: "since_id")
            paramName.updateValue("20", forKey: "count")
            
            get("1.1/statuses/home_timeline.json", parameters: paramName, progress: nil, success: { (
                task: URLSessionDataTask, response: Any?) -> Void in
                let dictionaries = response as! [NSDictionary]
                
                let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
                
                success(tweets)
                
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                failure(error)
            })
        }
    }
    
    func userTimeline(id: String, tweets: [Tweet]?, success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        var paramName: [String: String] = [String: String]()
        paramName.updateValue(id, forKey: "user_id")
        
        get("1.1/statuses/user_timeline.json", parameters: paramName, progress: nil, success: { (
            task: URLSessionDataTask, response: Any?) -> Void in
            let dictionaries = response as! [NSDictionary]
            
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            
            success(tweets)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
        
    }
    
    func postTweet(tweet: String, response: Bool, id: Int, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        
        var paramName: [String: String] = [String: String]()
        paramName.updateValue(tweet, forKey: "status")
        if response == true {
            paramName.updateValue("\(id)", forKey: "in_reply_to_status_id")
        }
        
        post("1.1/statuses/update.json", parameters: paramName, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    func retweet(id: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post("1.1/statuses/retweet/\(id).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func getRetweet(id: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        var paramName: [String: String] = [String: String]()
        paramName.updateValue(id, forKey: "id")
        paramName.updateValue("true", forKey: "include_my_retweet")
        
        get("1.1/statuses/show.json", parameters: paramName, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func unRetweet(id: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post("1.1/statuses/destroy/\(id).json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })

    }
    
    func favorite(id: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        post("1.1/favorites/create.json?id=" + id, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
            
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
    
    func unfavorite(id: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        var paramName: [String: String] = [String: String]()
        paramName.updateValue("\(id)", forKey: "id")
        
        post("1.1/favorites/destroy.json", parameters: paramName, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            
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
}
