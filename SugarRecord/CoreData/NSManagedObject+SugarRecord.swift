//
//  NSManagedObject+SugarRecord.swift
//  SugarRecord
//
//  Created by Pedro Piñera Buendia on 07/09/14.
//  Copyright (c) 2014 SugarRecord. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject: SugarRecordObjectProtocol
{
    //MARK: - Custom Getter
    
    /**
    Returns the context where this object is alive
    
    :returns: SugarRecord context 
    */
    public func context() -> SugarRecordContext
    {
        return SugarRecordCDContext(context: self.managedObjectContext)
    }
    
    /**
    Returns the class entity name
    
    :returns: String with the entity name
    */
    public class func entityName() -> String
    {
        return NSStringFromClass(self).componentsSeparatedByString(".").last!
    }
    
    /**
    Returns the stack type compatible with this object
    
    :returns: SugarRecordStackType with the type
    */
    public class func stackType() -> SugarRecordStackType
    {
        return SugarRecordStackType.SugarRecordStackTypeCoreData
    }
    
    //MARK: - Filtering
    
    /**
    Returns a SugarRecord  finder with the predicate set
    
    :param: predicate NSPredicate to be set to the finder
    
    :returns: SugarRecord finder with the predicate set
    */
    public class func by(predicate: NSPredicate) -> SugarRecordFinder
    {
        var finder: SugarRecordFinder = SugarRecordFinder(predicate: predicate)
        finder.objectClass = self
        finder.stackType = stackType()
        return finder
    }
    
    /**
    Returns a SugarRecord finder with the predicate set
    
    :param: predicateString Predicate in String format
    
    :returns: SugarRecord finder with the predicate set
    */
    public class func by(predicateString: NSString) -> SugarRecordFinder
    {
        var finder: SugarRecordFinder = SugarRecordFinder()
        finder.setPredicate(predicateString)
        finder.objectClass = self
        finder.stackType = stackType()
        return finder
    }
    
    /**
    Returns a SugarRecord finder with the predicate set
    
    :param: key   Key of the predicate to be filtered
    :param: value Value of the predicate to be filtered
    
    :returns: SugarRecord finder with the predicate set
    */
    public class func by(key: String, equalTo value: String) -> SugarRecordFinder
    {
        var finder: SugarRecordFinder = SugarRecordFinder()
        finder.setPredicate(byKey: key, andValue: value)
        finder.objectClass = self
        finder.stackType = stackType()
        return finder
    }
    
    
    //MARK: - Sorting
    
    /**
    Returns a SugarRecord finder with the sort descriptor set
    
    :param: sortingKey Sorting key
    :param: ascending  Sorting ascending value
    
    :returns: SugarRecord finder with the predicate set
    */
    public class func sorted(by sortingKey: String, ascending: Bool) -> SugarRecordFinder
    {
        var finder: SugarRecordFinder = SugarRecordFinder()
        finder.addSortDescriptor(byKey: sortingKey, ascending: ascending)
        finder.objectClass = self
        finder.stackType = stackType()
        return finder
    }
    
    /**
    Returns a SugarRecord finder with the sort descriptor set
    
    :param: sortDescriptor NSSortDescriptor to be set to the SugarRecord finder
    
    :returns: SugarRecord finder with the predicate set
    */
    public class func sorted(by sortDescriptor: NSSortDescriptor) -> SugarRecordFinder
    {
        var finder: SugarRecordFinder = SugarRecordFinder()
        finder.addSortDescriptor(sortDescriptor)
        finder.objectClass = self
        finder.stackType = stackType()
        return finder
    }
    
    /**
    Returns a SugarRecord finder with the sort descriptor set
    
    :param: sortDescriptors Array with NSSortDescriptors
    
    :returns: SugarRecord finder with the predicate set
    */
    public class func sorted(by sortDescriptors: [NSSortDescriptor]) -> SugarRecordFinder
    {
        var finder: SugarRecordFinder = SugarRecordFinder()
        finder.setSortDescriptors(sortDescriptors)
        finder.objectClass = self
        finder.stackType = stackType()
        return finder
    }
    
    
    //MARK: - All
    
    /**
    Returns a SugarRecord finder with .all elements enabled
    
    :returns: SugarRecord finder
    */
    public class func all() -> SugarRecordFinder
    {
        var finder: SugarRecordFinder = SugarRecordFinder()
        finder.all()
        finder.objectClass = self
        finder.stackType = stackType()
        return finder
    }
    
    //MARK: - Deletion
    
    /**
    Deletes the object from the store
    
    :returns: Bool indicating if the object has been deleted properly
    */
    public func delete() -> Bool
    {
        var deleted: Bool = false
        SugarRecord.operation(NSManagedObject.stackType(), closure: { (context) -> () in
            context.beginWritting()
            deleted = context.deleteObject(self)
            context.endWritting()
        })
        return deleted
    }
    
    /**
    Deletes the object from the store without saving the context
    
    :param: context Context where the object is going to be deleted
    
    :returns: Bool indicating if the object has been deleted
    */
    public func delete(inContext context: SugarRecordContext) -> Bool
    {
        return context.deleteObject(self)
    }
    
    
    //MARK: - Creation
    
    /**
    Creates a new object without inserting it in the context
    
    :returns: Created database object
    */
    public class func create() -> AnyObject
    {
        var object: AnyObject?
        SugarRecord.operation(NSManagedObject.stackType(), closure: { (context) -> () in
            object = context.createObject(self)
        })
        return object!
    }
    
    /**
    Create a new object without inserting it in the passed context
    
    :param: context Context where the object is going to be created
    
    :returns: Created database object
    */
    public class func create(inContext context: SugarRecordContext) -> AnyObject
    {
        return context.createObject(self)!
    }
    
    //MARK: - Saving
    
    /**
    Saves the object in the object context
    
    :returns: Bool indicating if the object has been properly saved
    */
    public func save () -> Bool
    {
        var saved: Bool = false
        self.save(false, completion: { (error) -> () in
            saved = error == nil
        })
        return saved
    }
    
    /**
    Saves the object in the object context asynchronously (or not) passing a completion closure
    
    :param: asynchronously Bool indicating if the saving process is asynchronous or not
    :param: completion     Closure called when the saving operation has been completed
    */
    public func save (asynchronously: Bool, completion: (error: NSError?) -> ())
    {
        let context: SugarRecordContext = self.context()
        if asynchronously {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
                context.endWritting()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion(error: nil)
                })
            })
        }
        else {
            context.endWritting()
            completion(error: nil)
        }
    }
    
    
    //MARK: - BeginEditing
    
    /**
    Needed to be called when the object is going to be edited
    */
    public func beginEditing()
    {
        self.context().beginWritting()
    }
    
    /**
    Needed to be called when the edition has finished
    */
    public func endEditing()
    {
        self.context().endWritting()
    }
}