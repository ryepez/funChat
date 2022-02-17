//
//  ViewController.swift
//  chatDare
//
//  Created by Ramon Yepez on 9/6/21.
//

import UIKit
import Firebase
import FirebaseStorageUI

class ViewController: UIViewController {
   
    /// The canal currently being seen
    var currentCanal: Canal!
    var dataController:DataController!
    
    let signupControllerIdentifier = "ListOfPeopleViewController"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageMessage: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messagtTextView: UITextView!
    @IBOutlet var bottomConstraintForKeyboard: NSLayoutConstraint!
    @IBOutlet weak var stackWithText: UIStackView!
    
    var firstTimeMessageLoad = Bool()
    var mg: [Messaj] = []
    var orderBydata: Array<Dictionary<String, [Messaj]>.Element> = []
    var datasetToSort: Array<Dictionary<String, [Messaj]>.Element> = []

    //properties
    var ref: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle!
    
    var messages: [DataSnapshot]! = []
    
    var treadID = String()
    // auth handers
    
   // fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    //getting on a few message at time
            
    //reference to the storage
    var storageRef: StorageReference!

    var user: User?
    var displayName = "Anonymous"
    var userName = String()
    var hasimage = Bool()
    
    var userImageURL = String()
    var animatedScrolling = Bool()
    
    var addingNewMessage = Bool()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        messagtTextView.delegate = self
        messagtTextView.layer.cornerRadius = 15
        messagtTextView.layer.borderWidth = 0.2
        messagtTextView.layer.borderColor = UIColor.gray.cgColor
        messagtTextView.text = "Message"
        messagtTextView.textColor = .darkGray
     
        //settingUp TableView
        tableViewSetup()
        
        //database and storage configuration
        let treadIDToUse = treadID
        
        configureStorage()
        configureDB(chatID: treadIDToUse)

        displayName = userName
        sendButton.isEnabled = false

        //makeAsRead(user: userName)
        firstTimeMessageLoad = true
       
        //navigation back to normal
        getNavigationBackToNormal()
        
        //keyboard notification
        keyboardNotifications()
       
        
        self.navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(systemName: "person.3.fill"), style: .plain, target: self, action:  #selector(listOfPeople))
        
