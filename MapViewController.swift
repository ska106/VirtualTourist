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
            // Force Initialize pinView.
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        }
        else
        {
            pinView!.annotation = annotation
        }
        pinView!.pinTintColor = UIColor.red
        pinView?.animatesDrop = true
        pinView?.isDraggable = true
        return pinView
    }
    
    func loadPinsFromDatabase()
    {
        var pins = [Pin]()
        var annotations = [MKAnnotation]()
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
        
        for (_,item) in pins.enumerated()
        {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(item.latitude),longitude: CLLocationDegrees(item.longitude))
            annotations.append(annotation)
        }
        mapview.addAnnotations(annotations)
    }
    
    func loadMapDefaults()
    {
        //Ref: http://sweettutos.com/2015/04/24/swift-mapkit-tutorial-series-how-to-search-a-place-address-or-poi-in-the-map/
        let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.78, longitude: 78.96)
        let span = MKCoordinateSpanMake(50, 40)
        let region = MKCoordinateRegionMake(coordinate, span)
        self.mapview.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        let annotation = view.annotation
        //mapView.deselectAnnotation(annotation!, animated: false)
        mapview.selectAnnotation(annotation!, animated: false)
        performSegue(withIdentifier: "showAlbum", sender: annotation)
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showAlbum"
        {
            let photosVC = segue.destination as! PhotoAlbumViewController
            let annotation = sender as! Pin
            photosVC.pin = annotation
        }
    }
}
