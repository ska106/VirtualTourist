//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Sudeep Agrawal on 12/27/16.
//  Copyright © 2016 Agrawal. All rights reserved.
//

import Foundation

class FlickrClient
{
    var session = URLSession.shared

    // MARK: Singleton Pattern
    static let sharedInstance = FlickrClient()
    
    // MARK : Based on the name of the resource, construct the API URL to be invoked.
    func getMethodURL(using parameters: [String:AnyObject]) -> URL
    {
        //Ref: www.grokswift.com/building-urls
        var components = URLComponents()
        components.scheme = Constants.APIScheme
        components.host = Constants.APIHost
        components.path = Constants.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters
        {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }

    private func makeBoundaryBoxString(lat latitude: Double,  long longitude: Double) -> String
    {
        //Longitude - limits
        let minimumLon = max(longitude - Constants.BBoxLimits.Width, Constants.BBoxLimits.LonRange.0)
        let maximumLon = min(longitude + Constants.BBoxLimits.Width, Constants.BBoxLimits.LonRange.0)
        
        //Latitude - imits
        let minimumLat = max(latitude - Constants.BBoxLimits.Height, Constants.BBoxLimits.LatRange.0)
        let maximumLat = min(latitude + Constants.BBoxLimits.Height, Constants.BBoxLimits.LatRange.0)
        
        //Ref: API Specifications on bbox @ https://www.flickr.com/services/api/flickr.photos.search.html
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
    // MARK : Function to initiate the API call via. Task.
    func makeTaskCall (req request:URLRequest , completionHandlerForTaskCall : @escaping (_ result : AnyObject? , _ error: NSError?) -> Void)
    {
        let session = URLSession.shared
        
        //Create Task
        let task = session.dataTask(with: request) { (data, response, error) in
        
            //Check for error
            if error == nil
            {
                //Success
                // Convert the JSON to AnyObject so that it can be mapped to the completionHandler here.
                Converter.parseJSONToAnyObject(response: data! as NSData, completionHandler: completionHandlerForTaskCall)
            }
            else
            {
                //Failure
                completionHandlerForTaskCall(nil,error! as NSError?)
            }
        }
        task.resume()
    }
    
    //Search Photos and get the photo URLs of all the photos in the search result.
    func searchPhotos(latitude: Double, longitude: Double, completionHandlerForSearchPhotos: @escaping (_ photoURLS: [String]?, _ error: NSError?) -> Void)
    {
        //Set the URL parameters as per the Flickr specifications
        let methodParameters: [String: AnyObject] =
        [
            Request.ParamKey.Method:Request.ParamVal.Method as AnyObject,
            Request.ParamKey.APIKey:Request.ParamVal.APIKey as AnyObject,
            Request.ParamKey.BoundingBox:self.makeBoundaryBoxString(lat: latitude, long: longitude) as AnyObject,
            Request.ParamKey.Extras:Request.ParamVal.MediumURL as AnyObject,
            Request.ParamKey.Format:Request.ParamVal.Format as AnyObject,
            Request.ParamKey.NoJSONCallback:Request.ParamVal.DisableJSONCallback as AnyObject,
            Request.ParamKey.PerPage:Request.ParamVal.PhotosPerPage as AnyObject,
            Request.ParamKey.Page:"\(arc4random_uniform(50))" as AnyObject
        ]

        let requestURL = URLRequest(url: getMethodURL(using: methodParameters));
        
        makeTaskCall(req: requestURL){ (data, error) in
        
            if error == nil
            {
                //Success - No error in response
                //Check the reponse for OK (stat).
                guard let stat = data?[Response.Key.Status] as? String, stat == "OK" else
                {
                    print("Flickr API returned an error. See error code and message in \(data)")
                    completionHandlerForSearchPhotos(nil, NSError(domain: Error.Domain.searchMethod, code: 5001, userInfo: [NSLocalizedDescriptionKey:Error.Message.Error_Occurred]))
                    return
                }
                
                //Parse through the response that contains elements photos/photo.
                if let photosDictionary = data?[Response.Key.PhotosDictionary] as? [String:AnyObject],
                   let photosArray = photosDictionary[Response.Key.Photo] as? [[String:AnyObject]]
                {
                    var photoURLS = [String]()
                    
                    for photo in photosArray
                    {
                        //Get the URLs of the photos.
                        if let photoURL = photo[Response.Key.MediumURL] as? String
                        {
                            photoURLS.append(photoURL)
                        }
                    }
                    completionHandlerForSearchPhotos(photoURLS, nil)
                }
                else
                {
                    completionHandlerForSearchPhotos(nil, NSError(domain: Error.Domain.searchMethod, code: 5002, userInfo: [NSLocalizedDescriptionKey: Error.Message.Invalid_Response]))
                }
            }
            else
            {
                //Failure in invoking Flickr API.
                completionHandlerForSearchPhotos(nil,error)
            }
        }
    }
}