        //
    }
  
    @objc func listOfPeople() {
        
        let controller: ListOfPeopleViewController
        controller = storyboard?.instantiateViewController(withIdentifier: signupControllerIdentifier) as! ListOfPeopleViewController
        controller.chatID = treadID
        
        //coreData
        controller.canal = currentCanal
        controller.dataController = dataController
        
        present(controller, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //navigation back to normal
        getNavigationBackToNormal()
    }
    
    fileprivate func tableViewSetup() {
        //tableView Setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        tableView.isUserInteractionEnabled = true
        
        //registering custom cell
        tableView.register(ImageTableViewCell.self, forCellReuseIdentifier: "ImageTableViewCell")
        tableView.register(ImageRightTableViewCell.self, forCellReuseIdentifier: "ImageRightTableViewCell")
    }




    @objc func keyboardWillShow(sender: NSNotification) {
        
        let info = sender.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
            bottomConstraintForKeyboard.constant = keyboardSize
            let duration: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue

            UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
            
            scrollToBottomMessage(scrollingAnimantion: false)
    }
    
   
      func keyboardNotifications() {
          
          NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
      }
    
    
    func makeAsRead(user: String) {
        let userRef = ref.child("channels").child(treadID)
        userRef.child("readBy").updateChildValues([user: true])
    }
  
    
    func configureStorage() {
        
        storageRef = Storage.storage().reference()
    }
    
   
    func sendPhotoMessage(photoData: Data) {
        
        //starting activity indicator
        let container: UIView = UIView()
        container.frame = CGRect(x: 0, y: 0, width: 80, height: 80) // Set X and Y whatever you want
        container.backgroundColor = .clear

        let activityView = UIActivityIndicatorView(style: .large)
        activityView.center = self.view.center
        activityView.color = UIColor(red:0.23, green:0.57, blue:0.80, alpha:1.0)
        container.addSubview(activityView)
        self.view.addSubview(container)
        
        activityView.startAnimating()


        //build a path using the user id and timestam
        
        let imagePath = "chat_photos/" + Auth.auth().currentUser!.uid + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        print(imagePath)
        //metadata
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        //create a child note at imagepath with photoData and metada
        
        storageRef.child(imagePath).putData(photoData, metadata: metadata) {[weak self] (metadata, error) in
            
            guard let strongSelf = self else { return }
            
            if let error = error {
                self?.alertMaker(title: "🥺 Unable to load image", message: "\(error.localizedDescription)")
                print("error updaing: \(error.localizedDescription)")
                return
            }
            
            //user sendMessget to add imageURL to database
            strongSelf.sendURLtoDB(data: ["photoUrl" : strongSelf.storageRef.child((metadata?.path)!).description])
            
            activityView.stopAnimating()
            activityView.hidesWhenStopped = true
        }
        

        
    }
    
    func configureDB(chatID: String) {
        
        //getting a reference to the db
        ref = Database.database().reference()
        
        
        var numberOfMessages = 0
        var counter = 0
        
        
        Database.database().reference().child("messages").child(chatID).observe(DataEventType.value, with: { (snapshot) in
            numberOfMessages = Int(snapshot.childrenCount)
            print(numberOfMessages)
        })
        

        //adding the liciser to new messages
        
        _refHandle = ref.child("messages").child(chatID).observe(.childAdded) { [weak self] (snapshot: DataSnapshot) in
            
            guard let strongSelf = self else { return }
            let channelValue = snapshot.value as! [String:Any]
            let text = channelValue["text"] as! String
            let dateSet = channelValue["dateSent"] as! Double
            let userID = channelValue["userID"]  as! String
           
            //var imageUser = "person.fill.questionmark"
            let photoUrl = channelValue["photoUrl"] ?? "person.fill"
            let profileFotoURL = channelValue["profileFotoURL"] ?? "person.fill"
            
            //creating the stuct that holds the messages information
            let mesg = Messaj(text: text, dataForGroup: strongSelf.convertFireBaseToDate(serverTimestamp: dateSet), dateSent: strongSelf.convertFireBaseTime(serverTimestamp: dateSet), userID: userID, photoUrl: photoUrl as? String, profileFotoURL: profileFotoURL as? String)
            
            counter = counter + 1
        
            if counter == numberOfMessages {
                
                strongSelf.firstTimeMessageLoad = false
            
            }
            
            
            // Getting that data of the message and making a Dictionary
            let messageDate = mesg.dataForGroup
            let messageDictionary: Dictionary<String, [Messaj]>.Element
            
            messageDictionary.key = messageDate
            messageDictionary.value = [mesg]
            
            //if there is group for this message then appending to that group
            if let index = strongSelf.orderBydata.firstIndex(where: {$0.key == messageDate }) {
                
                strongSelf.orderBydata[index].value.append(mesg)
                
         
                if !strongSelf.firstTimeMessageLoad {
                    UIView.performWithoutAnimation {
                        strongSelf.tableView.reloadData()
                    }
                    strongSelf.scrollToBottomMessage(scrollingAnimantion: true)
                   
                    
                } else {
                    UIView.performWithoutAnimation {
                        strongSelf.tableView.reloadData()
                    }
                    
                    strongSelf.scrollToBottomMessage(scrollingAnimantion: false)

                }
          
                // if the data does not a group for the message than creata a new group
            } else {

                strongSelf.orderBydata.append(messageDictionary)
               
                
            
                if !strongSelf.firstTimeMessageLoad {
                    UIView.performWithoutAnimation {
                        strongSelf.tableView.reloadData()
                    }
                    strongSelf.scrollToBottomMessage(scrollingAnimantion: true)
                   
                } else {
                    UIView.performWithoutAnimation {
                        strongSelf.tableView.reloadData()
                    }
                    strongSelf.scrollToBottomMessage(scrollingAnimantion: false)
                   
                }
                
            }
         
            //make message as read by user
            strongSelf.makeAsRead(user: strongSelf.userName)
        }
        
        
    }
     
 
    deinit {
        //this is to remove the lisenser so we do not run of memory after this class get deinit
        ref.child("messages").child(treadID).removeObserver(withHandle: _refHandle)
        //remove lisne
      //  Auth.auth().removeStateDidChangeListener(_authHandle)
        
            print("deinit \(self)")
    }
    
    
   
    func curveUI(articulo: UIView, userPhone: Bool) {
        
        articulo.layer.cornerRadius = 20
        articulo.clipsToBounds = true
        
        if userPhone {
            
            // user phone case
            articulo.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        } else {
            //other user case
            articulo.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMaxXMaxYCorner]
        }

     
    }
    
    
    @IBAction func didSendMessage(_ sender: UIButton) {
        
        addingNewMessage = true
        animatedScrolling = true
               
        if !messagtTextView.text!.isEmpty {
           
              let data = ["text":  messagtTextView.text! as String]
              sendMessage(data: data)
          }
          
        messagtTextView.text = ""
        
    }
    
  
    func sendURLtoDB(data: [String:String]) {
        
        ref.child("usersInfo").child(Auth.auth().currentUser!.uid).child("profileFotoURL").getData { [self] error, db in
            
        let path = db.value as! String
        
        var message = ["dateSent": [".sv": "timestamp"], "userID": displayName, "text": "image", "profileFotoURL": path] as [String : Any]
        
        let messageTwo = ["dateSent": [".sv": "timestamp"], "text": "image", "readBy": [displayName: true], "profileFotoURL": path] as [String : Any]
        
        message[data.keys.first!] = data.values.first

         //   if let key = canal.key {
        ref.child("messages").child(treadID).childByAutoId().setValue(message)
        //add here the sent to the tableview will last message!
        ref.child("channels").child(treadID).updateChildValues(messageTwo)
           // }
            
            }
    }
    
    
    func sendMessage(data: [String:String]) {
        
        ref.child("usersInfo").child(Auth.auth().currentUser!.uid).child("profileFotoURL").getData { [self] error, db in
    
            
        let path = db.value as! String
        
        let textMessage = data.values.first! as String
            
        let message = ["dateSent": [".sv": "timestamp"], "text":textMessage, "userID": displayName, "profileFotoURL": path] as [String : Any]
        
        let messageTwo = ["dateSent": [".sv": "timestamp"], "text":textMessage, "readBy": [displayName: true], "profileFotoURL": path] as [String : Any]
        
           // if let key = canal.key {
        ref.child("messages").child(treadID).childByAutoId().setValue(message)
        ref.child("channels").child(treadID).updateChildValues(messageTwo)
          //  }
            
            }
    }
    
    @IBAction func didTapAddPhoto(_ sender: AnyObject) {
       
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
  


}

