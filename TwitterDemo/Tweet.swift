//
//  Tweet.swift
//  TwitterDemo
//
//  Created by Benny Singer on 2/20/17.
//  Copyright © 2017 Benjamin Singer. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var id: Int?
    var owner: User?
    var text: NSString?
    var timestamp: Date?
    var retweetCount: Int = 0
    var favoriteCount: Int = 0
    var retweeted = false
    var favorited = false
    var url: URL?
    
    var currentUserRetweetId: Int?
    
    var prevRetweeted: Tweet? = nil
    
    init(dictionary: NSDictionary) {
        id = dictionary["id"] as? Int
        
        text = dictionary["text"] as? String as NSString?
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoriteCount = (dictionary["favorite_count"] as? Int) ?? 0
        
        let timestampString = dictionary["created_at"] as? String
        
        if let timestampString = timestampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.date(from: timestampString) as Date?
        }
        
        let userDictionary = dictionary["user"] as? NSDictionary
        if let userDictionary = userDictionary {
            owner = User(dictionary: userDictionary)
        }
        
        let retweetedStatus = dictionary["retweeted"] as? Bool
        if let retweeted = retweetedStatus {
            self.retweeted = retweeted
        }
        
        let favoritedStatus = dictionary["favorited"] as? Bool
        if let favorited = favoritedStatus {
            self.favorited = favorited
        }
        
        let prevRetweetedStatus = dictionary["retweeted_status"] as? NSDictionary
        if let prevRetweeted = prevRetweetedStatus {
            self.prevRetweeted = Tweet(dictionary: prevRetweeted)
        }
        
        let currentUserRetweet = dictionary["current_user_retweet"] as? NSDictionary
        if let currentUserRetweet = currentUserRetweet {
            currentUserRetweetId = currentUserRetweet["id"] as? Int
        }
        
        let textSplit = text?.components(separatedBy: " ")
        for component in textSplit! {
            if component.characters.prefix(5).elementsEqual((String("https")?.characters)!)  {
                self.url = URL(string: component)
                break
            }
            
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
}
