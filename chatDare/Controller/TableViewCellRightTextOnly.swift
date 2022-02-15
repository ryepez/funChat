//
//  TableViewCellRightTextOnly.swift
//  chatDare
//
//  Created by Ramon Yepez on 12/17/21.
//

import UIKit

class TableViewCellRightTextOnly: UITableViewCell {

    
    
    @IBOutlet weak var messageStackView: UIStackView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var dateSentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func controlContains() {
                    
            messageStackView.backgroundColor = UIColor(red: 0.56, green: 0.38, blue: 0.77, alpha: 1.00)
            dateSentLabel.textAlignment = .right
        


        }

}