extension ViewController: UIGestureRecognizerDelegate {
    
    @objc func handleTapProfile(_ gesture: UITapGestureRecognizer){
        
    
        let tapLocation = gesture.location(in: self.tableView)
        
        if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
           
            if let cell = tableView.cellForRow(at: tapIndexPath) as? ChatTableViewCell {
            
            if cell.imageV.image != nil {
                
                if let DetailVC = self.storyboard?.instantiateViewController(withIdentifier: "BiggerImageViewController") as? BiggerImageViewController {
                    
                    if let image = cell.imageV.image {
                        DetailVC.imageToShow = image
                        
                        DetailVC.currentCanal = currentCanal
                        DetailVC.dataController = dataController
                        
                        if let urlToPut = cell.sd_imageURL?.absoluteString {
                            DetailVC.urlForImage = urlToPut
                        }
                        self.navigationController?.pushViewController(DetailVC,animated: true)

                        
                    }

                    
                }
            }
            
          
            }
            
            }
        
    }
    
    @objc func handleTapProfileWithImage(_ gesture: UITapGestureRecognizer){
        
        print("you pressed here")
    
    let tapLocation = gesture.location(in: self.tableView)
        
        if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
           
            if let cell = tableView.cellForRow(at: tapIndexPath) as? ImageTableViewCell {
        
            if cell.profileImageView.image != nil {

            if let DetailVC = self.storyboard?.instantiateViewController(withIdentifier: "BiggerImageViewController") as? BiggerImageViewController {
                
                if let image = cell.profileImageView.image {
                    
                    DetailVC.imageToShow = image
                    
                    DetailVC.currentCanal = currentCanal
                    DetailVC.dataController = dataController
                    
                    if let urlToPut = cell.sd_imageURL?.absoluteString {
                        DetailVC.urlForImage = urlToPut
                    }
                    
                    self.navigationController?.pushViewController(DetailVC,animated: true)

                }

                
            }
            
        }
            
            }
        }
        
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer){
        
    
    let tapLocation = gesture.location(in: self.tableView)
        
        if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
           
            if let cell = tableView.cellForRow(at: tapIndexPath) as? ImageRightTableViewCell {
                        
            if cell.countryImageView.image != nil {

            if let DetailVC = self.storyboard?.instantiateViewController(withIdentifier: "BiggerImageViewController") as? BiggerImageViewController {
                
                if let image =  cell.countryImageView.image {
                    
                    DetailVC.imageToShow = image
                    
                    DetailVC.currentCanal = currentCanal
                    DetailVC.dataController = dataController
                    
                    if let urlToPut = cell.sd_imageURL?.absoluteString {
                        DetailVC.urlForImage = urlToPut
                    }
                    
                    self.navigationController?.pushViewController(DetailVC,animated: true)
                    
                }

                
            }
                
            }
            
        }
        
        }
        
        
        
    }
    
    
    @objc func handleTapLeft(_ gesture: UITapGestureRecognizer){
        
    
    let tapLocation = gesture.location(in: self.tableView)
        
        if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
           
            if let cell = tableView.cellForRow(at: tapIndexPath) as? ImageTableViewCell {
            
            
            if cell.countryImageView.image != nil {

            if let DetailVC = self.storyboard?.instantiateViewController(withIdentifier: "BiggerImageViewController") as? BiggerImageViewController {
                
                if let image = cell.countryImageView.image {
                    
                    DetailVC.imageToShow = image
                    DetailVC.currentCanal = currentCanal
                    DetailVC.dataController = dataController
                    
                    if let urlToPut = cell.sd_imageURL?.absoluteString {
                        DetailVC.urlForImage = urlToPut
                    }
                    self.navigationController?.pushViewController(DetailVC,animated: true)

                    
            }

                
            }
            
            }
            
            }
        }
    }
    
}

