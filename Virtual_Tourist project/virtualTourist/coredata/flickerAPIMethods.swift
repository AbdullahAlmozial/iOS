//
//  API.swift
//  virtualTourist
//
//  Created by عبدالله محمد on 2/3/19.
//  Copyright © 2019 udacity. All rights reserved.
//

import Foundation
import UIKit

class flickerAPIMethods : NSObject {
    

    
    static let staticflicker = flickerAPIMethods()
    
    func downloadsimages(with url: String, completion: @escaping(_ data: Data?, _ error: String?) -> Void) {
        
        datatest(with: url, Dataconvert: false) { (response, error) in
            completion(response as? Data, error)
        }
    }
    
    
    
    private func datatest(with url: String, Dataconvert: Bool, completion: @escaping(_ response: AnyObject?, _ error: String?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: url)!)
         var err: String?
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if (error == nil) {
                
                if let data = data{
                    if let code = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(code){
                        if Dataconvert {
                            self.usefulData(data, completion: completion)
                        } else {
                            completion(data as AnyObject?, nil)
                        }
                        
                    }
                    else {
                         err = " Not a successfull status code"
                       completion(nil, err)
                    }
                }
                    
                else {
                      err = " No data was returned by the request!"
                   completion(nil, err)
                    
                }
            }

            else{
                  err = " No data was returned by the request!"
                  completion(nil, err)
              
            }
            
            }
        
        task.resume()
    }
    
     func usefulData(_ data: Data, completion: (_ response: AnyObject?, _ error: String?) -> Void) {
        var Result: AnyObject! = nil
        
        do {
            Result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            
            
            completion(nil, "problem with json")
        }
        completion(Result, nil)
    }
    
    
    static func postSession(latitude: Double, longitude: Double , completion: @escaping (_ imageUrls: [String]?,String?)->Void) {
        let randomPage = arc4random_uniform(10) + 1
        guard let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=7b1d4cc51d4be4957f4d5df3b3ea6d3e&tags=&accuracy=11&lat=\(latitude)&lon=\(longitude)&per_page=10&page=\(randomPage)&format=json&nojsoncallback=1" ) else {
            completion(nil ,"problem with postSession url ")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var err: String?
            var resultt: [String] = []
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode >= 200 && statusCode < 300 {
                    
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: []),
                        let dict = json as? [String:AnyObject],
                      
                        let results = dict["photos"] as? [String : AnyObject]  {
                        if let photos = results["photo"] as? [[String:AnyObject]] {
                            for photo in photos {
                                let id = photo["id"]!
                                let secret = photo["secret"]!
                                let server = photo["server"]!
                                let farm = photo["farm"]!
                                let image_url:String = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
                                resultt.append(image_url)
                                print(image_url)
                                
                            }
                            
                        } else {  err = " Sorry there is a problem with the system The app can not be used right now"}
                        
                    }else {  err = "Sorry there is a problem with the system The app can not be used right now"}
                    
                } else {
                    err = " Sorry there is a problem with the system The app can not be used right now"
                }
            } else {
                err = "Please check the internet connection"
            }
            completion(resultt,err )
        }
        task.resume()
    }
    
    
  
}
