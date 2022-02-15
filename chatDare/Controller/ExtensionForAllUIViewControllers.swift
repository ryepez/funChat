//
//  ExtensionForAllUIViewControllers.swift
//  chatDare
//
//  Created by Ramon Yepez on 12/15/21.
//

import Foundation
import UIKit

extension UIViewController {

    
func alertMaker(title: String, message: String) {
    
    // Create the alert controller.
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

 // Add cancel to dismiss alert
    alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))

    // Present the alert.
    self.present(alert, animated: true, completion: nil)

}
    
    func getNavigationBackToNormal() {
    
        //Making the keyboard look like normal
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationController?.navigationBar.standardAppearance = barAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = barAppearance
    }
    

}
