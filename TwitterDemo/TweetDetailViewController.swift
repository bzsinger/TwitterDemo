//
//  TweetDetailViewController.swift
//  TwitterDemo
//
//  Created by Benny Singer on 2/27/17.
//  Copyright © 2017 Benjamin Singer. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetNumberLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteNumberLabel: UILabel!
    
    var tweet: Tweet!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(wasTapped))
        tweetLabel.isUserInteractionEnabled = true
        tweetLabel.addGestureRecognizer(tap)
        
        let tweetOwner = tweet.owner
        if let profileUrl = tweetOwner?.profileUrl {
            profileImageView.setImageWith(profileUrl as URL)
        } else {
            profileImageView.image = #imageLiteral(resourceName: "profile-Icon")
        }
        profileImageView.layer.cornerRadius = 8.0
        profileImageView.clipsToBounds = true
        
        if let name = tweetOwner?.name {
            nameButton.setTitle(name as String, for: .normal)
        } else {
            nameButton.setTitle("", for: .normal)
        }
        
        if let username = tweetOwner?.screenname {
            usernameLabel.text = "@\(username as String)"
        } else {
            usernameLabel.text = ""
        }
        
        if let time = tweet.timestamp {
            timeLabel.text = formatDate(date: time)
        } else {
            timeLabel.text = ""
        }
        
        if let tweetText = tweet.text {
            tweetLabel.text = tweetText as String
        } else {
            tweetLabel.text = ""
        }
        
        favoriteNumberLabel.text = formatFavoriteRetweetNumbers(number: tweet.favoriteCount)
        retweetNumberLabel.text = formatFavoriteRetweetNumbers(number: tweet.retweetCount)
        
        replyButton.setBackgroundImage(#imageLiteral(resourceName: "reply-icon"), for: .normal)
        replyButton.setTitle("", for: .normal)
        
        if tweet.retweeted {
            retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
        } else {
            retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet-icon"), for: .normal)
        }
        retweetButton.setTitle("", for: .normal)
        
        if tweet.favorited {
            favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
        } else {
            favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)
        }
        favoriteButton.setTitle("", for: .normal)
        
        let profileTap = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(profileTap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //h/t zemirco (Github)
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/y h:mm a"
        return dateFormatter.string(from: date)
    }
    
    func formatFavoriteRetweetNumbers(number: Int) -> String {
        if number > 1000000 {
            return "\(number / 1000000)M"
        }
        if number > 1000 {
            return "\(number / 1000)K"
        }
        return "\(number)"
    }
    
    @IBAction func retweetButtonClicked(_ sender: Any) {
        if tweet.retweeted {
            var originalTweetId = ""
            if tweet.prevRetweeted == nil {
                originalTweetId = tweet.id!
            } else {
                originalTweetId = (tweet.prevRetweeted?.id)!
            }
            
            TwitterClient.sharedInstance?.getRetweet(id: originalTweetId, success: { (tweet: Tweet) in
                let retweetId = tweet.currentUserRetweetId
                TwitterClient.sharedInstance?.unRetweet(id: retweetId!, success: { (destroyedTweet: Tweet) in
                    self.retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet-icon"), for: .normal)
                    self.tweet.retweetCount -= 1
                    self.retweetNumberLabel.text = self.formatFavoriteRetweetNumbers(number: self.tweet.retweetCount)
                    self.tweet.retweeted = false
                }, failure: { (error: Error) in
                    print("Failed to unretweeet")
                    print(error.localizedDescription)
                })
            }, failure: { (error: Error) in
                print("Failed to get tweet")
                print(error.localizedDescription)
            })
            return
        } else {
            TwitterClient.sharedInstance?.retweet(id: tweet.id!, success: { (tweet: Tweet) in
                self.retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
                self.tweet.retweetCount += 1
                self.retweetNumberLabel.text = self.formatFavoriteRetweetNumbers(number: self.tweet.retweetCount)
                self.tweet.retweeted = true
            }, failure: { (error: Error) in
                print("Couldn't retweet")
                print(error.localizedDescription)
            })
        }
    }

    @IBAction func nameButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "userDetail", sender: self)
    }
    
    func profileTapped() {
        performSegue(withIdentifier: "userDetail", sender: self)
    }
    

    @IBAction func favoriteButtonClicked(_ sender: Any) {
        if tweet.favorited {
            TwitterClient.sharedInstance?.unfavorite(id: tweet.id!, success: { (boolResponse: Tweet) in
                self.favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "favor-icon"), for: .normal)
                self.tweet.favoriteCount -= 1
                self.favoriteNumberLabel.text = self.formatFavoriteRetweetNumbers(number: self.tweet.favoriteCount)
                self.tweet.favorited = false
            }, failure: { (error: Error) in
                print("Failed to unfavorite")
                print(error.localizedDescription)
            })
            
            return
        } else {
            TwitterClient.sharedInstance?.favorite(id: tweet.id!, success: { (boolResponse: Tweet) in
                self.favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
                self.tweet.favoriteCount += 1
                self.favoriteNumberLabel.text = self.formatFavoriteRetweetNumbers(number: self.tweet.favoriteCount)
                self.tweet.favorited = true
            }, failure: { (error: Error) in
                print("Couldn't favorite")
                print(error.localizedDescription)
            })
        }
    }
    
    @IBAction func replyButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "reply", sender: self)
    }

    func wasTapped() {
        if let url = tweet.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userDetail" {
            let destination = segue.destination as! UserDetailViewController
            destination.user = tweet.owner
            
        } else if segue.identifier == "reply" {
            let destination = segue.destination as! ComposeTweetViewController
            
            destination.preText = "@\((tweet.owner?.screenname)!) "
            destination.user = tweet.owner!
            
        }
    }
    
}
