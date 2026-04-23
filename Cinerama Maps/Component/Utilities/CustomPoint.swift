//
//  CustomPoint.swift
//  Cinerama Maps
//
//  Created by Techimmense Software Solutions on 24/10/24.
//

import Foundation
import GoogleMaps
import GoogleMapsUtils

class CustomPointAnnotation: GMSMarker {
    
    var imageName: String!
    var providerName: String!
    var city_Address: String!
    var providerRating: String!
    var point:String!
    var placeId:String!
    var lat:String!
    var lon:String!
    var fav:Bool!
    var cityName: String!
    var cityNameAr: String!
    var iconZoomed: UIImage?
    var iconNotZoomed: UIImage?
}


class AnnotationItem: NSObject, GMUClusterItem {

    // REQUIRED by GMUClusterItem
    var position: CLLocationCoordinate2D

    // Your extra properties
    var imageName: String?
    var providerName: String?
    var city_Address: String?
    var providerRating: String?
    var point: String?
    var placeId: String?
    var lat: String?
    var lon: String?
    var fav: Bool = false
    var cityName: String?
    var cityNameAr: String?
    var iconZoomed: UIImage?
    var iconNotZoomed: UIImage?
    var imgFor2: UIImage?
    var imgFor3: UIImage?

    init(coordinate: CLLocationCoordinate2D) {
        self.position = coordinate
        super.init()
    }
}
