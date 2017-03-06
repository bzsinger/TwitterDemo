//
//  UserListViewController.swift
//  TwitterDemo
//
//  Created by Benny Singer on 3/5/17.
//  Copyright © 2017 Benjamin Singer. All rights reserved.
//

import UIKit

class UserListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var usersList: [User]?
    
    var original: User?
    
    var type: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if usersList == nil {
            return 0
        }
        return usersList!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if usersList == nil {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        cell.user = usersList![indexPath.row]
        return cell
    }
    
    func loadData() {
        if type == "followers" {
            TwitterClient.sharedInstance?.getFollowers(screenname: (original?.screenname)! as String, success: { (users: [User]) in
                self.usersList = users
                self.tableView.reloadData()
            }, failure: { (error: Error) in
                print(error.localizedDescription)
            })
        }
    }
    
    @IBAction func nameButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "userDetail", sender: (sender as! UIButton).superview?.superview as! UserCell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userDetail" {
            let destination = segue.destination as! UserDetailViewController
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: cell)
            destination.user = usersList?[(indexPath?.row)!]
        }
    }
}
