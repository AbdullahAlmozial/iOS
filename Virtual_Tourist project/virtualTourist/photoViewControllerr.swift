//
//  photoViewController.swift
//  virtualTourist
//
//  Created by عبدالله محمد on 2/1/19.
//  Copyright © 2019 udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreData



class photoViewControllerr: UIViewController , MKMapViewDelegate {
    var pin : Pin!
    var arrayphotos = [Photo]()
    var arrayPhotosToDelete = [Photo]()
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var newcollectionbutton: UIButton!
    var dataController:DataController!
    @IBOutlet weak var mapSpecific: MKMapView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadApI()
        setupforpin()
        CollectionView.allowsMultipleSelection = true
    }
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    func showAlertError(_ errorString: String?) {
        if let errorString = errorString {
            self.displayAlert(title: "Error", message: errorString) // change way of implemintion from show error on the lebel as TheMovieManager project to show on Alert
        }
    }
    
    func loadApI()  {
        if let fetchload = fetchload() {
            arrayphotos = fetchload
        } else {
            
            flickerAPIMethods.postSession(latitude: pin.latitude, longitude: pin.longitude){ (resultt,errorString) in
                self.UIUpdatesOnMain { //for DispatchQueue.main.async as TheMovieManager project
                    guard errorString == nil else {
                        self.showAlertError(errorString) // if any error as TheMovieManager
                        return
                    }
                    // if it,s succefuly
                    print("done")
                    if let resultt = resultt {
                        for url in resultt {
                            //  print(url)
                            let photo = Photo(context:self.dataController.viewcontext)
                            photo.url = url
                            photo.pin = self.pin
                            
                            self.arrayphotos.append(photo)
                        }
                        
                        try? self.dataController.viewcontext.save()
                        
                        DispatchQueue.main.async {
                            self.CollectionView.reloadData()
                            for url in self.arrayphotos {
                                print(url)
                                print("df")
                            }  }  }  }    }  }  }
    
    func fetchload() -> [Photo]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        fetchRequest.predicate = predicate
        do {
            if let result = try dataController.viewcontext.fetch(fetchRequest) as? [Photo] {
                return result.count > 0 ? result : nil
            }
        } catch {
            print("Error with data")
        }
        
        return nil
    }
    
    
    
    func UIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    
    func setupforpin() {
        let location = CLLocationCoordinate2D(latitude: pin.latitude, longitude:pin.longitude)
        let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
        self.mapSpecific.setRegion(region, animated: true)
        
        let pine = customPin(pinTitle: "this is location you selected", pinSubTitle: "at lat= \(pin.latitude)and lone=\(pin.longitude)", location: location)
        self.mapSpecific.addAnnotation(pine)
        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    
    @IBAction func newcollection(_ sender: UIButton) {
        
        if arrayPhotosToDelete.count == 0 {
            for photo in arrayphotos {
                self.dataController.viewcontext.delete(photo)
            }
            
           try? self.dataController.viewcontext.save()
            arrayphotos = [Photo]()
            CollectionView.reloadData()
            loadApI()
            
            
        } else {
            sender.setTitle("New Collection for Photo", for: .normal)
            for photo in arrayPhotosToDelete {
                self.dataController.viewcontext.delete(photo)
                arrayphotos.remove(at: arrayphotos.index(of: photo)!)
            }
            
            arrayPhotosToDelete = [Photo]()
            try? self.dataController.viewcontext.save()
            CollectionView.reloadData()
            
        }
        
        
    }
    
    
    
    
    
}
extension photoViewControllerr : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayphotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewforcell
        
        let photo = self.arrayphotos[indexPath.row]
        
        cell.imageViewcollection.image = nil
      cell.activityIndecitor.isHidden = false
    
        
        if let imageData = photo.image {
            
            let image = UIImage(data: imageData as Data)
            cell.imageViewcollection.image = image
            cell.activityIndecitor.isHidden = true
        } else {
            cell.activityIndecitor.startAnimating()
            
            flickerAPIMethods.staticflicker.downloadsimages(with: photo.url!) { (data, error) in
                if error == nil {
                    let downloadedImage = UIImage(data: data!)
                    photo.image = data as NSData? as! Data
                    DispatchQueue.main.async {
            cell.imageViewcollection.image = downloadedImage
            cell.activityIndecitor.stopAnimating()
            cell.activityIndecitor.isHidden = true
                    }
                }
            }
            
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
        let cell = collectionView.cellForItem(at: indexPath)
        
        cell?.contentView.alpha = 0.4
         newcollectionbutton.setTitle("Remove Pictures", for: .normal)
        
        let photo = arrayphotos[indexPath.row]
        if !arrayPhotosToDelete.contains(photo) {
            arrayPhotosToDelete.append(photo)
        }
        
        
    }
      func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
     let cell = collectionView.cellForItem(at: indexPath)
    
        cell?.contentView.alpha = 1.0
    
          let photo = arrayphotos[indexPath.row]
        if arrayPhotosToDelete.count == 0 {
            newcollectionbutton.setTitle("New Collection", for: .normal)
        }
        if arrayPhotosToDelete.contains(photo) {
            cell?.contentView.alpha = 1.0
            arrayPhotosToDelete.remove(at: arrayPhotosToDelete.index(of: photo)!)
        }

     }

    
     }
    
    
    
    
    




class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle:String, pinSubTitle:String, location:CLLocationCoordinate2D) {
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
    }
}

