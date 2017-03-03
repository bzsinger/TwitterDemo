//
//  ComposeTweetViewController.swift
//  TwitterDemo
//
//  Created by Benny Singer on 3/2/17.
//  Copyright © 2017 Benjamin Singer. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var topBar: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var charactersLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //topBar.backgroundColor = UINavigationController.bar
        UIApplication.shared.statusBarStyle = .default
        tweetTextView.text = ""
        tweetTextView.becomeFirstResponder()
        tweetTextView.delegate = self
        
        profileImageView.setImageWith(User.currentUser?.profileUrl as! URL)
        profileImageView.layer.cornerRadius = 8.0
        profileImageView.clipsToBounds = true
        nameLabel.text = User.currentUser?.name as String?
        usernameLabel.text = User.currentUser?.screenname as String?
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        charactersLabel.text = "\(140 - tweetTextView.text.characters.count)"
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func tweetButtonPressed(_ sender: Any) {
        TwitterClient.sharedInstance?.postTweet(tweet: tweetTextView.text, success: { (tweet:Tweet) in
            User.tweets?.append(tweet) 
            self.dismiss(animated: true, completion: nil)
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
