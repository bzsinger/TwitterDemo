//
//  UserDetailViewController.swift
//  TwitterDemo
//
//  Created by Benny Singer on 2/28/17.
//  Copyright © 2017 Benjamin Singer. All rights reserved.
//

import UIKit

class UserDetailViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetNumberLabel: UILabel!
    @IBOutlet weak var followingNumberLabel: UILabel!
    @IBOutlet weak var followersNumberLabel: UILabel!
    
    var user: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImageView.setImageWith(user.profileUrl as! URL)
        profileImageView.layer.cornerRadius = 8.0
        profileImageView.clipsToBounds = true
        nameLabel.text = user.name as String!
        usernameLabel.text = "@\((user.screenname as String!)!)"
        tweetNumberLabel.text = formatFavoriteRetweetNumbers(number: user.numTweets)
        followersNumberLabel.text = formatFavoriteRetweetNumbers(number: user.numFollowers)
        followingNumberLabel.text = formatFavoriteRetweetNumbers(number: user.numFollowing)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func formatFavoriteRetweetNumbers(number: Int?) -> String {
        if number == nil { return "" }
        if number! > 1000000 {
            return "\(number! / 1000000)M"
        }
        if number! > 1000 {
            return "\(number! / 1000)K"
        }
        return "\(number!)"
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
