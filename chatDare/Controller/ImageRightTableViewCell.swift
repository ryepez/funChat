//
//  ImageRightTableViewCell.swift
//  chatDare
//
//  Created by Ramon Yepez on 11/7/21.
//

import UIKit

class ImageRightTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.autoresizingMask = .flexibleHeight
    }
    
    let containerView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true // this will make sure its children do not go out of the boundary
        return view
    }()
    
    
    let countryImageView:UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill // without this your image will shrink and looks ugly
        img.translatesAutoresizingMaskIntoConstraints = false
        img.clipsToBounds = true
        return img
    }()
    
    let dateLabel:UILabel = {
         let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9)
         //label.textColor = .black
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
     }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(containerView)
        self.contentView.addSubview(countryImageView)
        self.contentView.addSubview(dateLabel)

       
     
        containerView.topAnchor.constraint(equalTo:self.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo:self.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo:self.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo:self.bottomAnchor).isActive = true
       
        
        //containerView.heightAnchor.constraint(equalToConstant:100).isActive = true
     
     
     //right case
     countryImageView.widthAnchor.constraint(equalToConstant:95).isActive = true
     countryImageView.heightAnchor.constraint(equalToConstant:95).isActive = true
     countryImageView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-15).isActive = true
    countryImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true

        
        
  //  countryImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
  //  countryImageView.bottomAnchor.constraint(equalTo: self.dateLabel.topAnchor).isActive = true
        
    dateLabel.topAnchor.constraint(equalTo: self.countryImageView.bottomAnchor, constant: 5).isActive = true
    dateLabel.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-15).isActive = true
    dateLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant:-5).isActive = true
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
}
