//
//  Converter.swift
//  VirtualTourist
//
//  Created by Sudeep Agrawal on 12/27/16.
//  Copyright © 2016 Agrawal. All rights reserved.
//

import Foundation

class Converter
{
    //MARK : Convert a Dictionary to NSData.
    static func toNSData(requestBody : [String:AnyObject]? = nil) -> NSData
    {
        var jsonData:NSData! = nil
        do
        {
            jsonData = try JSONSerialization.data(withJSONObject: requestBody!, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData!
            //print ("Request => \(jsonData)")
        }
        catch let error as NSError
        {
            print(error)
        }
        parseJSONToAnyObject(response: jsonData) { (result, error) in
        }
        return jsonData
    }
    
    //MARK : This method will convert the JSON response to a usable AnyObject.
    static func parseJSONToAnyObject(response: NSData, completionHandler: (_ result:AnyObject?, _ error:NSError?)-> Void)
    {
        var parsedResponse:Any! = nil
        do
        {
            parsedResponse = try JSONSerialization.jsonObject(with: response as Data, options: JSONSerialization.ReadingOptions.allowFragments)
            //print("parseJSONToAnyObject :  " + parsedResponse.description)
            completionHandler(parsedResponse as AnyObject, nil)
        }
            
        catch let error as NSError
        {
            //Failure has occurred, don't return any results.
            completionHandler(nil, error)
        }
    }
}
