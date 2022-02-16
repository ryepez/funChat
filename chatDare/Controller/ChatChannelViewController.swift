//
//  ChatChannelViewController.swift
//  chatDare
//
//  Created by Ramon Yepez on 9/26/21.
//

import UIKit
import Firebase
import FirebaseStorageUI
import CoreData



class ChatChannelViewController: UIViewController {
 
    @IBOutlet weak var tableView: UITableView!
    
    
    //codeDate propeties
    //Data injection
    var dataController: DataController!
    //channel to store data
    var fetchedResultsController: NSFetchedResultsController<Canal>!

    
    //properties for db and storage 
    var ref: DatabaseReference!
    //reference to the storage
    var storageRef: StorageReference!

    fileprivate var _refHandle: DatabaseHandle!
    fileprivate var _refHandleTwo: DatabaseHandle!

    var channelContainer = [Channel]()
   
    // auth handers
   // fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    
    // singlinton place
    var user: User?
    var displayName = String()
    var userID = String()
    var userImageURL = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setting up the tableview and delegate
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.rowHeight = (view.frame.height/8)
        self.tableView.separatorStyle = .none

        //singleton function
        displayName =  Auth.auth().currentUser?.email?.components(separatedBy: "@")[0] ?? "?User?"
        userID = Auth.auth().currentUser!.uid
        
       
        
        //setting up db and storage
        configureDatabase(user: userID)
        configureStorage()
        
        //navigation back to normal
        getNavigationBackToNormal()
    
