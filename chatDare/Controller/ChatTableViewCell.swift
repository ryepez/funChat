//
//  ChatTableViewCell.swift
//  chatDare
//
//  Created by Ramon Yepez on 9/27/21.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var imageV: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var imageViewMessage: UIImageView!
    
    @IBOutlet weak var messageStackView: UIStackView!
    
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet var contrainRightCase: NSLayoutConstraint!
    @IBOutlet var cotrainLeftCase: NSLayoutConstraint!
        
    @IBOutlet weak var dateSentLabel: UILabel!
    
    
    @IBOutlet var testContaint: NSLayoutConstraint!
    
    //contains that need to turn off for the message from the right size
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
       // cotrainLeftCase.isActive = false
        //contrainRightCase.isActive = false
        //rightConstrainImage.isActive = false
        //leftImageConstraint.isActive = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }
    
    func imageResize() {
        imageViewMessage.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func controlContains(messageSent: Bool) {
        
        testContaint.isActive = false

     //   if messageSent {
            
      //      testContaint.isActive = false

        //    contrainRightCase.isActive = true
          //  cotrainLeftCase.isActive = false
           // contrainRightCase.constant = 14
          //  messageStackView.backgroundColor = UIColor(red: 0.56, green: 0.38, blue: 0.77, alpha: 1.00)
       //     dateSentLabel.textAlignment = .right


      //  } else {
            
            testContaint.isActive = true

            contrainRightCase.isActive = false
            cotrainLeftCase.isActive = true
            messageStackView.backgroundColor = UIColor(red:0.23, green:0.57, blue:0.80, alpha:1.0)
            dateSentLabel.textAlignment = .left


    //    }
        
        
    }
    

    
    

}
