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
    @IBOutlet weak var ToolButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let flickrClient = FlickrClient.sharedInstance
    let stack = CoreDataManager.sharedInstance
    
    // this will keep track of the current location
    var pin: Pin!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    //Set the title of the Tool Button accordingly.
    var selectedPhotos = [NSIndexPath]()
    {
        didSet
        {
            ToolButton.title = selectedPhotos.isEmpty ? "New Collection" : "Remove Selected Pictures"
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    //Search New Photos
    func searchPhotos()
    {
    }
    
    //Delete all Photos 
    func deletePhotos()
    {
    }
    
    //Delete Selected Photos
    func deleteSelectedPhotos()
    {
    }
    
    @IBAction func tapToolButton(_ sender: Any)
    {
        if selectedPhotos.isEmpty
        {
            deletePhotos()
            searchPhotos()
        }
        else
        {
            deleteSelectedPhotos()
        }
    }
}

// MARK: - MKMapViewDelegate
extension PhotoAlbumViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        return pinView
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoAlbumViewController:UICollectionViewDelegate
{
    func configureCellSection(cell: Photocell, indexPath: NSIndexPath)
    {
        if let _ = selectedPhotos.index(of: indexPath)
        {
            cell.alpha = 0.5
        }
        else
        {
            cell.alpha = 1.0
        }
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoAlbumViewController:UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        //Ref: https://developer.apple.com/library/content/documentation/WindowsViews/Conceptual/CollectionViewPGforIOS/CreatingCellsandViews/CreatingCellsandViews.html
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        //Get the Collection Cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Photocell", for: indexPath) as! Photocell
        
        //Get the Photo Image saved in the DB.
        let pic = fetchedResultsController.object(at: indexPath) as! Photos
        
        //Download photos from Flickr API.
        flickrClient.downloadPhotos(photoURL: pic.url!){ (image, error)  in

            //Check if the image data is not nil
            guard let imageData = image,
                  let downloadedImage = UIImage(data: imageData as Data) else
            {
                return
            }
            
            DispatchQueue.main.async
            {
                pic.image = imageData
                self.stack.save()
                
                if let updateCell = self.collectionView.cellForItem(at: indexPath) as? Photocell
                {
                    updateCell.imageView.image = downloadedImage
                    updateCell.activityIndicator.stopAnimating()
                    updateCell.activityIndicator.isHidden = true
                }
            }
            cell.imageView.image = UIImage(data: imageData as Data)
            self.configureCellSection(cell: cell, indexPath: indexPath as NSIndexPath)
        }
        return cell
    }
}
