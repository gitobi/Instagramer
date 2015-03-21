//
//  Instagramer.swift
//  Instagramer
//
//  Created by OnodaTakuro on 2015/03/21.
//
//

import Foundation
import Alamofire
import SwiftyJSON

public class InstagramerRequest {
    var _alamofireRequest: Alamofire.Request
    init(alamofireRequest: Alamofire.Request) {
        _alamofireRequest = alamofireRequest
    }
    
    public func progress(callback: ((bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) -> Void)) -> Self {
        _alamofireRequest.progress(closure: callback)
        return self
    }
    public func response(callback: ((request: NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) -> Void)) -> Self {
        _alamofireRequest.response(callback)
        return self
    }
    public func complete(callback: ((json: SwiftyJSON.JSON) -> Void)) -> Self {
        _alamofireRequest.responseJSON() { (_request: NSURLRequest, _response: NSHTTPURLResponse?, _data: AnyObject?, _error: NSError?) in
            var _swiftyJson: SwiftyJSON.JSON
            if _error != nil || _data == nil{
                _swiftyJson = SwiftyJSON.JSON.nullJSON
            } else {
                _swiftyJson = SwiftyJSON.JSON(_data!)
            }
            
            callback(json: _swiftyJson)
        }
        return self
    }

}

public class InstagramerUser {
    var _id                 : String
    var _username           : String
    var _full_name          : String
    var _profile_picture    : String

    init(json: JSON) {
        _id              = json["id"].stringValue
        _username        = json["username"].stringValue
        _full_name       = json["full_name"].stringValue
        _profile_picture = json["profile_picture"].stringValue
    }
}
public class InstagramerLocation {
    var _id         : String
    var _name       : String
    var _latitude   : Double
    var _longitude  : Double
    
    init(json: JSON){
        _id        = json["id"].stringValue
        _name      = json["name"].stringValue
        _latitude  = json["latitude"].doubleValue
        _longitude = json["longitude"].doubleValue
    }
}
public class InstagramerImageDitail {
    var _url    : String
    var _width  : Float
    var _height : Float
    init(json: JSON){
        _url    = json["url"].stringValue
        _width  = json["width"].floatValue
        _height = json["height"].floatValue
    }
}
public class InstagramerImage {
    var _low_resolution         : InstagramerImageDitail
    var _thumbnail              : InstagramerImageDitail
    var _standard_resolution    : InstagramerImageDitail
    init(json: JSON){
        _low_resolution      = InstagramerImageDitail(json: json["low_resolution"])
        _thumbnail           = InstagramerImageDitail(json: json["thumbnail"])
        _standard_resolution = InstagramerImageDitail(json: json["standard_resolution"])
    }
}
public class InstagramerMedia {
    var _attribution	: String?
    var _tags           : [String]
    var _location       : InstagramerLocation
    var _comments       : JSON
    var _filter         : String
    var _created_time   : String
    var _link           : String
    var _likes          : JSON
    var _images         : InstagramerImage
    var _users_in_photo : JSON
    var _caption        : JSON
    var _type           : String
    var _id             : String
    var _user           : InstagramerUser
    
    init(json: JSON){
        _attribution    = json["attribution"].string
        _tags           = json["tags"].arrayObject as [String]
        _location       = InstagramerLocation(json: json["location"])
        _comments       = json["comments"]
        _filter         = json["filter"].stringValue
        _created_time   = json["created_time"].stringValue
        _link           = json["link"].stringValue
        _likes          = json["likes"]
        _images         = InstagramerImage(json: json["images"])
        _users_in_photo = json["users_in_photo"]
        _caption        = json["caption"]
        _type           = json["type"].stringValue
        _id             = json["id"].stringValue
        _user           = InstagramerUser(json: json["user"])
        
    }
    
    
}
public class InstagramerModel {
    public class func medias(json: JSON) -> [InstagramerMedia] {
        var models = [InstagramerMedia]()
        for (index: String, subJson: JSON) in json["data"] {
            if "media" == subJson["type"].string {
                var model = InstagramerMedia(json: subJson)
                models.append(model)
            }
        }
        return models
    }
}

public class Instagramer {
    
    var _clientId : String
    var _accessToken : String?
    
    var _endPointURL = "https://api.instagram.com/v1/"
    
    public init(clientId: String) {
        _clientId = clientId
    }
    
    public func accessParams() -> [String: AnyObject] {
        if let accessToken = _accessToken {
            return ["access_token": accessToken]
        } else {
            return ["client_id": _clientId]
        }
    }
    
    public func mediaPopuler() -> InstagramerRequest {
        var _partialURL = "media/popular"
        return request(_partialURL, parameters: accessParams())
        
    }
    
    private func request(partialURL: String, parameters: [String: AnyObject]?) -> InstagramerRequest {
        var alamofireRequest = Alamofire.request(.GET, _endPointURL + partialURL, parameters: parameters, encoding: .URL)
        var instagramerRequest = InstagramerRequest(alamofireRequest: alamofireRequest)
        return instagramerRequest
    }
    
}