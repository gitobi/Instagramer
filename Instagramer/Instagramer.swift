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
//            NSLog(_swiftyJson.debugDescription)
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
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                var models = InstagramerModelCreate<T>.create(json)
                if let valid = internalCallbackComplete {
                        valid(models: models)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    callback(models: models)
                    return
                }
            }
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
    
    public var id           : String { return _id }
    public var name         : String { return _name }
    public var latitude     : Double { return _latitude }
    public var longitude    : Double { return _longitude }
    
    init(json: JSON){
        _id        = json["id"].stringValue
        _name      = json["name"].stringValue
        _latitude  = json["latitude"].doubleValue
        _longitude = json["longitude"].doubleValue
    }
    
    override public var description: String {
        var str = "\(_id),\(_name),\(_latitude),\(_longitude)"
        return str
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
    private var _created        : String
    
    public var id           : String    { return _id }
    public var createdTime  : Int       { return _created_time }
    public var created      : String    { return _created }
    public var images       : InstagramerMediaResolution { return _images }
    
    init(json: JSON){
        _attribution    = json["attribution"].string
        _tags           = json["tags"].arrayObject as! [String]
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
        
        // convert UNIX time
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(_created_time))
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        _created = formatter.stringFromDate(date)
        
        
//        NSLog("\(_location)")
    }
    
    override public var description: String {
        var str = "\(_created),\(_created_time),\(_id),\(_link)"
        return str
    }

}

public class InstagramerOAuth {
    
    private let _oauthURL = "https://instagram.com/oauth/authorize/"

    private var _clientId           : String
    private var _accessToken        : String?
    
    private var _accessTokenSaveKey : String?

    private var _redirectURI        : String?
    private var _error              : String?
    private var _error_reason       : String?
    private var _error_description  : String?
    
    private var _closurePermitted   : (() -> Void)?
    private var _closureDenied      : (() -> Void)?

    public var clientId         : String { return _clientId }
    public var accessToken      : String? { return _accessToken }
    public var error            : String? { return _error }
    public var errorReason      : String? { return _error_reason }
    public var errorDescription : String? { return _error_description }
    public var errors           : (error: String?, reason: String?, description: String?) { return (_error, _error_reason, _error_description) }
    
    private init(clientId: String) {
        _clientId = clientId
    }

    internal var accessParameters : [String:AnyObject] {
        var parameters = [String:AnyObject]()
        if let valid = _accessToken {
            parameters["access_token"] = _accessToken
        } else {
            parameters["client_id"] = _clientId
        }
        return parameters
    }

    internal func replaceAccessParameters(inout parameters : [String:AnyObject]) {
        parameters["access_token"] = nil
        parameters["client_id"] = nil
        for (key, value) in accessParameters {
            parameters[key] = value
        }
    }

    internal func oauth(accessToken: String) {
        _accessToken = accessToken
    }
    
