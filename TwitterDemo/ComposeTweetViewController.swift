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
    var countColor: UIColor?
    @IBOutlet weak var tweetTextView: UITextView!
    
    var preText = ""
    var user: User? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        //topBar.backgroundColor = UINavigationController.bar
        UIApplication.shared.statusBarStyle = .default
        tweetTextView.text = preText
        tweetTextView.becomeFirstResponder()
        tweetTextView.delegate = self
        
        profileImageView.setImageWith(User.currentUser?.profileUrl as! URL)
        profileImageView.layer.cornerRadius = 8.0
        profileImageView.clipsToBounds = true
        nameLabel.text = User.currentUser?.name as String?
        usernameLabel.text = User.currentUser?.screenname as String?
        
        countColor = charactersLabel.textColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        charactersLabel.text = "\(140 - tweetTextView.text.characters.count)"
        if 140 - textView.text.characters.count < 0 {
            charactersLabel.textColor = UIColor.red
        } else {
            charactersLabel.textColor = countColor
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func tweetButtonPressed(_ sender: Any) {
        if tweetTextView.text.characters.count > 140 {
            let alertController = UIAlertController(title: "Too Long", message: "Your Tweet is excessively verbose.", preferredStyle: .alert)
            
            // create a cancel action
            let cancelAction = UIAlertAction(title: "Fine, I'll shorten it.", style: .cancel) { (action) in
                // handle cancel response here. Doing nothing will dismiss the view.
            }
            // add the cancel action to the alertController
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true) {
                // optional code for what happens after the alert controller has finished presenting
            }
            return
        }
        
        if preText != "" {
            TwitterClient.sharedInstance?.postTweet(tweet: tweetTextView.text, response: true, id: 0, success: { (tweet:Tweet) in
                User.tweets?.insert(tweet, at: 0)
                //print("appended")
                self.dismiss(animated: true, completion: nil)
            }, failure: { (error: Error) in
                print(error.localizedDescription)
            })
            return
        }
        
        TwitterClient.sharedInstance?.postTweet(tweet: tweetTextView.text, response: false, id: 0, success: { (tweet:Tweet) in
            User.tweets?.insert(tweet, at: 0)
            //print("appended")
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
