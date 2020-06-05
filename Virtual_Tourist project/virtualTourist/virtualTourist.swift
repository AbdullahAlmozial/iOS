//
//  ViewController.swift
//  customannotation
//
//  Created by عبدالله محمد on 1/31/19.
//  Copyright © 2019 udacity. All rights reserved.
//





import UIKit
import MapKit
import CoreData

class virtualTourist: UIViewController ,  MKMapViewDelegate , NSFetchedResultsControllerDelegate {
    
    
      var fetchedResultsController:NSFetchedResultsController<Pin>!
    
 let segue = "PhotoSegue"
    @IBOutlet weak var mapView: MKMapView!
  
    
     var dataController:DataController!
    
override func viewDidLoad() {
    super.viewDidLoad()
    
     let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
    // check you need this or not
    
    do {
        if let result = try dataController.viewcontext.fetch(fetchRequest) as? [Pin] {
            for pin in result {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude:
                    CLLocationDegrees(pin.latitude),longitude:
                    CLLocationDegrees(pin.longitude))
                mapView.addAnnotation(annotation)
            } }
        }
     catch {
        print("no find any Pins")
    }

    self.mapView.delegate = self

    
}
    
    
    @IBAction func addpin(_ sender: UILongPressGestureRecognizer) {
           if sender.state == .began {
       let pin = Pin(context: dataController.viewcontext)
        let touchLocation = sender.location(in: self.mapView)
        let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        pin.latitude = Double(coordinate.latitude)
        pin.longitude = Double(coordinate.longitude)
        pin.creattionData = Date()
        try? dataController.viewcontext.save()
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "hello new pin"
            mapView.addAnnotation(annotation)
            
        }
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
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        if let annotation = view.annotation {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [annotation.coordinate.latitude, annotation.coordinate.longitude])
            fetchRequest.predicate = predicate
            do {
                if let result = try dataController.viewcontext.fetch(fetchRequest) as? [Pin],
                    let pin = result.first {
                  performSegue(withIdentifier: segue, sender: pin)
                
                } }
            
            catch {
                print("Couldn't find any Pins")
            }
        }

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.segue {
            let vc = segue.destination as! photoViewControllerr
            vc.pin = (sender as! Pin)
            vc.dataController = dataController
        }
    }
        func deleteNotebook(at indexPath: IndexPath) {
            let notebookToDelete = fetchedResultsController.object(at: indexPath)
            dataController.viewcontext.delete(notebookToDelete)
            try? dataController.viewcontext.save()
        }
}

