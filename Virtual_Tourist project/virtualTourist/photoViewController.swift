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



class photoViewController: UIViewController , MKMapViewDelegate {
      var pin : Pin!
    
    
    
    var photos = [Photo]()
    
   var selectedPhotos = [IndexPath]()
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    var dataController:DataController!
    
    @IBOutlet weak var mapviewspecific: MKMapView!
  
    
    
    override func viewDidLoad() {

        
        
        super.viewDidLoad()
        loadApI()
        print(pin.latitude)
        print(pin.longitude)
      setupforpin()
        collectionView.allowsMultipleSelection = true
        
        
    }
    


    
    func loadApI()  {

        if let fetchResult = fetchPhotos() {
            photos = fetchResult
        } else {
        
        udacityAPIMethods.postSession(latitude: pin.latitude, longitude: pin.longitude){ (resultt,errorString) in
        self.UIUpdatesOnMain { //for DispatchQueue.main.async as TheMovieManager project
            guard errorString == nil else {
                print(errorString) // if any error as TheMovieManager
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
                    
                    self.photos.append(photo)
                }
               
              try? self.dataController.viewcontext.save()
                
                DispatchQueue.main.async {
                self.collectionView.reloadData()
                    for url in self.photos {
                        print(url)
                        print("df")
                    }  }  }  }    }  }  }
    
    func fetchPhotos() -> [Photo]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        fetchRequest.predicate = predicate
        
        do {
            if let result = try dataController.viewcontext.fetch(fetchRequest) as? [Photo] {
                return result.count > 0 ? result : nil
            }
        } catch {
            print("Error getting data")
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
        self.mapviewspecific.setRegion(region, animated: true)
        
        let pine = customPin(pinTitle: "this is location you selected", pinSubTitle: "at lat= \(pin.latitude)and lone=\(pin.longitude)", location: location)
        self.mapviewspecific.addAnnotation(pine)
        
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
    
    

 
}
extension photoViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewforcell
        
         let photo = self.photos[indexPath.row]
        cell.setupimage(url: photo.url!)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         let cell = collectionView.cellForItem(at: indexPath)
         cell?.contentView.alpha = 0.4
        
        
       // collectionView.setTitle("Remove Selected Pictures", for: .normal)
        
        selectedPhotos.append(indexPath)

    }
  /*  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
           let cell = collectionView.cellForItem(at: indexPath)
        
                let photo = photos[indexPath.row]
        if photosToDelete.contains(photo) {
            cell?.contentView.alpha = 1.0
            photosToDelete.remove(at: photosToDelete.index(of: photo)!)
        }
    }*/
    
    
    
    
    
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
