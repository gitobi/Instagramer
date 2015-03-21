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

public class InstagramerRequest<T: InstagramerModel> {
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
    
    private func completeJSON(callback: ((json: SwiftyJSON.JSON) -> Void)) -> Self {
        _alamofireRequest.responseJSON { (_request: NSURLRequest, _response: NSHTTPURLResponse?, _data: AnyObject?, _error: NSError?) in
            var _swiftyJson: SwiftyJSON.JSON
            if _error != nil || _data == nil{
                _swiftyJson = SwiftyJSON.JSON.nullJSON
            } else {
                _swiftyJson = SwiftyJSON.JSON(_data!)
            }
            callback(json: _swiftyJson)
            return
        }
        return self
    }
    
    public func complete(callback: ((models: [T]) -> Void)) -> Self {
        completeJSON { [weak self] (json: SwiftyJSON.JSON) in
            var models = InstagramerModelCreate<T>.create(json)
            callback(models: models)
            return
        }
        return self
    }

}

public class InstagramerUser: InstagramerModel {
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
public class InstagramerLocation: InstagramerModel {
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
public class InstagramerMediaDitail: InstagramerModel {
    var _url    : String
    var _width  : Float
    var _height : Float
    public var url      : String { return _url }
    public var width    : Float  { return _width }
    public var height   : Float  { return _height }
    init(json: JSON){
        _url    = json["url"].stringValue
        _width  = json["width"].floatValue
        _height = json["height"].floatValue
    }
}
public class InstagramerMediaResolution: InstagramerModel {
    var _low_resolution         : InstagramerMediaDitail
    var _thumbnail              : InstagramerMediaDitail
    var _standard_resolution    : InstagramerMediaDitail
    public var low              : InstagramerMediaDitail { return _low_resolution }
    public var thumbnail        : InstagramerMediaDitail { return _thumbnail }
    public var standard         : InstagramerMediaDitail { return _standard_resolution }
    init(json: JSON){
        _low_resolution      = InstagramerMediaDitail(json: json["low_resolution"])
        _thumbnail           = InstagramerMediaDitail(json: json["thumbnail"])
        _standard_resolution = InstagramerMediaDitail(json: json["standard_resolution"])
    }
}
public class InstagramerMedia: InstagramerModel {
    var _attribution	: String?
    var _videos         : InstagramerMediaResolution?
    var _tags           : [String]
    var _location       : InstagramerLocation
    var _comments       : JSON
    var _filter         : String
    var _created_time   : String
    var _link           : String
    var _likes          : JSON
    var _images         : InstagramerMediaResolution
    var _users_in_photo : JSON
    var _caption        : JSON
    var _type           : String
    var _id             : String
    var _user           : InstagramerUser
    public var images   : InstagramerMediaResolution { return _images }
    
    init(json: JSON){
        _attribution    = json["attribution"].string
        _tags           = json["tags"].arrayObject as [String]
        _location       = InstagramerLocation(json: json["location"])
        _comments       = json["comments"]
        _filter         = json["filter"].stringValue
        _created_time   = json["created_time"].stringValue
        _link           = json["link"].stringValue
        _likes          = json["likes"]
        _images         = InstagramerMediaResolution(json: json["images"])
        _users_in_photo = json["users_in_photo"]
        _caption        = json["caption"]
        _type           = json["type"].stringValue
        _id             = json["id"].stringValue
        _user           = InstagramerUser(json: json["user"])
        
        if "video" == _type {
            _videos = InstagramerMediaResolution(json: json["videos"])
        }
        
    }
    
    override public var description: String {
        var str = "\(_id),\(_link)"
        return str
    }

}
public class InstagramerModel: NSObject {
    
}
public class InstagramerModelCreate<T: InstagramerModel> {
    
    public class func create(json: JSON) -> [T] {
        var models = [T]()
//        NSLog(json.debugDescription)
        for (index: String, subJson: JSON) in json["data"] {
//            NSLog(subJson.debugDescription)
            let type = subJson["type"].string
            if ("image" == type) || ("video" == type) {
                var model = InstagramerMedia(json: subJson)
                models.append(model as T)
                
            } else {
                // TODO unknown type
                NSLog("unknown type : \(type)")
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
    
    public func mediaPopuler() -> InstagramerRequest<InstagramerMedia> {
        var _partialURL = "media/popular"
        return request(_partialURL, parameters: accessParams())
        
    }
    
    private func request<T: InstagramerModel>(partialURL: String, parameters: [String: AnyObject]?) -> InstagramerRequest<T> {
        var alamofireRequest = Alamofire.request(.GET, _endPointURL + partialURL, parameters: parameters, encoding: .URL)
        var instagramerRequest = InstagramerRequest<T>(alamofireRequest: alamofireRequest)
        return instagramerRequest
    }
    
}