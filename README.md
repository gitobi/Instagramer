# Instagramer
Instagram API wrapper

## Installation
### [CocoaPods](http://cocoapods.org)
`Podfile`:
```ruby
use_frameworks!
pod 'Instagramer', :git => 'https://github.com/gitobi/Instagramer.git'
```

dependency [Alamofire](https://github.com/Alamofire/Alamofire) and [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)

## Usage

`InstagramerDemo.swift`:
```swift
import Instagramer

public class InstagramerDemo {
    class var sharedInstance : InstagramerDemo {
        struct Static {
            static let instance = InstagramerDemo()
        }
        return Static.instance
    }
    private init() { }


    var _instagramer = Instagramer(clientId: /* your application's CLIENT_ID */)

    func setup() {
        var needCallbackURLHandle = _instagramer.oAuth(
            "access_token_key"
            , redirectURI: /* your application's REDIRECT_URI */
            , permitted : { [weak self] in
                NSLog("permited : \(self?._instagramer.oAuth.accessToken)")
            
            }, denied : { [weak self] in
                NSLog("denied   : \(self?._instagramer.oAuth.errors)")
            }
    }
    
    func oauthCallbackHandle(url: NSURL) -> Bool {
        return _instagramer.oAuthHandle(url)
    }
    
    func mediaSearch() {
        _instagramer.mediaSearch(lat: /* latitude */, lng: /* longitude */)
        .progress { (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
            NSLog("\(bytesRead)")
        }
        .response() { (request, response, data, error) in
            NSLog("\(request)")
        }
        .complete() { (models: [InstagramerMedia]) in
            for model in models {
            NSLog("\(models.images.thumbnail.url)")
        }
    }
```

`AppDelegate.swift`:
```swift
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return InstagramerDemo.sharedInstance.oauthCallbackHandle(url)
    }
```
