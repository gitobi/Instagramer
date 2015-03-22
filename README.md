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

```swift
import Instagramer

var _instagramer = Instagramer(clientId: /* your application's CLIENT_ID */)

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
