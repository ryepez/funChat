//
//  SignUpViewController.swift
//  chatDare
//
//  Created by Ramon Yepez on 12/4/21.
//

import UIKit
import Firebase


class SignUpViewController: UIViewController {

    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var profileImage: UIButton!
    
    // Firebase reference
    var ref: DatabaseReference!
    
    //reference to the storage
    var storageRef: StorageReference!
    
    // profile image temp save
    var nameOfProfileFoto = String()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setting up text delegates
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        firebaseReference()
        configureStorage()
        buttonsSetup()
        
    }
    
    
    fileprivate func buttonsSetup() {
        
        activityIndicator.isHidden = true
        profileImage.isHidden = true
        profileImage.isEnabled = false
        
        createAccountButton.isHidden = true
        createAccountButton.isEnabled = false
        
        profileImage.layer.cornerRadius = 10
        createAccountButton.layer.cornerRadius = 10
    }
    
    fileprivate func firebaseReference() {
       
        //db reference
        ref = Database.database().reference()
    }
    
    
    func configureStorage() {
        
        storageRef = Storage.storage().reference()
    }
    
    //IBActions buttons
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func addProfileImage(_ sender: UIButton) {
  
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true

        present(picker, animated: true, completion: nil)
    
    }
    
    
    @IBAction func createAccount(_ sender: Any) {
       
        //maybe use this ?
        //passwordTextField.resignFirstResponder()
        
        //disable and hiding buttons to the users does not press again
        passwordTextField.isEnabled = false
        emailTextField.isEnabled = false
        profileImage.isHidden = true
        createAccountButton.isHidden = true
        
        //starting indicator animnation
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if validateEmail(candidate: email) {
            //Do creating on account
            createAccountFirebase(email: email, password: password) { result in
                
                //if sucessful send profile image to db
                if result {
                    
                    let imageToUpLoad = self.loadImageFromDiskWith(fileName: self.nameOfProfileFoto)
                    
                    if let data = imageToUpLoad?.jpegData(compressionQuality: 0.9) {
                        self.sendProfileImageToServer(photoData: data)
                      
                                                
                    } else {
                        self.createAlert(title: "Something went wrong 🥸", message: "😩")
                    }

                    
                }
                //if not sucesful do not send image to db
                //disable button
             
                
            }

        } else {
            
            createAlert(title: "Invalid email", message: "Plese enter valid email")
      
        }
        
        

        
    }
    
    
    //create account function
     func createAccountFirebase(email: String, password: String, completion: @escaping (Bool) -> Void) {
       
        Auth.auth().createUser(withEmail: email, password: password) { [self] authResult, error in
            
            if (error != nil) {
                
                self.createAlert(title: "Something went wrong 🧐", message: error?.localizedDescription ?? "🤯")
                print(error?.localizedDescription as Any)
                completion(false)
                return
            }
            
            let userName =  Auth.auth().currentUser?.email?.components(separatedBy: "@")[0] ?? "?User?"
            let userID = Auth.auth().currentUser!.uid
            
            //if we are able to create account
            self.ref.child("usersInfo").child(userID).setValue(["userName": userName])
        

            //if sucessful
            completion(true)

            
        }
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
        
        //dismising controller sucessful case and stoping the animation
        self.activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
  // To save image and use later for uploading
    
    func saveImage(imageName: String, image: UIImage) {

     guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        
        print(fileURL.path)
        
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }

        }

        do {
            try data.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }

    }


    func checkIfProfileExist() {
     
       // let fileManager = FileManager.default

        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

           let fileName = "profile"
           let fileURL = documentsDirectory.appendingPathComponent(fileName)
                      
           //Checks if file exists, removes it if so.
           if FileManager.default.fileExists(atPath: fileURL.path) {
            print("file exist")
            createAccountButton.isHidden = false
            createAccountButton.isEnabled = true

           } else {
            print("no file exist")
            createAccountButton.isHidden = true
            createAccountButton.isEnabled = false

           }

    }
    
    func deleteFile() {
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileName = "profile"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
                
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }

        }
    }


    func loadImageFromDiskWith(fileName: String) -> UIImage? {

      let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image

        }

        return nil
    }
    
    
    func createAlert(title: String, message: String) {
        
        // Create the alert controller.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

     // Add cancel to dismiss alert
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
    
        // Present the alert.
        self.present(alert, animated: true, completion: nil)
        
        //stoping the activity indicatior
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        
    }
    
    
    
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if emailTextField.text !=  "" && passwordTextField.text!.count >= 6 {
            profileImage.isHidden = false
            profileImage.isEnabled = true
        } else {
            profileImage.isHidden = true
            profileImage.isEnabled = false

        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }

    func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
    }
    
}

extension SignUpViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let photoData = img.jpegData(compressionQuality: 0.8) {
             //setting image name of file system and saving image
            nameOfProfileFoto = "profile"
            saveImage(imageName: nameOfProfileFoto, image: UIImage(data: photoData)!)
        
        }
             else if let img = info[.originalImage] as? UIImage, let photoData = img.jpegData(compressionQuality: 0.8) {
                // call function to upload photo message
                
                nameOfProfileFoto = "profile"
                saveImage(imageName: nameOfProfileFoto, image: UIImage(data: photoData)!)

            }
        
        checkIfProfileExist()

            //dismissing the picker
            dismiss(animated: true, completion: nil)

        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       
        picker.dismiss(animated: true, completion: nil)
    }
    
}