    /**
    
    :param: accessTokenSaveKey
    :param: forceRefleshAccessToken
    :param: redirectURI
    :param: permitted
    :param: denied
    
    :returns: true if need oauthHandle
    */
    internal func oauth(accessTokenSaveKey: String?, forceRefleshAccessToken: Bool = false, redirectURI: String, permitted: (() -> Void), denied: (() -> Void)) -> Bool {
        _accessToken = nil
        _accessTokenSaveKey = accessTokenSaveKey
        if let valid = _accessTokenSaveKey {
            // load
            if forceRefleshAccessToken {
                removeUserDefaults(valid)
            }
            if let accessToken = loadUserDefaults(valid) {
                _accessToken = accessToken
                // TODO need check loaded accessToken
            }
        }
        
        if nil != _accessToken {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                permitted()
                return
            }
            return false
            
        } else {
            // did not saved or reflash
            _redirectURI      = redirectURI
            _closurePermitted = permitted
            _closureDenied    = denied
            
            var parameters = ["client_id=" + (_clientId ?? "")]
            parameters.append("redirect_uri=" + redirectURI)
            parameters.append("response_type=token")
            var urlString = _oauthURL + "?" + join("&", parameters)

//            NSLog("\(urlString)")
            var url = NSURL(string: urlString)
            UIApplication.sharedApplication().openURL(url!)
            
            return true
        }
    }

    internal func oauthHandle(callbackURL: NSURL?) -> Bool {

//        NSLog("\(callbackURL)")
        
        var urlString = schemeHostPathWith(callbackURL)
        if _redirectURI == urlString {
            let parameters = parametersWith(callbackURL)
            if let accessToken = parameters["access_token"] {
                // access permit
                _accessToken = accessToken
                if let valid = _accessTokenSaveKey {
                    saveUserDefaults(valid, value: accessToken)
                }
                if let valid = _closurePermitted {
                    valid()
                }
                return true
                
            } else if let error = parameters["error"] {
                // access denied
                _error = error
                _error_reason = parameters["error_reason"]
                _error_description = parameters["error_description"]
                if let valid = _closureDenied {
                    valid()
                }
                return true
            }
        }
        
        // not specified URL
        return false
    }
    
    // MARK: URL utils
    private func parametersWith(url: NSURL?) -> [String:String] {
        var parameters = [String:String]()
        if let valid = url {
            let accessTokenKey = "access_token"
            var urlString = valid.absoluteString
            let successPrefix = (_redirectURI ?? "") + "#\(accessTokenKey)="
            
//            NSLog("path:\(urlString)")
//            NSLog("pref:\(successPrefix)")
            
            if let range = urlString?.rangeOfString(successPrefix) {
                // access permit
                urlString?.removeRange(range)
                parameters[accessTokenKey] = urlString
                
            } else if let components = NSURLComponents(URL: valid, resolvingAgainstBaseURL: false) {
                // access denied
                for item in components.queryItems as! [NSURLQueryItem] {
                    parameters[item.name] = item.value?.stringByReplacingOccurrencesOfString("+", withString: " ")
                }
            }
        }
        return parameters
    }
    
    private func schemeHostPathWith(url: NSURL?) -> String {
        var string = ""
        if let valid = url {
            string = (valid.scheme! ?? "") + "://" + (valid.host! ?? "") + (valid.path! ?? "")
        }
        return string
    }

    // MARK: NSUserDefaults
    private let _keyPrefix = "Instagramer_"
    private func saveUserDefaults(key: String, value: String) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(value, forKey: _keyPrefix + key)
        ud.synchronize()
    }
    
    private func loadUserDefaults(key: String) -> String? {
        let ud = NSUserDefaults.standardUserDefaults()
        return ud.objectForKey(_keyPrefix + key) as? String
    }

    private func removeUserDefaults(key: String) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.removeObjectForKey(_keyPrefix + key)
        ud.synchronize()
    }

}

public class InstagramerModel: NSObject {
    
}

internal class InstagramerModelCreate<T: InstagramerModel> {
    
     class func create(json: JSON) -> [T] {
        var models = [T]()
//        NSLog(json.debugDescription)
        for (index: String, subJson: JSON) in json["data"] {
//            NSLog(subJson.debugDescription)
            let type = subJson["type"].string
            if ("image" == type) || ("video" == type) {
                var model = InstagramerMedia(json: subJson)
                models.append(model as! T)
                
            } else {
                // TODO unknown type
                NSLog("unknown type : \(type)")
            }
        }
        return models
    }
}

public class Instagramer {
    
    // MARK: init and auth
    
    private var _oAuth : InstagramerOAuth
    public var oAuth : InstagramerOAuth { return _oAuth }
    
    public init(clientId: String) {
        _oAuth = InstagramerOAuth(clientId: clientId)
    }

    public func oAuth(accessToken: String) {
        return _oAuth.oauth(accessToken)
    }

    public func oAuth(accessTokenSaveKey: String?, forceRefleshAccessToken: Bool = false, redirectURI: String, permitted: (() -> Void), denied: (() -> Void)) -> Bool {
        return _oAuth.oauth(accessTokenSaveKey, forceRefleshAccessToken: forceRefleshAccessToken, redirectURI: redirectURI, permitted: permitted, denied: denied)
    }
    