        checkingRunBefore()
    }
    

    override func viewWillAppear(_ animated: Bool) {
    
       // checkingRunBefore()

        //singleton
        userID = Auth.auth().currentUser!.uid
        
        //setting the database to update when users add new messages
        configureChange(user: userID)
        
        //navigation back to normal
        getNavigationBackToNormal()
        
        tableView.reloadData()
    }
    
    func checkingRunBefore() {
        
        let isSliderSet = UserDefaults.standard.bool(forKey: "firtRun")
        
        if isSliderSet {
            //getting channel data from coreData if coredata is not emply
            UserDefaults.standard.set(false, forKey: "firtRun")
            print("not fetching data until next time")
            
        } else {
            setUpFetchedResultsController()
        }

    }

    
    /*
    func configureAuth() {
        //Firebase Authentication
        
        _authHandle = Auth.auth().addStateDidChangeListener({(auth: Auth, user: User?) in
        //refresh table data
            self.channels.removeAll(keepingCapacity: false)
            self.tableView.reloadData()
            
            //check if there is current user
            if let activeUser = user {
                //check if the current app user is the current FIRUser
                if self.user != activeUser {
                    self.user = activeUser
                    self.userID = activeUser.uid
                    let name = user!.email!.components(separatedBy: "@")[0]
                    self.displayName = name
                } else {
                    //user must sign in
                
                    let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                    
                    
                    self.present(loginVC, animated: true, completion: nil)
                }
            }
            
        })
    }
    
 */
  
    func configureDatabase(user: String) {
        
        var counter = 0
        var numberOfChannels = 0
            
        Database.database().reference().child("chatroomUsers").child(user).observe(DataEventType.value, with: { (snapshot) in
            numberOfChannels = Int(snapshot.childrenCount)
        })
        
        
        ref = Database.database().reference()
        
        //creating a lisenser  where to lisen to changes
      
      _refHandle = ref.child("chatroomUsers").child(user).observe(.childAdded) { [self] (snapShot: DataSnapshot) in
                
            self.ref.child("channels").child(snapShot.key).getData(completion: { error, DataSnapshotDetails in
                
                if   (DataSnapshotDetails.value as? [String:Any]) == nil {
                    print("no data")
                } else {
                    
                    let channelValue = DataSnapshotDetails.value as! [String:Any]
                    let text = channelValue["text"] as! String
                    let dateSet = channelValue["dateSent"] as! Double
                    let tittle = channelValue["tittle"] as! String
                    let readBy = channelValue["readBy"]  as! [String:Any]
                    //var imageUser = "person.fill.questionmark"
                    let userProfile = channelValue["profileFotoURL"] as? String
                    
                    let channelKey = DataSnapshotDetails.key

                    let containerBox = Channel(key: channelKey, text: text, dateSent: dateSet, tittle: tittle, readBy: readBy, userProfile: userProfile ?? "person.fill")
                   self.channelContainer.append(containerBox)
                    
                    //saving into coreData
                    self.addChannel(id: channelKey)


                }
            
                counter = counter + 1
                
                if counter == numberOfChannels {
                    
                    self.channelContainer = self.channelContainer.sorted(by: { $0.dateSent > $1.dateSent })
                    
                    UIView.performWithoutAnimation {
                        self.tableView.reloadData()
                    }
                    
                }
                
            })

            }
        
    }
    
    func configureChange(user: String) {
        
        
        ref = Database.database().reference()
        //creating a lisenser  where to lisen to changes
       ref.child("chatroomUsers").child(user).observe(.childAdded) { [self] (snapShot: DataSnapshot) in
            

           self._refHandleTwo = self.ref.child("channels").child(snapShot.key).observe(.value) { (snapShot: DataSnapshot) in
                        
               
               if   (snapShot.value as? [String:Any]) == nil {
                   print("no data")
               } else {
                   
                   let channelValue = snapShot.value as! [String:Any]

                    let text = channelValue["text"] as! String
                    let dateSent = channelValue["dateSent"] as! Double
                    let tittle = channelValue["tittle"] as! String
                    let readBy = channelValue["readBy"] as! [String:Any]
                    let userProfile = channelValue["profileFotoURL"] as! String

                    
                    let channelKey = snapShot.key
                    
                    
                    // old way
                    let channelChange = Channel(key: channelKey, text: text, dateSent: dateSent, tittle: tittle, readBy: readBy, userProfile: userProfile )
                        
                    
                    if let location = channelContainer.firstIndex(where: { $0.key == channelChange.key }) {
                        
                        // you know that location is not nil here
                        self.channelContainer.remove(at: location)
                        self.channelContainer.insert(channelChange, at: 0)

                        self.channelContainer = self.channelContainer.sorted(by: { $0.dateSent > $1.dateSent })
                        
                        UIView.performWithoutAnimation {
                            self.tableView.reloadData()

                        }
                   
               }
          
                    
                
                }
                
               

            }
        
        
    
    }
        
        
    }
    

    func configureStorage() {
        
        storageRef = Storage.storage().reference()
    }
    
    
    @IBAction func logOut(_ sender: UIButton) {
        
        do
           {
               try Auth.auth().signOut()
            
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let logInVC = storyboard.instantiateViewController(identifier: "LoginViewController")
        
        //to change the root view controller calling the object created in scene delegete
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(logInVC)
           }
           catch let error as NSError
           {
               print(error.localizedDescription)
           }
      
    }
    
    
    deinit {
        //this is to remove the lisenser so we do not run of memory after this class get deinit
       ref.child("chatroomUsers").removeObserver(withHandle: _refHandle)
        //remove lisne
    //   Auth.auth().removeStateDidChangeListener(_authHandle)
        ref.child("channels").removeAllObservers()
        print("deinit")

    }
    

 
   @IBAction func addImage(_ sender: UIButton) {
       
       let picker = UIImagePickerController()
       picker.delegate = self
       picker.sourceType = .photoLibrary
       present(picker, animated: true, completion: nil)
   }
    
    func createChannel() {
        
        var mdata = [String: Any]()
        let key = ref.childByAutoId()
        
        //profileFotoURL
        
        //competion hander needed!
        ref.child("usersInfo").child(Auth.auth().currentUser!.uid).child("profileFotoURL").getData { [self] error, db in
            
            let path = db.value as! String
                         
            mdata = ["text" :  "Welcome to this chat!", "dateSent": [".sv": "timestamp"], "tittle": "Running", "readBy": [self.displayName:true], "profileFotoURL": path]
            
        
            if let keyOfChannel = key.key {
                
            ref.child("channels").child(keyOfChannel).setValue(mdata)
             
            //fix userID
                //guard let userID = Auth.auth().currentUser?.uid else { return }
                let userInfo = [userID: true]
                ref.child("members").child(keyOfChannel).setValue(userInfo)

                let userIDPartOfGroup = [keyOfChannel: true]
          //  ref.child("channels").child(keyOfChannel).child("details").setValue(mdata)
                
                    
                ref.child("chatroomUsers").child(userID).updateChildValues(userIDPartOfGroup)

                
              /* do something like this
                ref.child("chatroomUsers").child(userID).updateChildValues(userIDPartOfGroup) { <#Error?#>, <#DatabaseReference#> in
                    <#code#>
                }
     */
            
            //message
                let message = ["dateSent": [".sv": "timestamp"], "text": "Welcome to this chat!", "userID": displayName, "profileFotoURL": path] as [String : Any]
                
                ref.child("messages").child(keyOfChannel).childByAutoId().setValue(message)

            }
        }
        
    }
    

    
    func convertTimestamp(serverTimestamp: Double) -> String {
        
        let cal = Calendar.current
        let today = Date()
        let formatter = DateFormatter()

    
        let firebaseTimeStamp = serverTimestamp / 1000
        let date = NSDate(timeIntervalSince1970: firebaseTimeStamp)

        let messageDate = Date.init(timeIntervalSince1970:  TimeInterval(firebaseTimeStamp))
    
        let components = cal.dateComponents([.hour], from: messageDate, to: today)
        let diff = components.hour!
        

    // if time between date is more than 24 hours show the data of the message if less 24 hrs so the time
    
    switch diff {
    //time
    case 0...23:
        formatter.timeStyle = .short
        //days
    case 24...168:
        formatter.dateFormat = "EEEE"
//date
    default:
        formatter.dateStyle = .short
    }
        return formatter.string(from: date as Date)
    }
    
    @IBAction func addProfilePic(_ sender: UIButton) {
        
        print("you press here")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true

        present(picker, animated: true, completion: nil)

    }

    
    func sendProfileImageToServer(photoData: Data) {
        
        //build a path using the user id and timestam
        
        let imagePath = "profileImage/" + Auth.auth().currentUser!.uid + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        print(imagePath)
        //metadata
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        //create a child note at imagepath with photoData and metada
        
        storageRef.child(imagePath).putData(photoData, metadata: metadata) {[weak self] (metadata, error) in
            
            guard let strongSelf = self else { return }
            
            if let error = error {
                print("error updaing: \(error.localizedDescription)")
                return
            }
            
            //user sendMessget to add imageURL to database
            strongSelf.sendURLtoDB(data: ["profileFotoURL" : strongSelf.storageRef.child((metadata?.path)!).description])
            
        }
        
    }
    
    func sendURLtoDB(data: [String:String]) {
    
        ref.child("usersInfo").child(Auth.auth().currentUser!.uid).updateChildValues(data)

        
    }
    
    @IBAction func contactsController(_ sender: UIBarButtonItem) {
        
        
        let controller: CreateChatViewController
        controller = storyboard?.instantiateViewController(withIdentifier: "CreateChatViewController") as! CreateChatViewController
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
  
    
}

