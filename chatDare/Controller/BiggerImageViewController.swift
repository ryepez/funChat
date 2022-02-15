//
//  BiggerImageViewController.swift
//  chatDare
//
//  Created by Ramon Yepez on 10/23/21.
//

import UIKit
import CoreData

class BiggerImageViewController: UIViewController {

    //Property that it will store image
    
    var imageToShow = UIImage()
    let saveButton = UIButton()
    var urlForImage = String()

    
    /// The canal currently being seen
    var currentCanal: Canal!
    var dataController:DataController!

    //Outlet for image image and scrolling
    @IBOutlet weak var imageViewBigger: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
   //contrain for centter image
    @IBOutlet weak var verticalContraint: NSLayoutConstraint!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        //getting image
        imageViewBigger.image = imageToShow
        
        //setting scrolling
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4
        scrollView.zoomScale = 1.0

        // making navigation transparent
        settingUpNavigation()
        
        // adding the double tap gesture to image to zoom in and out.
        imageViewBigger.isUserInteractionEnabled = true
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
            doubleTapRecognizer.numberOfTapsRequired = 2
        imageViewBigger.addGestureRecognizer(doubleTapRecognizer)
        
        let longHoldTap = UILongPressGestureRecognizer(target: self, action: #selector(showMenu(_:)))
        longHoldTap.minimumPressDuration = 1
        imageViewBigger.addGestureRecognizer(longHoldTap)
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        saveButton.center = view.center
        saveButton.addTarget(self, action: #selector(saveToCoreData), for: .touchUpInside)
        saveButton.isHidden = true

        view.addSubview(saveButton)
       
    }
    
    deinit {
     
            print("deinit \(self)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        settingUpNavigation()
    }
    
    func settingUpNavigation() {
            
       let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.standardAppearance = appearance
    navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white

      //centering the image. Offsetting the navigation bar height

        if let navigationBarHeight = navigationController?.navigationBar.frame.height {
                verticalContraint.constant = -navigationBarHeight
            }
        }

    
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        
        //this working here
        print("working here")
        if scrollView.zoomScale == 1 {
            print("working here1")
            scrollView.setZoomScale(2, animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }

    }
    
    @objc private func showMenu(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
      
        
        if gestureRecognizer.state == .began {
           print("presed")
            saveButton.isHidden = false
    }
        
    }
    
    @objc  func saveToCoreData() {
        
        print("saving to coreDate")
        
     
        
        DispatchQueue.main.async { [weak self] in
            
            guard let strongSelf = self else { return }
            let foto = Foto(context: strongSelf.dataController.viewContext)
            foto.url =  strongSelf.urlForImage
            foto.downloadDate = Date()
            foto.channel = strongSelf.currentCanal
            foto.imageToUse = strongSelf.imageToShow.pngData()
            
            //saving the data
            
            do {
                try strongSelf.dataController.viewContext.save()
            } catch {
                strongSelf.alertMaker(title: "Data could not be save", message: "Please try again.")
            }
            
        }
        
        
        
        
        saveButton.isHidden = true
        
    }
    
}

extension BiggerImageViewController: UIScrollViewDelegate {
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageViewBigger
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
             if scrollView.zoomScale > 1 {
                 if let image = imageViewBigger.image {
                     let ratioW = imageViewBigger.frame.width / image.size.width
                     let ratioH = imageViewBigger.frame.height / image.size.height
                     
                     let ratio = ratioW < ratioH ? ratioW : ratioH
                     let newWidth = image.size.width * ratio
                     let newHeight = image.size.height * ratio
                     let conditionLeft = newWidth*scrollView.zoomScale > imageViewBigger.frame.width
                     let left = 0.5 * (conditionLeft ? newWidth - imageViewBigger.frame.width : (scrollView.frame.width - scrollView.contentSize.width))
                     let conditioTop = newHeight*scrollView.zoomScale > imageViewBigger.frame.height
                     
                     let top = 0.5 * (conditioTop ? newHeight - imageViewBigger.frame.height : (scrollView.frame.height - scrollView.contentSize.height))
                     
                     scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: top, right: left)
                     
                 }
             } else {
                 scrollView.contentInset = .zero
             }
         }
}
