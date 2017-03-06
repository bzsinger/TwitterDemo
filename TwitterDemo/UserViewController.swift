//
//  UserViewController.swift
//  TwitterDemo
//
//  Created by Benny Singer on 2/27/17.
//  Copyright © 2017 Benjamin Singer. All rights reserved.
//

import UIKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetNumberLabel: UILabel!
    @IBOutlet weak var followerNumberLabel: UILabel!
    @IBOutlet weak var followingNumberLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var composeButton: UIBarButtonItem!
    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    
    @IBOutlet weak var tweetsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    var loading = false
    
    var numbersShortened: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TwitterClient.sharedInstance?.limitStatus()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension //use AutoLayout
        tableView.estimatedRowHeight = 120 //only used for scrollbar height dimension
        
        profileImageView.image = #imageLiteral(resourceName: "profile-Icon")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(numberTapped))
        tweetNumberLabel.isUserInteractionEnabled = true
        tweetNumberLabel.addGestureRecognizer(tap)
        followerNumberLabel.isUserInteractionEnabled = true
        followerNumberLabel.addGestureRecognizer(tap)
        followingNumberLabel.isUserInteractionEnabled = true
        followingNumberLabel.addGestureRecognizer(tap)
        
        let tweetTap = UITapGestureRecognizer(target: self, action: #selector(tweetTapped))
        tweetsLabel.isUserInteractionEnabled = true
        tweetsLabel.addGestureRecognizer(tweetTap)
        
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTapped))
        followersLabel.isUserInteractionEnabled = true
        followersLabel.addGestureRecognizer(followersTap)
        
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(followingTapped))
        followingLabel.isUserInteractionEnabled = true
        followingLabel.addGestureRecognizer(followingTap)
        
        loadData(reload: false, showError: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //loadData(reload: true, showError: false)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = User.tweets {
            return tweets.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if User.tweets == nil { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = User.tweets![indexPath.row]
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logoutButtonClicked(_ sender: Any) {
        TwitterClient.sharedInstance?.logout()
    }
    
    func loadData(reload: Bool, showError: Bool) {
        if loading { return }
        loading = true
        print("load data")
        TwitterClient.sharedInstance?.homeTimeline(reload: reload, success: { (tweets: [Tweet]) in
            if (reload != true) {
                if User.tweets == nil {
                    User.tweets = tweets
                } else {
                    User.tweets! += tweets
                }
            }
            self.loadUser()
            self.composeButton.isEnabled = true
            self.tableView.reloadData()
            
        }, failure: { (error: Error) in
            
            if showError {
                print("showing error")
                var title = error.localizedDescription
                
                if title == "Request failed: client error (429)" {
                    title = "We've been sending too many requests to Twitter. Try again in a couple minutes."
                    self.composeButton.isEnabled = false
                }
                
                let alertController = UIAlertController(title: "Oops!", message: title, preferredStyle: .alert)
                
                // create a cancel action
                let cancelAction = UIAlertAction(title: "OK", style: .cancel) { (action) in
                    // handle cancel response here. Doing nothing will dismiss the view.
                }
                // add the cancel action to the alertController
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true) {
                    // optional code for what happens after the alert controller has finished presenting
                }
            }
        })
        
        loading = false
        
        TwitterClient.sharedInstance?.limitStatus()
    }
    
    func loadUser() {
        print("load user")
        User.reloadUser()
        profileImageView.setImageWith(User.currentUser?.profileUrl as! URL)
        profileImageView.layer.cornerRadius = 8.0
        profileImageView.clipsToBounds = true
        
    
        profileImageView.image = #imageLiteral(resourceName: "profile-Icon")
       
        TwitterClient.sharedInstance?.getProfileBanner(screenname: User.currentUser?.screenname as! String, success: { (url: URL) in
            self.profileBackgroundImageView.setImageWith(url)
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })

        
        /*if let textColor = User.currentUser?.textColor {
            nameLabel.textColor = textColor
            usernameLabel.textColor = textColor
            
            tweetsLabel.textColor = textColor
            followersLabel.textColor = textColor
            followingLabel.textColor = textColor
            
            tweetNumberLabel.textColor = textColor
            followerNumberLabel.textColor = textColor
            followingNumberLabel.textColor = textColor
        }*/
        
        
        self.nameLabel.text = User.currentUser?.name as String!
        self.usernameLabel.text = "@\((User.currentUser?.screenname as String!)!)"
        
        tableView.reloadData()
        
        numberTapped()
    }
    
    /*func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (User.tweets != nil && !isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                if wait >= 20 {
                    // Code to load more results
                    self.loadData(reload: false, showError: true)
                    self.tableView.reloadData()
                }
                wait += 1
                print(wait)
            }
        }
    }*/
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        loadData(reload: true, showError: true)
        
        // Reload the tableView now that there is new data
        tableView.reloadData()
        
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
    }
    
    @IBAction func replyButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "reply", sender: (sender as! UIButton).superview?.superview as! TweetCell)
    }
    
    @IBAction func nameButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "userDetail", sender: (sender as! UIButton).superview?.superview as! TweetCell)
    }

    @IBAction func didTap(_ sender: Any) {
        performSegue(withIdentifier: "userDetail", sender: (sender as! UITapGestureRecognizer).view?.superview?.superview as! TweetCell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tweetDetail" {
            let destination = segue.destination as! TweetDetailViewController
            
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            destination.tweet = User.tweets![indexPath!.row]
            tableView.deselectRow(at: indexPath!, animated: true)
        } else if segue.identifier == "userDetail" {
            let destination = segue.destination as! UserDetailViewController
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            destination.user = User.tweets![indexPath!.row].owner
        } else if segue.identifier == "userDetailSelf" {
            let destination = segue.destination as! UserDetailViewController
            destination.user = User.currentUser
        } else if segue.identifier == "reply" {
            let destination = segue.destination as! ComposeTweetViewController
            
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            destination.preText = "@\((User.tweets![indexPath!.row].owner!.screenname)!) "
            destination.user = User.tweets![indexPath!.row].owner!
        } else if segue.identifier == "followerList" {
            let destination = segue.destination as! UserListViewController
            
            destination.original = User.currentUser!
            destination.type = "followers"
        }
    }
    
    func numberTapped() {
        if numbersShortened {
            tweetNumberLabel.text = "\((User.currentUser?.numTweets)!)"
            followerNumberLabel.text = "\((User.currentUser?.numFollowers)!)"
            followingNumberLabel.text = "\((User.currentUser?.numFollowing)!)"
            numbersShortened = false
        } else {
            tweetNumberLabel.text = formatNumbers(number: User.currentUser?.numTweets)
            followerNumberLabel.text = formatNumbers(number: User.currentUser?.numFollowers)
            followingNumberLabel.text = formatNumbers(number: User.currentUser?.numFollowing)
            numbersShortened = true
        }
    }
    
    func tweetTapped() {
        performSegue(withIdentifier: "userDetailSelf", sender: self)
    }
    
    func followersTapped() {
        performSegue(withIdentifier: "followerList", sender: self)
    }
    
    func followingTapped() {
        performSegue(withIdentifier: "followingList", sender: self)
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
    
}
