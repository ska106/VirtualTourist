//
//  CoreDataManager.swift
//  VirtualTourist
//
//  Created by Sudeep Agrawal on 12/26/16.
//  Copyright © 2016 Agrawal. All rights reserved.

import Foundation
import CoreData

typealias BatchTask=(_ workerContext: NSManagedObjectContext) -> ()

enum CoreDataManagerNotifications : String
{
    case ImportingTaskDidFinish = "ImportingTaskDidFinish"
}

struct CoreDataManager
{
    let model : NSManagedObjectModel
    let coordinator : NSPersistentStoreCoordinator
    let modelURL : NSURL
    let dbURL : NSURL
    let persistingContext : NSManagedObjectContext
    let backgroundContext : NSManagedObjectContext
    let context : NSManagedObjectContext
    
    static let sharedInstance = CoreDataManager(modelName: "VTModel")!
    
    
    init?(modelName: String)
    {
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else
        {
            print("Unable to find \(modelName)in the main bundle")
            return nil
        }
        
        self.modelURL = modelURL as NSURL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else
        {
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.name = "Persisting"
        persistingContext.persistentStoreCoordinator = coordinator
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        context.name = "Main"
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        backgroundContext.name = "Background"
       
        let fm = FileManager.default
        guard let  docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else
        {
            print("Unable to reach the documents folder")
            return nil
        }
        self.dbURL = docUrl.appendingPathComponent("VirtualTourist.sqlite") as NSURL
        do
        {
            try addStoreTo(coordinator: coordinator,
                           storeType: NSSQLiteStoreType,
                           configuration: nil,
                           storeURL: dbURL,
                           options: nil)
            
        }
        catch
        {
            print("unable to add store at \(dbURL)")
        }
    }
    
    func addStoreTo(coordinator coord : NSPersistentStoreCoordinator,
                    storeType: String,
                    configuration: String?,
                    storeURL: NSURL,
                    options : [NSObject : AnyObject]?) throws
    {
        try coord.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL as URL, options: nil)
        
    }
}


extension CoreDataManager
{
    func dropAllData() throws
    {
        try coordinator.destroyPersistentStore(at: dbURL as URL, ofType:NSSQLiteStoreType , options: nil)
        try addStoreTo(coordinator: self.coordinator, storeType: NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}

extension CoreDataManager
{
    func performBackgroundBatchOperation(batch: @escaping BatchTask)
    {
        backgroundContext.perform()
        {
            batch(self.backgroundContext)
            do
            {
                try self.backgroundContext.save()
            }
            catch
            {
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
}

extension CoreDataManager
{
    func performBackgroundImportingBatchOperation(batch: @escaping BatchTask)
    {
        // Create temp coordinator
        let tmpCoord = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        
        do
        {
            try addStoreTo(coordinator: tmpCoord, storeType: NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
        }catch{
            fatalError("Error adding a SQLite Store: \(error)")
        }
        
        // Create temp context
        let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        moc.name = "Importer"
        moc.persistentStoreCoordinator = tmpCoord
        
        // Run the batch task, save the contents of the moc & notify
        moc.perform()
        {
            batch(moc)
            
            do
            {
                try moc.save()
            }
            catch
            {
                fatalError("Error saving importer moc: \(moc)")
            }
            let nc = NotificationCenter.default
            let n = NSNotification(name: NSNotification.Name(rawValue: CoreDataManagerNotifications.ImportingTaskDidFinish.rawValue),
                                   object: nil)
            nc.post(n as Notification)
        }
    }
}

// MARK:  - Save
extension CoreDataManager
{
    func save()
    {
        context.performAndWait()
        {
            if self.context.hasChanges
            {
                do
                {
                    try self.context.save()
                }
                catch
                {
                    fatalError("Error while saving main context: \(error)")
                }
                
                // now we save in the background
                self.persistingContext.perform()
                {
                    do
                    {
                        try self.persistingContext.save()
                    }
                    catch
                    {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    func autoSave(delayInSeconds : Int)
    {
        if delayInSeconds > 0
        {
            save()
            let when = DispatchTime.now() + .seconds(delayInSeconds)
            DispatchQueue.main.asyncAfter(deadline: when)
            {
                self.autoSave(delayInSeconds: delayInSeconds)
            }
        }
    }
}
