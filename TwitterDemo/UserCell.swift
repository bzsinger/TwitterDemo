//
//  UserCell.swift
//  TwitterDemo
//
//  Created by Benny Singer on 3/5/17.
//  Copyright © 2017 Benjamin Singer. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    
    var user: User? {
        didSet {
            print("user cell set")
            profileImageView.setImageWith((user?.profileUrl)! as URL)
            profileImageView.layer.cornerRadius = 8.0
            profileImageView.clipsToBounds = true
            nameButton.setTitle(user?.name as String?, for: .normal)
            usernameLabel.text = "@" + (user?.screenname as String?)!
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
