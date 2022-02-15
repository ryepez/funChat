//
//  CreateChatViewController.swift
//  chatDare
//
//  Created by Ramon Yepez on 12/1/21.
//

import UIKit
import Firebase


class CreateChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var buttonConstraint: NSLayoutConstraint!
    @IBOutlet weak var textToSendView: UITextView!
    // db reference
    var ref: DatabaseReference!
    
    // variable that contains the people select for chat
    var selected: [String] = []
    
    //struc of contacts
    var contactos: [Contact]  = []
    
    //user information
    var weHaveData = Bool()
   
    var textIsNoEmply = false {
        didSet {
            print(textIsNoEmply)
        }
    }

    var displayName: String = ""
    var userID: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
      
        configDB { userInfo in
            self.contactos = userInfo
            //filter current user from contact list
            self.contactos = self.contactos.filter{$0.userName != self.displayName}
            self.contactos =  self.contactos.sorted{$0.userName.lowercased() < $1.userName.lowercased() }
            
            self.tableView.reloadData()
        }
        
        //user info
        chatButton.isEnabled = false
        displayName =  Auth.auth().currentUser?.email?.components(separatedBy: "@")[0] ?? "?User?"
        userID = Auth.auth().currentUser!.uid
      
        textToSendView.delegate = self
        textToSendView.layer.cornerRadius = 15
        textToSendView.layer.borderWidth = 0.2
        textToSendView.layer.borderColor = UIColor.gray.cgColor
        textToSendView.textColor = .darkGray

        //keyboard notification
        keyboardNotifications()
        
    }
    
    func configDB(completion: @escaping ([Contact]) -> Void) {
        
        var arrayOfValues: [Contact] = []
        
        ref = Database.database().reference()
        
     /*  to be user latter when each person has a contact list for test right now we will read all users
        ref.child("usersInfo").child(Auth.auth().currentUser!.uid).child("contacts").getData { error, DataSnapshot in
            
            guard error == nil else {return}
            
            let dic = DataSnapshot.value as! [String:Any]
            
            for index in dic {
                
                let userInfo =  Contact(userName: index.key, isSelected: false, userKey: index.value as! String)
                
                arrayOfValues.append(userInfo)
            }
            
            completion(arrayOfValues)
        }
 
 */
        ref.child("usersInfo").queryOrderedByKey().getData { error, snapshot in
          
            guard error == nil else {return}

            let values = snapshot.value as! [String: Any]
           
            for item in values.keys {
               
                let each = values[item] as! [String: Any]
                let userName = each["userName"] as! String
                let userInfo = Contact(userName: userName, isSelected: false, userKey: item)
                arrayOfValues.append(userInfo)

            }
    
            completion(arrayOfValues)
            
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        let usernameToUpdate = contactos[indexPath.row].userName
        
        contactos[indexPath.row].isSelected = true
        
        selected.append(usernameToUpdate)

        if contactos[indexPath.row].isSelected {
                cell.accessoryType = .checkmark
           }
        

        weHaveData = !selected.isEmpty
                
        if weHaveData {
            if textIsNoEmply {
                chatButton.isEnabled = true
            }
        } else {
            chatButton.isEnabled = false
        }

 
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {

        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!

        contactos[indexPath.row].isSelected = false

        if !contactos[indexPath.row].isSelected  {
            cell.accessoryType = .none
        }
        
        let usernameToUpdate = contactos[indexPath.row].userName
        
        selected.removeAll(where: {$0 == usernameToUpdate})
        
        weHaveData = !selected.isEmpty
        
      
        chatButton.isEnabled = weHaveData
       
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String?
    {
      return "Contacts"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell  = tableView.dequeueReusableCell(withIdentifier: "friends")

        let contacts = contactos[indexPath.row]
        
        cell?.textLabel!.text = contacts.userName

       
      if contacts.isSelected {
           cell?.accessoryType = .checkmark
       } else {
        cell?.accessoryType = .none

       }
        
        return cell!
    }
    
    
    @IBAction func createChat(_ sender: UIButton) {
        
        createChannel(usersToAddToChat: self.selected, message: textToSendView.text!)
        
    }
    
    
   
    @IBAction func dimiss(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    func createChannel(usersToAddToChat: [String], message: String) {
        
        
        //create empty dictionary and auto generated key for chatID
        var mdata = [String: Any]()
        var mdataMessage = [String: Any]()

        let key = ref.childByAutoId()
        
        //get the get user profile URL and create first message for channel tableView
        //competion hander needed!
        ref.child("usersInfo").child(Auth.auth().currentUser!.uid).child("profileFotoURL").getData { [self] error, db in
            
            //profile URL
            let path = db.value as! String
                         
            switch selected.count {
            case 1:
                
            mdata = ["text" : message, "dateSent": [".sv": "timestamp"], "tittle": "\(selected[0]) & \(self.displayName)", "readBy": [self.displayName:true], "profileFotoURL": path]
                
            mdataMessage = ["dateSent": [".sv": "timestamp"], "text":message, "userID": displayName, "profileFotoURL": path] as [String : Any]

            case 2:
                
            mdata = ["text" :  message, "dateSent": [".sv": "timestamp"], "tittle": "\(selected[0]), \(selected[1]) & \(self.displayName)", "readBy": [self.displayName:true], "profileFotoURL": path]
                                
            mdataMessage = ["dateSent": [".sv": "timestamp"], "text":message, "userID": displayName, "profileFotoURL": path] as [String : Any]

            
            default:
            
            mdata = ["text" :  message, "dateSent": [".sv": "timestamp"], "tittle": "\(selected[0]) & \(selected[1]) +\(selected.count-2)", "readBy": [self.displayName:true], "profileFotoURL": path]
                
            mdataMessage = ["dateSent": [".sv": "timestamp"], "text":message, "userID": displayName, "profileFotoURL": path] as [String : Any]

           
            }
            
            if let keyOfChannel = key.key {
                
            ref.child("channels").child(keyOfChannel).setValue(mdata)
            ref.child("messages").child(keyOfChannel).childByAutoId().setValue(mdataMessage)

            //fix userID
                //guard let userID = Auth.auth().currentUser?.uid else { return }
                let userInfo = [userID: true]

                let userIDPartOfGroup = [keyOfChannel: true]
          //  ref.child("channels").child(keyOfChannel).child("details").setValue(mdata)
            ref.child("members").child(keyOfChannel).setValue(userInfo)
            ref.child("chatroomUsers").child(userID).updateChildValues(userIDPartOfGroup)

           // ref.child("chatroomUsers").child(userID).updateChildValues(userIDPartOfGroup)
                
                
            //send users name to be converted in to firebase keys and added to member and chatRoomUsers
                for userToAdd in usersToAddToChat {
                    
                    let index = contactos.firstIndex (where: {$0.userName == userToAdd})
                    
                    let userID = contactos[index!].userKey
                    let userInfo = [userID: true]

                    ref.child("chatroomUsers").child(userID).updateChildValues(userIDPartOfGroup)
                    ref.child("members").child(keyOfChannel).updateChildValues(userInfo)
                }
            
              //  self.tranferToChatViewController(channelKey: keyOfChannel)
                dismiss(animated: true, completion: nil)
            }
            
            
        }
        
    }
    
    func tranferToChatViewController(channelKey: String) {
        
        let controller: ViewController
        
        controller = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
         controller.userName = displayName
        
        // sending treadID
         controller.treadID = channelKey
        
        
        
        navigationController?.pushViewController(controller, animated: true)
        
    
    }
    
    func keyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        
        let info = sender.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        buttonConstraint.constant = keyboardSize
            let duration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue

            UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
            
    }
    
    
    
}


extension CreateChatViewController: UITextViewDelegate {
    
    // sent button and enable and unable
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let text = (textView.text! as NSString).replacingCharacters(in: range, with: text)
     
        textIsNoEmply =  !text.isEmpty ? true : false
    
        if !textIsNoEmply {
            chatButton.isEnabled = false
        }

        if weHaveData {
            if textIsNoEmply {
                chatButton.isEnabled = true
            }
        } else {
            chatButton.isEnabled = false
        }
      
        
        return true
    }
    
}
