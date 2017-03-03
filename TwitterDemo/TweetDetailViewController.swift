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
    @IBOutlet weak var replyImageView: UIImageView!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetNumberLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteNumberLabel: UILabel!
    
    var tweet: Tweet!

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        replyImageView.image = #imageLiteral(resourceName: "reply-icon")
        
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //h/t zemirco (Github)
    func formatDate(date: Date) -> String {
        let calendar = Calendar.current
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let currentComponents = (calendar as NSCalendar).components(unitFlags, from: date)
        
        return "\(currentComponents.month!)/\(currentComponents.day!)/\(currentComponents.year!), \(currentComponents.hour!):\(currentComponents.minute!)"
    }
    
    func formatFavoriteRetweetNumbers(number: Int) -> String {
        if number > 1000 {
            return "\(number / 1000)K"
        }
        if number > 1000000 {
            return "\(number / 1000000)M"
        }
        return "\(number)"
    }
    
    @IBAction func retweetButtonClicked(_ sender: Any) {
        if tweet.retweeted {
            /*TwitterClient.sharedInstance?.getRetweet(id: tweet.id!, success: { (tweet: Tweet) in
             
             }, failure: { (error: Error) in
             print(error.localizedDescription)
             })*/
            return
        }
        TwitterClient.sharedInstance?.retweet(id: tweet.id!, success: { (tweet: Tweet) in
            self.retweetButton.setBackgroundImage(#imageLiteral(resourceName: "retweet-icon-green"), for: .normal)
            //tweet.retweetCount += 1
            self.retweetNumberLabel.text = self.formatFavoriteRetweetNumbers(number: tweet.retweetCount)
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }

    @IBAction func favoriteButtonClicked(_ sender: Any) {
        if tweet.favorited { return }
        TwitterClient.sharedInstance?.favorite(id: tweet.id!, success: { (boolResponse: Tweet) in
            self.favoriteButton.setBackgroundImage(#imageLiteral(resourceName: "favor-icon-red"), for: .normal)
            //self.tweet.favoriteCount += 1
            self.favoriteNumberLabel.text = self.formatFavoriteRetweetNumbers(number: self.tweet.favoriteCount)
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
