//
//  OnListTableViewCell.swift
//  chatDare
//
//  Created by Ramon Yepez on 12/20/21.
//

import UIKit

class OnListTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    
    @IBOutlet weak var imageStack: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
