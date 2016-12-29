//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Sudeep Agrawal on 12/26/16.
//  Copyright © 2016 Agrawal. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController:UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    
    // this will keep track of the current location
    var pin: Pin!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
}
