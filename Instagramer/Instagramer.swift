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
    private var _alamofireRequest: Alamofire.Request
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
        }
        return self
    }

    private var _internalCallbackComplete : ((models: [T]) -> Void)?
    internal func internalComplete(callback: ((models: [T]) -> Void)) {
        _internalCallbackComplete = callback
    }
    
    public func complete(callback: ((models: [T]) -> Void)) -> Self {
        var internalCallbackComplete = _internalCallbackComplete
        completeJSON { (json: SwiftyJSON.JSON) in
            var models = InstagramerModelCreate<T>.create(json)
            if let valid = internalCallbackComplete {
                    valid(models: models)
            }
            callback(models: models)
        }
        
        return self
    }

}

public class InstagramerUser: InstagramerModel {
    private var _id                 : String
    private var _username           : String
    private var _full_name          : String
    private var _profile_picture    : String

    init(json: JSON) {
        _id              = json["id"].stringValue
        _username        = json["username"].stringValue
        _full_name       = json["full_name"].stringValue
        _profile_picture = json["profile_picture"].stringValue
    }
}

public class InstagramerLocation: InstagramerModel {
    private var _id         : String
    private var _name       : String
    private var _latitude   : Double
    private var _longitude  : Double
    
    init(json: JSON){
        _id        = json["id"].stringValue
        _name      = json["name"].stringValue
        _latitude  = json["latitude"].doubleValue
        _longitude = json["longitude"].doubleValue
    }
}

public class InstagramerMediaDitail: InstagramerModel {
    private var _url    : String
    private var _width  : Int
    private var _height : Int
    
    public var url      : String { return _url }
    public var width    : Int    { return _width }
    public var height   : Int    { return _height }
    
    init(json: JSON){
        _url    = json["url"].stringValue
        _width  = json["width"].intValue
        _height = json["height"].intValue
    }
}

public class InstagramerMediaResolution: InstagramerModel {
    private var _low_resolution         : InstagramerMediaDitail
    private var _thumbnail              : InstagramerMediaDitail
    private var _standard_resolution    : InstagramerMediaDitail
    
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
    private var _attribution	: String?
    private var _videos         : InstagramerMediaResolution?
    private var _tags           : [String]
    private var _location       : InstagramerLocation
    private var _comments       : JSON
    private var _filter         : String
    private var _created_time   : Int
    private var _link           : String
    private var _likes          : JSON
    private var _images         : InstagramerMediaResolution
    private var _users_in_photo : JSON
    private var _caption        : JSON
    private var _type           : String
    private var _id             : String
    private var _user           : InstagramerUser
    
    public var createdTime  : Int { return _created_time }
    public var images       : InstagramerMediaResolution { return _images }
    
    init(json: JSON){
        _attribution    = json["attribution"].string
        _tags           = json["tags"].arrayObject as [String]
        _location       = InstagramerLocation(json: json["location"])
        _comments       = json["comments"]
        _filter         = json["filter"].stringValue
        _created_time   = json["created_time"].intValue
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
        var str = "\(_created_time),\(_id),\(_link)"
        return str
    }

}

public class InstagramerModel: NSObject {
    
}

public class InstagramerModelCreate<T: InstagramerModel> {
    
    public class func create(json: JSON) -> [T] {
        var models = [T]()
        NSLog(json.debugDescription)
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
    
    private var _clientId : String
    private var _accessToken : String?
    
    private var _endPointURL = "https://api.instagram.com/v1/"
    
    public init(clientId: String) {
        _clientId = clientId
    }
    
    private func accessParams() -> [String: AnyObject] {
        if let accessToken = _accessToken {
            return ["access_token": accessToken]
        } else {
            return ["client_id": _clientId]
        }
    }
    
    public func mediaPopuler() -> InstagramerRequest<InstagramerMedia> {
        var partialURL = "media/popular"
        return request(partialURL, parameters: accessParams())
        
    }
    
    private var _lastRequestMinTimestamp : Int?
    private var _lastRequestMaxTimestamp : Int?
    private var _lastRequestGettingMinTimestamp : Int?
    private var _lastRequestGettingMaxTimestamp : Int?
    
    
    public func mediaSearch(
        lat: Double? = nil
        , lng: Double? = nil
        , distance: Int? = nil
        , minTimestamp: Int? = nil
        , maxTimestamp: Int? = nil
    ) -> InstagramerRequest<InstagramerMedia> {
        
        var partialURL = "media/search"
        var parameters = accessParams()
        if let valid = lat { parameters["lat"] = lat }
        if let valid = lng { parameters["lng"] = lng }
        if let valid = distance { parameters["distance"] = distance }
        if let valid = minTimestamp {
            parameters["min_timestamp"] = minTimestamp
            _lastRequestMinTimestamp = minTimestamp
        }
        if let valid = maxTimestamp {
            parameters["max_timestamp"] = maxTimestamp
            _lastRequestMaxTimestamp = maxTimestamp
        }
        
        var _request : InstagramerRequest<InstagramerMedia> = request(partialURL, parameters: parameters)
        _request.internalComplete { [weak self] (_models: [InstagramerMedia]) in
            if 0 < _models.count {
                self?._lastRequestGettingMinTimestamp = _models[0].createdTime
                self?._lastRequestGettingMaxTimestamp = _models[_models.count - 1].createdTime
                
                NSLog("getting \(self?._lastRequestGettingMinTimestamp) ~ \(self?._lastRequestGettingMaxTimestamp)")
            }
        }
        return _request
    }
    
    private func request<T: InstagramerModel>(partialURL: String, parameters: [String: AnyObject]?) -> InstagramerRequest<T> {
        var alamofireRequest = Alamofire.request(.GET, _endPointURL + partialURL, parameters: parameters, encoding: .URL)
        var instagramerRequest = InstagramerRequest<T>(alamofireRequest: alamofireRequest)
        return instagramerRequest
    }
    
}