extension ViewController: UITextViewDelegate {
    
    // sent button and enable and unable
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let text = (textView.text! as NSString).replacingCharacters(in: range, with: text)

        if !text.isEmpty{
            sendButton.isEnabled = true
            
        } else {
            sendButton.isEnabled = false
        }
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
       
        if textView.text == "Message" {
            messagtTextView.text = ""
            messagtTextView.textColor = .darkText
        }
                
        textView.becomeFirstResponder()
    }
    
}

extension ViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            // getting the image selected by the user
        if let image = info[.originalImage] as? UIImage,  let photoData = image.jpegData(compressionQuality: 0.5) {
            // call function to upload photo message
            sendPhotoMessage(photoData: photoData)
            
        }
            //dismissing the picker
            dismiss(animated: true, completion: nil)

        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollToBottomMessage(scrollingAnimantion: Bool) {
        
    if orderBydata.count == 0 {return}
                    
    let numberOfRows = tableView.numberOfRows(inSection: orderBydata.count-1)
    let bottomMessageIndex = IndexPath(row: numberOfRows-1, section:  orderBydata.count-1)
    self.tableView.scrollToRow(at: bottomMessageIndex, at: .bottom, animated: scrollingAnimantion)
        
    }
    
    


    func numberOfSections(in tableView: UITableView) -> Int {
        return orderBydata.count
    }
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return orderBydata[section].key
    }
    

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = NSTextAlignment.center
        header.textLabel?.text = header.textLabel?.text?.capitalized
        header.textLabel?.font = UIFont(name:"Raleway", size:14)
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
     
        return orderBydata[section].value.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let mensaje = orderBydata[indexPath.section].value[indexPath.row]
        let name = mensaje.userID
        let profileFotoURL = mensaje.profileFotoURL ?? "person.fill"
        let dataSent = mensaje.dateSent
        let text = mensaje.text
        //two cases has picture yes and no
        
        let hasimageURL = mensaje.photoUrl != "person.fill"
        let imageURL = mensaje.photoUrl
        let userMessageDirection = (displayName == name)

       
        switch (hasimageURL, userMessageDirection) {
     
        case (true, true):
            
            let cell =
            tableView.dequeueReusableCell(withIdentifier: "ImageRightTableViewCell", for: indexPath) as! ImageRightTableViewCell
            
            
            //adding gesture Recognizer for tapping the image once to see it bigger
           
            cell.countryImageView.isUserInteractionEnabled = true

            let tapImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            tapImageRecognizer.numberOfTapsRequired = 1
                    
            cell.countryImageView.addGestureRecognizer(tapImageRecognizer)
            
            
                // Convert Date to String
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
            cell.dateLabel.text = dataSent
            cell.dateLabel.font = UIFont(name:"Raleway", size:9)
            
            //please create a function for this
            cell.dateLabel.textColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.00)
    
            let gsReference = Storage.storage().reference(forURL:  imageURL!)

            cell.countryImageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            cell.countryImageView.sd_setImage(with: gsReference, placeholderImage: UIImage(systemName: "photo"))
            cell.countryImageView.sd_imageTransition = .flipFromTop
             
            curveUI(articulo: cell.countryImageView, userPhone: userMessageDirection)

            return cell
            
        case (true, false):
            
                    let cell =
                    tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as! ImageTableViewCell
            
            
            //adding gesture Recognizer for tapping the image once to see it bigger
           
            cell.countryImageView.isUserInteractionEnabled = true
            let tapImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapLeft))
            tapImageRecognizer.numberOfTapsRequired = 1
            cell.countryImageView.addGestureRecognizer(tapImageRecognizer)
            
            // adding geusture recongnizeer for tapping profile image
            
            
            // Convert Date to String
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
            
            cell.dateLabel.text = dataSent
            
            cell.dateLabel.font = UIFont(name:"Raleway", size:9)
            cell.dateLabel.textColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1.00)
            
            cell.nameLabel.font = UIFont(name:"Raleway", size:11)
            
     
            //please create a function for this
            if profileFotoURL !=  "person.fill" {
                
                
                //please create a function for this

                let gsReference = Storage.storage().reference(forURL:  profileFotoURL)
                cell.profileImageView.sd_setImage(with: gsReference, placeholderImage: UIImage(systemName: "person.fill"))
                cell.profileImageView.layer.cornerRadius = 20
            }
            
            //adding gesture Recognizer for tapping the image once to see it bigger
           
            cell.profileImageView.isUserInteractionEnabled = true
            let tapImageRecognizerProfle = UITapGestureRecognizer(target: self, action: #selector(handleTapProfileWithImage))
            
            tapImageRecognizerProfle.numberOfTapsRequired = 1
            cell.profileImageView.addGestureRecognizer(tapImageRecognizerProfle)
            
            cell.nameLabel.text = name

            //please create a function for this
            let gsf = Storage.storage().reference(forURL:  imageURL!)

            cell.countryImageView.sd_setImage(with: gsf, placeholderImage: UIImage(systemName: "person.fill"))
            
            curveUI(articulo: cell.countryImageView, userPhone: userMessageDirection)

                    return cell
                  
            //false, true
            //messageChatRight
            
        case (false, true):
            
            let cell =
            tableView.dequeueReusableCell(withIdentifier: "messageChatRight", for: indexPath) as! TableViewCellRightTextOnly
            
            cell.controlContains()
            
           curveUI(articulo: cell.messageStackView, userPhone: true)
            
            cell.messageStackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            cell.messageStackView.isLayoutMarginsRelativeArrangement = true
            cell.message.text = text
            cell.dateSentLabel.text = dataSent

            return cell

        case (false, false):
            
               let cell =
               tableView.dequeueReusableCell(withIdentifier: "messageChat", for: indexPath) as! ChatTableViewCell
            
            cell.controlContains(messageSent: userMessageDirection)
            
            curveUI(articulo: cell.messageStackView, userPhone: userMessageDirection)
            cell.messageStackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            cell.messageStackView.isLayoutMarginsRelativeArrangement = true
            cell.message.text = text
            
            // Convert Date to String
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        
        cell.dateSentLabel.text = dataSent
 
                if profileFotoURL !=  "person.fill" {
                
                    //please create a function for this
                let gsReference = Storage.storage().reference(forURL:  profileFotoURL)
                    
                cell.imageV.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                cell.imageV.sd_setImage(with: gsReference, placeholderImage: UIImage(systemName: "person.fill"))
                    cell.imageV.layer.cornerRadius = 20
                   cell.userName.text = name
                 
                }
                
            //adding gesture Recognizer for tapping the image once to see it bigger
           
            cell.imageV.isUserInteractionEnabled = true
            let tapImageRecognizerProfle = UITapGestureRecognizer(target: self, action: #selector(handleTapProfile(_:)))
            
            tapImageRecognizerProfle.numberOfTapsRequired = 1
            cell.imageV.addGestureRecognizer(tapImageRecognizerProfle)

            return cell
        }
        
    }
    
}

