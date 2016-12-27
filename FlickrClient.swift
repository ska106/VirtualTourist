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
    
    // MARK : Prepare the HTTP header for the request.
    func setHeaders(request: NSMutableURLRequest) -> NSMutableURLRequest
    {
        request.addValue(HeaderValues.JSON, forHTTPHeaderField: HeaderKeys.Accept)
        request.addValue(HeaderValues.JSON, forHTTPHeaderField: HeaderKeys.ContentType)
        return request
    }

    // MARK : Function to initiate the API call via. Task.
    func makeTaskCall (request:URLRequest , completionHandlerForTaskCall : @escaping (_ result : AnyObject? , _ error: NSError?) -> Void)
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
    
    //Search Photos
    func searchPhotos()
    {
    }
    //DownloadPhotos
    func downloadPhotos()
    {
    }
}
