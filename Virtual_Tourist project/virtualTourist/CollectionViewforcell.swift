//
//  CollectionViewforcell.swift
//  virtualTourist
//
//  Created by عبدالله محمد on 2/5/19.
//  Copyright © 2019 udacity. All rights reserved.
//

import UIKit

class CollectionViewforcell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageViewcollection: UIImageView!
    
    @IBOutlet weak var activityIndecitor: UIActivityIndicatorView!
    
    
    func setupimage(url:String) {
        
        DispatchQueue.main.async {
            do{
                let appurl = URL(string: url)!
                let data=try Data(contentsOf: appurl )
                // access to ui
                DispatchQueue.main.async {
                 self.imageViewcollection.image = UIImage(data: data)

               }
            }
            catch{
                
           print("problem eith cell setupimage method ")
            }
        }
    }
    
    
}
