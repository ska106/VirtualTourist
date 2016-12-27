//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Sudeep Agrawal on 12/27/16.
//  Copyright © 2016 Agrawal. All rights reserved.
//

import Foundation

extension FlickrClient
{
    struct Constants
    {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest/"
    }
    
    struct Methods
    {
        static let SearchPhotos = "flickr.photos.search"
    }
    
    struct HeaderKeys
    {
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
    }
    
    struct HeaderValues
    {
        static let JSON = "application/json"
    }

    struct ParameterKeys
    {
        static let Longitude = "lon"
        static let Latitude = "lat"
        static let Extras = "extras"
        static let APIKey = "api_key"
        static let Method = "method"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let PerPage = "per_page"
        static let Page = "page"
    }
    
    struct ParameterValues
    {
        static let MediumURL = "url_m"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let PhotosPerPage = "25"
    }
    
    struct APIKeys
    {
        static let flickr = "c9e2bdb5c6d04dfd0c58742eb4215dfc"
    }
    
    struct JSONResponseKeys
    {
        static let PhotosDictionary = "photos"
        static let PhotosArray = "photo"
        static let MediumURL = "url_m"
    }
}
