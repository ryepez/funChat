//
//  LoginViewController.swift
//  chatDare
//
//  Created by Ramon Yepez on 9/23/21.
//

import UIKit
import Firebase
import AVFoundation


//player properties

var player: AVPlayer?
let playerView = AVPlayerLayer()

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var videoPlayerView: UIView!
    
    @IBOutlet weak var stackVideo: UIStackView!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Database reference
    var ref: DatabaseReference!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Delegates
        
        txtEmail.delegate = self
        txtPassword.delegate = self
    
        // firebase database refererence
        firebaseReference()
        
        //intial buttons setting
        buttonSetup()

        //adding video to view
        playerVideo(userVideo: "D3")
        
        //pushing infomation stack and activity indicator to the top
        videoPlayerView.bringSubviewToFront(infoStackView)
        videoPlayerView.bringSubviewToFront(activityIndicator)

        //hiding create account
        //createAccountButton.isEnabled = false
      //  createAccountButton.alpha = 0.0
        
        //adding tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        
        // tap
       // var secretTapGesture = UITapGestureRecognizer()
        // TAP Gesture
       // secretTapGesture = UITapGestureRecognizer(target: self, action: #selector(secretTap(_:)))
     //   secretTapGesture.numberOfTapsRequired = 5
       // secretTapGesture.numberOfTouchesRequired = 2
      //  welcomeLabel.addGestureRecognizer(secretTapGesture)
      //  welcomeLabel.isUserInteractionEnabled = true

    }

    @objc func secretTap(_ gesture: UITapGestureRecognizer){
     
        AudioServicesPlayAlertSound(SystemSoundID(1007))
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        UIView.animate(withDuration: 3, delay: 0.1, options: .transitionFlipFromRight, animations: {
            self.createAccountButton.alpha = 1.0
           self.createAccountButton.isEnabled = true
        })
        
       
     

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
           // notifications to key track of the keyboard
           subscribeToKeyboardNotifications()
           subscribeToKeyboardNotificationsHide()
       }
       
       override func viewWillDisappear(_ animated: Bool) {
           
           // unsubscribe from keyboard notification

           unsubscribeToKeyboardNotifications()
           unsubscribeToKeyboardNotificationsHide()

       }
    
    deinit {
       NotificationCenter.default.removeObserver(self)
    }
    
    func firebaseReference() {
        
        // firebase database refererence
        ref = Database.database().reference()
        
    }

    
    fileprivate func buttonSetup() {
        
        //making the button be rounderer
        loginButton.layer.cornerRadius = 10
        createAccountButton.layer.cornerRadius = 10
        
        // hiding status label
        statusText.alpha = 0.0
        //disable logging button
        loginButton.isEnabled = false
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        txtEmail.resignFirstResponder()
        txtPassword.resignFirstResponder()

    }
   
  
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if txtEmail.text == "" || txtPassword.text == "" {
            loginButton.isEnabled = false
        } else {
            loginButton.isEnabled = true

        }
    }

    func buttonsEnabled(status: Bool) {
    
        if status {
            activityIndicator.stopAnimating()
            loginButton.isEnabled = status
            createAccountButton.isEnabled = status
            txtEmail.isEnabled = status
            txtPassword.isEnabled = status
        } else {
            activityIndicator.startAnimating()
            loginButton.isEnabled = status
            createAccountButton.isEnabled = status
            txtEmail.isEnabled = status
            txtPassword.isEnabled = status
        }
    }
    
    @IBAction func login(_ sender: UIButton) {
        
        
        //Getting fields text
        let email = txtEmail.text!
        let password = txtPassword.text!
        
        //Start activity indicator and disable button
        buttonsEnabled(status: false)

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
       
            if (error != nil) {
                
                strongSelf.createAlertLoging(title: "🤯Something went wrong!🧐", message: error?.localizedDescription ?? "🤯")
                //strongSelf.statusText.alpha = 1.0
               // strongSelf.statusText.text = "Error check user name and/or password"
                print(error ?? "Something went wrong")
                //Activity indicator and button back to normal
                strongSelf.buttonsEnabled(status: true)
                return
            }
            strongSelf.statusText.alpha = 1.0
            strongSelf.statusText.text = "loggin sucess for email\(email)"
           
            //Activity indicator and buttons back to normal
            strongSelf.buttonsEnabled(status: true)
            
            //making the seque
            strongSelf.handleSessionResponse()
        }

    }
    
    
    func createAlertLoging(title: String, message: String) {
        
        // Create the alert controller.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

     // Add cancel to dismiss alert
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
    
        // Present the alert.
        self.present(alert, animated: true, completion: nil)
   
    }

    func playerVideo(userVideo: String) {
      
        //getting path
        let path = Bundle.main.path(forResource:userVideo,  ofType:"mp4")!
       // adding url to player
        let url = URL(fileURLWithPath: path)
        player = AVPlayer(url: url)
        playerView.player = player

        // Controlling display of video
        playerView.videoGravity = .resizeAspectFill
        videoPlayerView.clipsToBounds = true
        playerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)

        // Adding videp to videoPlayerView
        videoPlayerView.layer.addSublayer(playerView)
       
        //Play video
        player?.play()
        
       // notification to know when video ended
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)

    }
    
   
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        
        //go back start
        player!.seek(to: .zero)
        
    }
    
    
    func handleSessionResponse() {
                
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
   
            //to change the root view controller calling the object created in scene delegete
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // keyboard Setting
      @objc  func keyboardWiShow(_ notification:Notification) {
        // if statement to only do the movement of keyboard when is the bottom textfield
        if txtPassword.isEditing || txtEmail.isEditing, view.frame.origin.y == 0  {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
        }
        
        //function that gets the height of the keyboard
        func getKeyboardHeight(_ notification:Notification) -> CGFloat  {
            let userInfo = notification.userInfo
            let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            
            return keyboardSize.cgRectValue.height
        }
        
        //keyboard subscriptions
        func subscribeToKeyboardNotifications() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWiShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        }
        
        func unsubscribeToKeyboardNotifications() {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        }
        
        //hidding keyboard
        
        @objc func keyboardWillHide(_ notification:Notification) {
            //return the view to it is original point if the view is not at zero
            
            if  txtPassword.isEditing || txtEmail.isEditing, view.frame.origin.y != 0 {
                view.frame.origin.y = 0
            }
            
    }
        
        func subscribeToKeyboardNotificationsHide() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        func unsubscribeToKeyboardNotificationsHide() {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
    
    
    
    
}
