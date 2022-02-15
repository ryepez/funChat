//
//  ListOfPeopleViewController.swift
//  chatDare
//
//  Created by Ramon Yepez on 12/19/21.
//

import UIKit
import Firebase
import FirebaseStorageUI
import CoreData


class ListOfPeopleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
  
    @IBOutlet weak var collectionView: UICollectionView!
    //setting the container for the data
    var canal: Canal!
    //injecting the data source
    var dataController: DataController!
    //variable to store block operation for deleting photos from collectionView
    var blockOperation = BlockOperation()
    
    //images array
    var fotoData: [chatSaveImage] = []
    
    // the fectch results
    var fetchedResultsController: NSFetchedResultsController<Foto>!
    
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var tableView: UITableView!
    
    var ref: DatabaseReference!
    var chatID = String()
    var listOfPeople: [UserOnList] = []
    var lista: [UserOnList] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
   
        configureDB(chatID: chatID) { dic in
            for user in dic.keys {
                
                let llaves = user as String

                self.getProfile(userData: llaves) { userOnlist in
                    self.lista.append(userOnlist)
                    self.tableView.reloadData()
                }
                
            }
        }
                
        self.tableView.rowHeight = (view.frame.height/10)
        self.tableView.separatorStyle = .none
        
        makeCollectionViewThreeColumns()
        
        //getting images
        //loading coreData
        settiUpFetchResults()
    }
    
    
    fileprivate func settiUpFetchResults() {
        //selects the first annotation so when going to the screen it shows selected
        
        
        let fetchRequest:NSFetchRequest<Foto> = Foto.fetchRequest()
        let predicate = NSPredicate(format: "channel == %@", canal)
        fetchRequest.predicate = predicate
        //sorting the fetch request
        let sortDescriptor = NSSortDescriptor(key: "downloadDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription )")
        }
    }
    
    
    fileprivate func makeCollectionViewThreeColumns() {
          // makes the collection view looks nice with 3 columns
          let space: CGFloat = 3.0
          let dimension = (view.frame.size.width - (2*space)) / 3.0
          
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: (view.frame.size.width/3.0))
      }
    
    func configureDB(chatID: String, completion: @escaping ([String:Any]) -> Void) {
        //getting a reference to the db
        
        
        ref = Database.database().reference()
        
        ref.child("members").child(chatID).getData { error, dataShap in
            
            if error != nil {
                completion([:])
            } else {
                
                let values = dataShap.value as! [String:Any]
                completion(values)
                           
                           }
            
        }
           
        
    }
    
    func getProfile(userData: String, completion: @escaping (UserOnList) -> Void) {
        
       // var arrayOfValues: [UserOnList] = []

        
        ref.child("usersInfo").child(userData).getData { error, dataShapy in
            
            let values = dataShapy.value as! [String: Any]
            
            let userInfo = UserOnList(userName: values["userName"] as! String, profileURL: values["profileFotoURL"] as! String)
            
            completion(userInfo)
        }
        
        
    }
 
    deinit {
        //this is to remove the lisenser so we do not run of memory after this class get deinit
      //  Auth.auth().removeStateDidChangeListener(_authHandle)
        
            print("deinit \(self)")
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String?
    {
    
      return "Chat Participants"
   }
    
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return lista.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         
         let person = lista[indexPath.row]

         let cell =
         tableView.dequeueReusableCell(withIdentifier: "OnListTableViewCell", for: indexPath) as! OnListTableViewCell
         
         
         cell.userName.text = person.userName
         
         let gsReference = Storage.storage().reference(forURL:  person.profileURL)

         cell.userPhoto.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
         cell.userPhoto.sd_setImage(with: gsReference, placeholderImage: UIImage(systemName: "person.fill"))
         cell.userPhoto.sd_imageTransition = .fade

         
         //setting the round image
     cell.imageStack.layer.cornerRadius = cell.imageStack.bounds.height / 2
     cell.imageStack.layer.borderWidth = 3.5
         cell.imageStack.layer.borderColor = UIColor.white.cgColor
     cell.imageStack.clipsToBounds = true
         
         return cell
     }
    
    @IBAction func dimiss(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    


    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SaveImageCollectionViewCell", for: indexPath) as! SaveImageCollectionViewCell
        
        let photo = self.fetchedResultsController.object(at: indexPath)
        //cell.imageView.image = UIImage(data:fotoData[indexPath.row].image)
        cell.imageView.image =  UIImage(data: photo.imageToUse!)
        return cell 
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("You have delete this picture!")
        
        let pictureToBeDeleted = fetchedResultsController.object(at: indexPath)
        
        dataController.viewContext.delete(pictureToBeDeleted)
        
    }

    
    
}

extension ListOfPeopleViewController: NSFetchedResultsControllerDelegate {
    // methods to delete images by clicking on them.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        blockOperation = BlockOperation()
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let sectionIndexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        
        case .insert:
            
            blockOperation.addExecutionBlock { [weak self] in
                
                self?.collectionView?.insertSections(sectionIndexSet)
                
            }
            
        case .delete:
            
            blockOperation.addExecutionBlock { [weak self] in
                
                self?.collectionView?.deleteSections(sectionIndexSet)
                
            }
            
        case .update:
            
            blockOperation.addExecutionBlock { [weak self] in
                
                self?.collectionView?.reloadSections(sectionIndexSet)
                
            }
            
        case .move:
            
            assertionFailure()
            
            break
            
        @unknown default:
            fatalError()
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        
        case .insert:
            
            guard let newIndexPath = newIndexPath else { break }
            
            blockOperation.addExecutionBlock { [weak self] in
                
                self?.collectionView?.insertItems(at: [newIndexPath])
                
            }
            
        case .delete:
            
            guard let indexPath = indexPath else { break }
            
            blockOperation.addExecutionBlock { [weak self] in
                
                self?.collectionView?.deleteItems(at: [indexPath])
                
                
            }
            
            
        case .move:
            
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            
            blockOperation.addExecutionBlock { [weak self] in
                
                self?.collectionView?.moveItem(at: indexPath, to: newIndexPath)
                
            }
            
        case .update:
            print("do nothing")
        @unknown default: break
            
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView?.performBatchUpdates({ [weak self] in
            
            self?.blockOperation.start()
            
        }, completion: nil)
        
    }

}
