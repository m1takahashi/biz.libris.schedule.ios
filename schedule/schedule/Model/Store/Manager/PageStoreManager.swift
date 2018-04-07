//
//  PageStoreManager.swift
//  http://qiita.com/watanave/items/4da9f4bc97247f780af8
//

import UIKit
import CoreData

class PageStoreManager {
    let appDelegate:AppDelegate!
    let context:NSManagedObjectContext!
    let entity: NSEntityDescription!
    let entityName:String = "PageStore"
    
    init() {
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        context     = appDelegate.managedObjectContext!
        entity      = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
    }
    
    func add(title:String, body:String, noteId:NSNumber) {
        let param = PageStore(entity: entity, insertIntoManagedObjectContext: context)
        param.title         = title
        param.body          = body
        param.note_id       = noteId
        param.submit_date   = NSDate()
        param.update_date   = NSDate()
        param.seq           = NSNumber(integer: 0)
        appDelegate.saveContext()
    }
    
    func delete(object:PageStore) {
        context.deleteObject(object)
        var error:NSError? = nil
        do {
            try context.save()
            print("ページを削除しました。")
        } catch let error1 as NSError {
            error = error1
            print("Error : %@", error!.localizedDescription)
            abort()
        }
    }
    
    func deleteByNoteId(noteId:NSNumber) {
        let results = self.getListByNoteId(noteId, order:NoteSortOrder.TitleASC.rawValue) as! [PageStore]
        
        for object in results {
            print("削除対象 : %@", object.title as String)
            context.deleteObject(object)
        }
        var error:NSError? = nil
        do {
            try context.save()
            print("ページを削除しました。")
        } catch let error1 as NSError {
            error = error1
            print("Error : %@", error!.localizedDescription)
            abort()
        }
    }
    
    func getListByNoteId(noteId:NSNumber, order:Int) -> NSArray {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        // Where
        fetchRequest.predicate = NSPredicate(format: "note_id = %@", noteId)
        
        // Order
        switch order {
        case NoteSortOrder.TitleASC.rawValue:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            break;
        case NoteSortOrder.SubmitDateDESC.rawValue:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "submit_date", ascending: false)]
            break;
        case NoteSortOrder.SubmitDateASC.rawValue:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "submit_date", ascending: true)]
            break;
        case NoteSortOrder.UpdateDateDESC.rawValue:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "update_date", ascending: false)]
            break;
        case NoteSortOrder.UpdateDateASC.rawValue:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "update_date", ascending: true)]
            break;
        default:
            break;
        }
        
        let results: NSArray! = try? context.executeFetchRequest(fetchRequest)
        return results
    }
}