    public func oAuthHandle(callbackURL: NSURL?) -> Bool {
        return _oAuth.oauthHandle(callbackURL)
    }
    
    // MARK: request
    
    private let _endPointURL = "https://api.instagram.com/v1/"

    public func mediaPopuler() -> InstagramerRequest<InstagramerMedia> {
        var partialURL = "media/popular"
        return request(partialURL, parameters: _oAuth.accessParameters)
        
    }
    
    private var _lastMediaSearchParameters : [String:AnyObject]?
    private var _lastResponseMinTimestamp : Int?
    private var _lastResponseMaxTimestamp : Int?
    
    public func mediaSearch(
        lat: Double? = nil
        , lng: Double? = nil
        , distance: Int? = nil
        , minTimestamp: Int? = nil
        , maxTimestamp: Int? = nil
    ) -> InstagramerRequest<InstagramerMedia> {
        
        var parameters = [String:AnyObject]()
        if let valid = lat { parameters["lat"] = lat }
        if let valid = lng { parameters["lng"] = lng }
        if let valid = distance { parameters["distance"] = distance }
        if let valid = minTimestamp { parameters["min_timestamp"] = minTimestamp }
        if let valid = maxTimestamp { parameters["max_timestamp"] = maxTimestamp }
        return mediaSearch(&parameters)
    }
    
    public func mediaSearchNext() -> InstagramerRequest<InstagramerMedia>? {
        if let valid = _lastMediaSearchParameters {
            var parameters = valid
            parameters["min_timestamp"] = String(_lastResponseMaxTimestamp! + 1)
            parameters["max_timestamp"] = nil
            return mediaSearch(&parameters)
        }
        return nil
    }
    
    public func mediaSearchPrev() -> InstagramerRequest<InstagramerMedia>? {
        if let valid = _lastMediaSearchParameters {
            var parameters = valid
            let min = (_lastResponseMinTimestamp! - 1) - (60 * 60 * 24 * 7)
            let max = _lastResponseMinTimestamp! - 1
            parameters["min_timestamp"] = String(min)
            parameters["max_timestamp"] = String(max)
            return mediaSearch(&parameters)
        }
        return nil
    }

    private func mediaSearch(inout parameters: [String:AnyObject]) -> InstagramerRequest<InstagramerMedia> {

        var partialURL = "media/search"
        _oAuth.replaceAccessParameters(&parameters)
        
        var _request : InstagramerRequest<InstagramerMedia> = request(partialURL, parameters: parameters)
        _request.internalComplete { [weak self] (_models: [InstagramerMedia]) in
            if 0 < _models.count {
                self?.setLastResponse(parameters, responseMinTime: _models.last!.createdTime, responseMaxTime: _models[0].createdTime)
                
                var tmpMin = parameters["min_timestamp"] as! String?
                var tmpMax = parameters["max_timestamp"] as! String?
                NSLog("request  \(tmpMin) ~ \(tmpMax)")
                NSLog("response \(self?._lastResponseMinTimestamp) ~ \(self?._lastResponseMaxTimestamp)")
            }
        }
        return _request
    }
    
    private func setLastResponse(requestParameters: [String:AnyObject], responseMinTime: Int, responseMaxTime: Int) {
        _lastMediaSearchParameters = requestParameters
        if nil == _lastResponseMaxTimestamp {
            _lastResponseMaxTimestamp = responseMaxTime
        } else {
            _lastResponseMaxTimestamp = max(_lastResponseMaxTimestamp!, responseMaxTime)
        }
        if nil == _lastResponseMinTimestamp {
            _lastResponseMinTimestamp = responseMinTime
        } else {
            _lastResponseMinTimestamp = min(_lastResponseMinTimestamp!, responseMinTime)
        }
    }
    
    private func request<T: InstagramerModel>(partialURL: String, parameters: [String: AnyObject]?) -> InstagramerRequest<T> {
        var alamofireRequest = Alamofire.request(.GET, _endPointURL + partialURL, parameters: parameters, encoding: .URL)
        var instagramerRequest = InstagramerRequest<T>(alamofireRequest: alamofireRequest)
        return instagramerRequest
    }
    
}
