//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Sudeep Agrawal on 12/27/16.
//  Copyright © 2016 Agrawal. All rights reserved.

import Foundation

// Ref: https://www.flickr.com/services/api/flickr.photos.search.html
extension FlickrClient
{
    struct Constants
    {
        //Ref: www.grokswift.com/building-urls
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest/"
        
        
        static let PhotoLimit = 20
        
        struct BBoxLimits
        {
            static let Width = 1.0
            static let Height = 1.0
            static let LatRange = (-90.0, 90.0)
            static let LonRange = (-180.0, 180.0)
        }
    }

    struct Request
    {
        struct ParamKey
        {
            static let Method = "method"
            static let APIKey = "api_key"
            static let Extras = "extras"
            static let BoundingBox = "bbox"
            static let Format = "format"
            static let NoJSONCallback = "nojsoncallback"
            static let Page = "page"
            static let PerPage = "per_page"
            static let Longitude = "lon"
            static let Latitude = "lat"
        }
    
        struct ParamVal
        {
            //static let Method = "flickr.photos.search"
            static let Method = "flickr.photos.getRecent"
            static let APIKey = "c9e2bdb5c6d04dfd0c58742eb4215dfc"
            static let MediumURL = "url_m"
            static let Format = "json"
            static let DisableJSONCallback = "1"
            static let PhotosPerPage = "10"
        }
    }
    
    struct Response
    {
        struct Key
        {
            static let Status = "stat"
            static let PhotosDictionary = "photos"
            static let Photo = "photo"
            static let MediumURL = "url_m"
            static let Title = "title"
            static let Pages = "pages"
            static let Total = "total"
        }
    }
    
    struct Error
    {
        struct Domain
        {
            static let SearchMethod="VT.SEARCH_PHOTOS"
            static let DownloadMethod="VT.DOWNLOAD_PHOTOS"
        }
        
        struct Message
        {
            static let Error_Occurred = "Error occurrred in API response."
            static let Invalid_Response = "API response is not parsable for necessary information."
            static let Download_Not_Possible = "Unable to download pic."
        }
    }
}