extension ChatChannelViewController:  UIImagePickerControllerDelegate&  UINavigationControllerDelegate{

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let photoData = img.jpegData(compressionQuality: 0.8) {
             
            sendProfileImageToServer(photoData: photoData)

             }
             else if let img = info[.originalImage] as? UIImage, let photoData = img.jpegData(compressionQuality: 0.7) {
                // call function to upload photo message
                
                sendProfileImageToServer(photoData: photoData)

            }
        

            //dismissing the picker
            dismiss(animated: true, completion: nil)

        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       
        picker.dismiss(animated: true, completion: nil)
    }
    
}



extension ChatChannelViewController: UITableViewDelegate & UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String?
    {
    
      return "Messages"
   }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.white.withAlphaComponent(0.75)
        
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.black
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 35)
        header.textLabel?.frame = header.bounds
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelContainer.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
                
        let cell =
        tableView.dequeueReusableCell(withIdentifier: "chatChannels", for: indexPath) as! ChannelsTableViewCell
        
        let channelsSnapshot = channelContainer[indexPath.row]
        let canales = channelsSnapshot
        let tittle = canales.tittle
        let text = canales.text
        let dateSent = canales.dateSent
        let imageURL = canales.userProfile
        cell.lastMessageTimeWhie.text = text
        
        // Convert Date to String
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .long
        
        cell.dateOfLastmessage.text = convertTimestamp(serverTimestamp: dateSent)
        cell.chatTittle.text = tittle
                
        //please create a function for this
        if imageURL != "person.fill" {
            let gsReference = Storage.storage().reference(forURL:  imageURL)
            cell.profileImage.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            cell.profileImage.sd_setImage(with: gsReference, placeholderImage: UIImage(systemName: "person.fill"))
            cell.profileImage.sd_imageTransition = .fade

        }
            
        cell.imageStackReal.layer.cornerRadius = cell.imageStackReal.bounds.height / 2
        cell.imageStackReal.layer.borderWidth = 3.5
        cell.imageStackReal.layer.borderColor = UIColor.white.cgColor
        cell.imageStackReal.clipsToBounds = true
        cell.accessoryType = .disclosureIndicator

        /// fix to show unread messages
        if channelsSnapshot.readBy.firstIndex(where: {$0.key == displayName }) == nil {
           
            print("message not read")

            cell.dateOfLastmessage.textColor = UIColor(red:0.23, green:0.57, blue:0.80, alpha:1.0)
            cell.lastMessageTimeWhie.textColor = UIColor(red:0.23, green:0.57, blue:0.80, alpha:1.0)
            cell.chatTittle.textColor = UIColor(red:0.23, green:0.57, blue:0.80, alpha:1.0)
            cell.imageStackReal.layer.borderColor = UIColor(red:0.23, green:0.57, blue:0.80, alpha:1.0).cgColor
            
            
        } else {
            
            //the message has been read by user
            print("read by the user")
            cell.dateOfLastmessage.textColor = UIColor.black
            cell.lastMessageTimeWhie.textColor = UIColor.black
            cell.chatTittle.textColor = UIColor.black
            cell.imageStackReal.layer.borderColor = UIColor.white.cgColor
            
        }
    
        return cell
    }
    
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let controller: ViewController
        controller = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController

        let channelsSnapshot = channelContainer[indexPath.row]

        //sending the select chat to table chat view controller
        
        if let cannales = fetchedResultsController.fetchedObjects {
            
            guard let indexPath = cannales.firstIndex(where: { (canalito) -> Bool in
                //it return that location where this condition is met
                canalito.id == channelsSnapshot.key
            }) else {
                return
            }
            
            controller.currentCanal = cannales[indexPath]
            controller.dataController = dataController
        }
    
        
    
        controller.userName = displayName
       // for getting last message sent
        let keyOfTread = channelsSnapshot.key
        controller.treadID = keyOfTread
        
        //pushing the controller to top

        navigationController?.pushViewController(controller, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)

        
    }
    
    func scrollToBottomMessage() {
        
        if channelContainer.count == 0 {return}
        
        let bottomMessageIndex = IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0)
        
        tableView.scrollToRow(at: bottomMessageIndex, at: .bottom, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                presentDeletionFailsafe(indexPath: indexPath)
            
             
            }
        }

        func presentDeletionFailsafe(indexPath: IndexPath) {
            let alert = UIAlertController(title: nil, message: "Are you sure you'd like remove yourself from this channel?", preferredStyle: .actionSheet)

            // yes action
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [self] _ in
                
                self.deleteFromChat(userIdToDelete: userID, treadID: channelContainer[indexPath.row].key) { sucesful in
                    
                    if sucesful {
                        
                        
                        self.deleteFromMember(userIdToDelete: userID, treadID: channelContainer[indexPath.row].key) { sucesful in
                            
                            if sucesful {
                                
                                
                               
                                //remove from codeData
                                deleteChannel(at: indexPath)
                                //remove data from container
                                self.channelContainer.remove(at: indexPath.row)
                                
                                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                                
                                
                            } else {
                                self.alertMaker(title: "🤯", message: "Trying again soon")
                            }
    
                            
                        }
                        
                        
                    } else {
                        self.alertMaker(title: "😩", message: "unable to delete")
                    }
                }
                
                // put code to remove tableView cell here
              //   self.channelContainer.remove(at: indexPath.row)
             //   self.tableView.deleteRows(at: [indexPath], with: .fade)
            }

            alert.addAction(deleteAction)

            // cancel action
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            present(alert, animated: true, completion: nil)
        }
    
    
    func deleteFromChat(userIdToDelete: String, treadID: String, completion: @escaping (Bool) -> Void){
        
        // #1 delete from chatRoomRoom user
        
        ref.child("chatroomUsers").child(userIdToDelete).child(treadID).removeValue { error, dbreferece in
            
            if error != nil {
                completion(false)
            } else {
                print(dbreferece)
                completion(true)
            }
            
        }

    }
    
    func deleteFromMember(userIdToDelete: String, treadID: String, completion: @escaping (Bool) -> Void){
        
        // #1 delete from chatRoomRoom user
        
        ref.child("members").child(treadID).child(userIdToDelete).removeValue { error, dbreferece in
            
            if error != nil {
                completion(false)
            } else {
                print(dbreferece)
                completion(true)
            }
            
        }

    }

}

extension ChatChannelViewController:NSFetchedResultsControllerDelegate {
    
    
    // Deletes the channel at the specified index path
    func deleteChannel(at indexPath: IndexPath) {
        
        let channelToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(channelToDelete)
        try? dataController.viewContext.save()
    }
    
    //add new channel
    func addChannel(id: String) {
        
        //seting the pin data and saving it
        
        let CanalToUse = Canal(context: dataController.viewContext)
        CanalToUse.id = id
        
        //saving the data
        
        do {
            try dataController.viewContext.save()
        } catch {
            
            alertMaker(title: "Data could not be save", message: "Please try again.")
        }
        
        fetchDataAgain()
        
    }
    
    fileprivate func fetchDataAgain() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription )")
        }
    }
    
    fileprivate func setUpFetchedResultsController() {
       
        //creating a fetchRequest
        let fetchRequest:NSFetchRequest<Canal> = Canal.fetchRequest()
       
        //sorting the fetch request
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription )")
        }
        
        
    }
    
    

}

