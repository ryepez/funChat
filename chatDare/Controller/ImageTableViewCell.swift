//
//  ImageTableViewCell.swift
//  chatDare
//
//  Created by Ramon Yepez on 11/7/21.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
       
       let containerView:UIView = {
           let view = UIView()
           view.translatesAutoresizingMaskIntoConstraints = false
           view.clipsToBounds = true // this will make sure its children do not go out of the boundary
           return view
       }()
       
       let profileImageView:UIImageView = {
           let img = UIImageView()
           img.contentMode = .scaleAspectFill // image will never be strecthed vertially or horizontally
        img.translatesAutoresizingMaskIntoConstraints = false // enable autolayout
        img.layer.cornerRadius = 17.5
           img.clipsToBounds = true
           return img
       }()
       
    let nameLabel:UILabel = {
         let label = UILabel()
       // label.font = UIFont(name:"Raleway", size:12)
         //label.textColor = .black
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
     }()
    
    let dateLabel:UILabel = {
         let label = UILabel()
      //  label.font = UIFont(name:"Raleway", size:9)
         //label.textColor = .black
         label.translatesAutoresizingMaskIntoConstraints = false
         return label
     }()
       
       let countryImageView:UIImageView = {
           let img = UIImageView()
           img.contentMode = .scaleAspectFill // without this your image will shrink and looks ugly
           img.translatesAutoresizingMaskIntoConstraints = false
           img.clipsToBounds = true
           return img
       }()

       override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
           super.init(style: style, reuseIdentifier: reuseIdentifier)
           
            self.contentView.addSubview(containerView)
            self.contentView.addSubview(nameLabel)
            self.contentView.addSubview(profileImageView)
            self.contentView.addSubview(dateLabel)
            self.contentView.addSubview(countryImageView)

        
        
        containerView.topAnchor.constraint(equalTo:self.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo:self.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo:self.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo:self.bottomAnchor).isActive = true

        
        //controls the size of profile image
        profileImageView.widthAnchor.constraint(equalToConstant:40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant:40).isActive = true
        

        profileImageView.topAnchor.constraint(equalTo:self.contentView.topAnchor, constant:5).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant:10).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: self.nameLabel.topAnchor).isActive = true
           
  
      //  containerView.heightAnchor.constraint(equalToConstant:100).isActive = true

        //nameLabel.topAnchor.constraint(equalTo:self.profileImageView.bottomAnchor).isActive = true
        nameLabel.centerXAnchor.constraint(equalTo:self.profileImageView.centerXAnchor).isActive = true
      
        nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -62).isActive = true
           
        nameLabel.widthAnchor.constraint(equalToConstant:40).isActive = true

           
           
           
        countryImageView.widthAnchor.constraint(equalToConstant:100).isActive = true
        countryImageView.heightAnchor.constraint(equalToConstant:100).isActive = true
        countryImageView.leadingAnchor.constraint(equalTo:self.profileImageView.trailingAnchor, constant:10).isActive = true
        countryImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        //countryImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
      //  countryImageView.bottomAnchor.constraint(equalTo: self.dateLabel.topAnchor).isActive = true
        
        
    dateLabel.topAnchor.constraint(equalTo: self.countryImageView.bottomAnchor, constant: 5).isActive = true
   
    //    dateLabel.topAnchor.constraint(equalTo: self.countryImageView.bottomAnchor).isActive = true
   // dateLabel.leadingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:10).isActive = true
        
    dateLabel.leadingAnchor.constraint(equalTo:self.profileImageView.trailingAnchor, constant:10).isActive = true
        
        
    //dateLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    dateLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant:-5).isActive = true
        /* right case
        countryImageView.widthAnchor.constraint(equalToConstant:95).isActive = true
        countryImageView.heightAnchor.constraint(equalToConstant:95).isActive = true
     
        countryImageView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor, constant:-20).isActive = true
        countryImageView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor).isActive = true
 
 */
       }
       
       required init?(coder aDecoder: NSCoder) {
           
           super.init(coder: aDecoder)
       }

}
