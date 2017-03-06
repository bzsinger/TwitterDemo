//
//  User.swift
//  TwitterDemo
//
//  Created by Benny Singer on 2/20/17.
//  Copyright © 2017 Benjamin Singer. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: NSString?
    var screenname: NSString?
    var id: String?
    var profileUrl: NSURL?
    var profileBackgroundUrl: NSURL?
    var tagline: NSString?
    var numTweets: Int?
    var numFollowers: Int?
    var numFollowing: Int?
    
    var textColor: UIColor?

    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String as NSString?
        screenname = dictionary["screen_name"] as! NSString?
        
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = NSURL(string: profileUrlString)
        }
        
        let profileTextColorString = dictionary["profile_text_color"] as? String
        let profileTextColor = Int(profileTextColorString!)
        
        if let profileTextColor = profileTextColor {
            textColor = UIColor(netHex: profileTextColor)
        }
        
        id = dictionary["id_str"] as! String?
        
        numTweets = dictionary["statuses_count"] as! Int?
        numFollowers = dictionary["followers_count"] as! Int?
        numFollowing = dictionary["friends_count"] as! Int?
        
        tagline = dictionary["description"] as? NSString
    }
    
    static let userDidLogoutNotification = "UserDidLogout"
    static var _currentUser: User?
    
    class var currentUser: User? { //indicated that it's a computed property
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: "currentUserData") as? Data
                
                if let userData = userData {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: [])
                    _currentUser = User(dictionary: dictionary as! NSDictionary)
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            let defaults = UserDefaults.standard
            
            if let user = user {
                let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(data, forKey: "currentUserData")
            } else {
                defaults.removeObject(forKey: "currentUserData")
            }
            defaults.synchronize()
        }
    }
    
    
    static var _tweets: [Tweet]?
    class var tweets: [Tweet]? {
        get {
            if _tweets == nil {
                TwitterClient.sharedInstance?.homeTimeline(reload: false, success: { (tweets: [Tweet]) in
                    print("user reload")
                    _tweets = tweets
                }, failure: { (error: Error) in
                    print(error.localizedDescription)
                })
            }
            return _tweets
        }
        set(tweets) {
            _tweets = tweets
        }
    }
    
    class func reloadUser() {
        TwitterClient.sharedInstance?.currentAccount(success: { (user: User) in
            User.currentUser = user
        }, failure: { (error: Error) in
        })
    }
}
