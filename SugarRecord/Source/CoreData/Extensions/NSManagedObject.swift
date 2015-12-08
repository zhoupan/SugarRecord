import Foundation
import CoreData

// MARK: - Entity Protocol

extension NSManagedObject {
    
    public static var entityName: String {
        get {
            return NSStringFromClass(self).componentsSeparatedByString(".").last!
        }
    }
    
}


// MARK: - NSManagedobjecte Extension (Entity)

extension NSManagedObject: Entity {}