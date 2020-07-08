//
//  serverclass.swift
//  serverRequestResponse
//
//  Created by Royal on 24/2/18.
//  Copyright © 2018 King. All rights reserved.
//
//^ must be the beginning of the string
//[A-Za-z]{4} = four characters A-Z or a-z
//0one zero
//.{6} six arbitrary characters
//$ must be the end of the string

import Foundation
import UIKit
import SystemConfiguration
import CoreData





class CoredataClass {

    static let sharedInstance = CoredataClass()
    
    func storevalues(imgid: String) -> Void{
        //        DispatchQueue.main.async {
        let context = self.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Purchaseimgid", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        
        newUser.setValue(self.nullToNil(value: imgid as AnyObject), forKey: "imgid")
       
         do {
                try context.save()
                       
        } catch {
                        
            print("Failed saving")
        }
    }
    
    func GetData_of_Purchase_Image_List_entity() -> [NSManagedObject] {
        
        let context = self.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Purchaseimgid")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        var result: [NSManagedObject] = []
        do {
            result = try context.fetch(request) as! [NSManagedObject]
            //            for data in result as! [NSManagedObject] {
            //                print(data.value(forKey: "useremail") as! String)
            //            }
            
        } catch {
            
            print("Failed")
        }
        
        return result
    }
    
    
    func deleteFromMaster(entityname: String) -> Void{
        //        DispatchQueue.main.async {
        let context = self.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityname)
        
        
        do {
            let results = try context.fetch(request) as! [NSManagedObject]
            
            for address in results {
                context.delete(address)
            }
            
            try context.save()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func someEntityExists(entityname: String) -> Bool {
        
        let context = self.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityname)
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        //        if request.predicate != nil {
        var results: [NSManagedObject] = []
        
        do {
            results = try context.fetch(request) as! [NSManagedObject]
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        
        return results.count > 0
        
    }

    
    
    
    func nullToNil(value : AnyObject?) -> AnyObject? {
        if value is NSNull {
            return "nil" as AnyObject
        } else {
            return value
        }
    }
    
    
   // MARK: - Core Data stack

   lazy var persistentContainer: NSPersistentContainer = {
       /*
        The persistent container for the application. This implementation
        creates and returns a container, having loaded the store for the
        application to it. This property is optional since there are legitimate
        error conditions that could cause the creation of the store to fail.
       */
       let container = NSPersistentContainer(name: "wallywall")
       container.loadPersistentStores(completionHandler: { (storeDescription, error) in
           if let error = error as NSError? {
               // Replace this implementation with code to handle the error appropriately.
               // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
               /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
               fatalError("Unresolved error \(error), \(error.userInfo)")
           }
       })
       return container
   }()

   // MARK: - Core Data Saving support

   func saveContext () {
       let context = persistentContainer.viewContext
       if context.hasChanges {
           do {
               try context.save()
           } catch {
               // Replace this implementation with code to handle the error appropriately.
               // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
               let nserror = error as NSError
               fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
           }
       }
   }
}


