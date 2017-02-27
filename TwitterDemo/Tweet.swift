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
    
    init(dictionary: NSDictionary) {
        id = dictionary["id"] as? Int
        
        text = dictionary["text"] as? String as NSString?
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoriteCount = (dictionary["favourites_count"] as? Int) ?? 0
        
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
