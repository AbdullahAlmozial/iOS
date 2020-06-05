//
//  apiflicker.swift
//  virtualTourist
//
//  Created by عبدالله محمد on 2/1/19.
//  Copyright © 2019 udacity. All rights reserved.
//

import Foundation

class API {
    static func getStudentLocations(  completion: @escaping(_ imageUrls: [String]?, _ error: String?) -> Void) {
        guard let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=09c4932572608e6913cd54393e2a5bd7&lat=32.2325&lon=76.3242&format=json&nojsoncallback=1&auth_token=72157706420447364-e5dd819f784a06cf&api_sig=3f72594a06986d20a54642da391a788d") else {
            completion(nil, "problem with url")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        var photoUrls = [String]()
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode { //Request sent succesfully
                if statusCode >= 200 && statusCode < 300 { //Response is ok
                    
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: []),
                        let dict = json as? [String:Any],
                        let results = dict["photos"] as? [String : AnyObject]  {
                        if let photos = results["photo"] as? [[String:AnyObject]] {
                        for photo in photos {
                            let id = photo["id"] as? String
                            let secret = photo["secret"] as? String
                            let server = photo["server"] as? String
                            let farm = photo["farm"] as? String
                let image_url:String = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
                            
                        }
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                completion(photoUrls, nil)
            }
            
        }
        task.resume()
    }
}
    


