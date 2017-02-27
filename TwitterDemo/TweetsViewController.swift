//
//  TweetsViewController.swift
//  TwitterDemo
//
//  Created by Benny Singer on 2/24/17.
//  Copyright © 2017 Benjamin Singer. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var tweets: [Tweet]?
    @IBOutlet weak var tableView: UITableView!
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var wait = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension //use AutoLayout
        tableView.estimatedRowHeight = 120 //only used for scrollbar height dimension
        
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        loadData(reload: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = tweets {
            return tweets.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tweets == nil { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = tweets![indexPath.row]
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonClicked(_ sender: Any) {
        TwitterClient.sharedInstance?.logout()
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func loadData(reload: Bool) {
        if isMoreDataLoading { return }
        isMoreDataLoading = true
        TwitterClient.sharedInstance?.homeTimeline(tweets: tweets, reload: reload, success: { (tweets: [Tweet]) in
            if self.tweets == nil || reload == true {
                self.tweets = tweets
            } else {
                self.tweets! += tweets
            }
            self.tableView.reloadData()
            
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
        
        // Update flag
        self.isMoreDataLoading = false
        // Stop the loading indicator
        self.loadingMoreView!.stopAnimating()
        wait = 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (tweets != nil && !isMoreDataLoading) {
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
                    self.loadData(reload: false)
                    self.tableView.reloadData()
                }
                wait += 1
                print(wait)
            }
        }
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        loadData(reload: true)
            
        // Reload the tableView now that there is new data
        tableView.reloadData()
            
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
    }
}
