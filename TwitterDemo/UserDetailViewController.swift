//
//  UserDetailViewController.swift
//  TwitterDemo
//
//  Created by Benny Singer on 2/28/17.
//  Copyright © 2017 Benjamin Singer. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetNumberLabel: UILabel!
    @IBOutlet weak var followingNumberLabel: UILabel!
    @IBOutlet weak var followersNumberLabel: UILabel!
    
    var numbersShortened: Bool = false
    
    var user: User!
    var tweets: [Tweet]!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.setImageWith(user.profileUrl as! URL)
        profileImageView.layer.cornerRadius = 8.0
        profileImageView.clipsToBounds = true
        nameLabel.text = user.name as String!
        usernameLabel.text = "@\((user.screenname as String!)!)"
        // Do any additional setup after loading the view.
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(numberTapped))
        tweetNumberLabel.isUserInteractionEnabled = true
        tweetNumberLabel.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(numberTapped))
        followersNumberLabel.isUserInteractionEnabled = true
        followersNumberLabel.addGestureRecognizer(tap2)
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(numberTapped))
        followingNumberLabel.isUserInteractionEnabled = true
        followingNumberLabel.addGestureRecognizer(tap3)
        
        numberTapped()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadTweets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberTapped() {
        if numbersShortened {
            tweetNumberLabel.text = "\((user.numTweets)!)"
            followersNumberLabel.text = "\((user.numFollowers)!)"
            followingNumberLabel.text = "\((user.numFollowing)!)"
            numbersShortened = false
        } else {
            tweetNumberLabel.text = formatNumbers(number: user.numTweets)
            followersNumberLabel.text = formatNumbers(number: user.numFollowers)
            followingNumberLabel.text = formatNumbers(number: user.numFollowing)
            numbersShortened = true
        }
    }
    
    func formatNumbers(number: Int?) -> String {
        if number == nil { return "" }
        if number! > 1000000 {
            return "\(number! / 1000000)M"
        }
        if number! > 1000 {
            return "\(number! / 1000)K"
        }
        return "\(number!)"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tweets == nil { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = tweets![indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = tweets {
            return tweets.count
        }
        return 0
    }
    
    @IBAction func replyButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "reply", sender: (sender as! UIButton).superview?.superview as! TweetCell)
    }
    
    func loadTweets() {
        TwitterClient.sharedInstance?.userTimeline(id: user.id!, tweets: tweets, success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
        }, failure: { (error: Error) in
            self.tweets = []
            print(error.localizedDescription)
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tweetDetail" {
            let destination = segue.destination as! TweetDetailViewController
            
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            destination.tweet = User.tweets![indexPath!.row]
            tableView.deselectRow(at: indexPath!, animated: true)
        } else if segue.identifier == "reply" {
            let destination = segue.destination as! ComposeTweetViewController
            
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            destination.preText = "@\((User.tweets![indexPath!.row].owner!.screenname)!) "
            destination.user = User.tweets![indexPath!.row].owner!
        }
    }
}
