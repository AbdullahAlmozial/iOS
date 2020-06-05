//
//  dataController.swift
//  virtualTourist
//
//  Created by عبدالله محمد on 2/3/19.
//  Copyright © 2019 udacity. All rights reserved.
//

import Foundation
import  CoreData

class DataController {
    
    let persistentContainer:NSPersistentContainer
    
    
    
    var viewcontext : NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(complition: (() -> Void)? = nil )  {
        persistentContainer.loadPersistentStores { NSPersistentStoreDescription , error in guard error == nil else {
            fatalError(error!.localizedDescription)
            }
            complition?()
            
        }
    }
    
    
}
