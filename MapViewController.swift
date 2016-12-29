//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Sudeep Agrawal on 12/26/16.
//  Copyright © 2016 Agrawal. All rights reserved.
//

import Foundation

import UIKit
import MapKit
import CoreData

class MapViewController : UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate
{
    @IBOutlet weak var mapview: MKMapView!
    
    let className = "MapViewController"
    let stack = CoreDataManager.sharedInstance
    var centerCoordinate: CLLocationCoordinate2D?
    var centerCoordinateLongitude: CLLocationDegrees?
    var centerCoordinateLatitude: CLLocationDegrees?
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapview.delegate = self
        addGestureRecognizer()
        loadMapDefaults()
        loadPinsFromDatabase()
    }
    
    func addGestureRecognizer()
    {
        //Ref :http://stackoverflow.com/questions/29241691/how-do-i-use-uilongpressgesturerecognizer-with-a-uicollectionviewcell-in-swift
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.addPinToMap(gestureRecognizer:)))
        lpgr.minimumPressDuration = 2.0   // two second hold for  pin creation
        lpgr.delegate = self
        self.mapview.addGestureRecognizer(lpgr)
    }
    
    func addPinToMap(gestureRecognizer: UILongPressGestureRecognizer)
    {
        if gestureRecognizer.state == UIGestureRecognizerState.began
        {
            let point = gestureRecognizer.location(in: mapview)
            
            // Get the coordinates from the touch point.
            let coordinate = mapview.convert(point, toCoordinateFrom: mapview)
            let latitude = coordinate.latitude
            let longitude = coordinate.longitude
            print ("Coordinates of the Pin [LAT LONG] : \(latitude) \(longitude)")
           
            //Initialize Pin.
            let pin = Pin(context: stack.context)
            pin.latitude = latitude
            pin.longitude = longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapview.addAnnotation(annotation)
            stack.save()
        }
    }
    
    // MARK: - MKMapViewDelegate
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let reuseId = "pin"
        var pinView = mapview.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
    
        if pinView == nil
        {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
        }
            
        else
        {
            pinView!.annotation = annotation
        }
        pinView?.animatesDrop = true
        return pinView
    }
    
    func loadPinsFromDatabase()
    {
        var pins = [Pin]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        do
        {
            let results = try stack.context.fetch(fetchRequest)
            if let results = results as? [Pin]
            {
                pins = results
                print("Number of Pins : \(pins.count)")
            }
        }
        catch
        {
            print("Couldn't find any Pins")
        }
        //mapview.addAnnotations(pins as! [MKAnnotation])
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
      /*  if segue.identifier == "showCollection"
        {
            let photosVC = segue.destinationViewController as! CollectionViewController
            let annotation = sender as! Pin
            photosVC.pin = annotation
        } */
    }
    
    func loadMapDefaults()
    {
        guard let centerCoordinateLatitude = UserDefaults.standard.value(forKey:"centerCoordinateLatitude") as? CLLocationDegrees else
        {
            return
        }
        guard let centerCoordinateLongitude = UserDefaults.standard.value(forKey:"centerCoordinateLongitude") as? CLLocationDegrees else {
            return
        }
        mapview.centerCoordinate = CLLocationCoordinate2DMake(centerCoordinateLatitude, centerCoordinateLongitude)
    }
    

    
    /*func mapView(_ didSelectmapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
    {
        let annotation = view.annotation as! Pin
        mapview.deselectAnnotation(annotation, animated: false)
        performSegue(withIdentifier: "showCollection", sender: annotation)
 
    }*/
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool)
    {
        centerCoordinateLatitude = mapView.centerCoordinate.latitude
        centerCoordinateLongitude = mapView.centerCoordinate.longitude
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)
    {
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: "centerCoordinateLatitude")
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: "centerCoordinateLongitude")
    }
}
