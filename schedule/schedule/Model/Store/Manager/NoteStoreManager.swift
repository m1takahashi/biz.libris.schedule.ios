//
//  NoteStoreManager.swift
//  http://hidef.jp/post-652/
//

import UIKit
import CoreData

class NoteStoreManager {
    let appDelegate:AppDelegate!
    let context:NSManagedObjectContext!
    let entity: NSEntityDescription!
    let entityName:String = "NoteStore"
    
    init() {
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        context     = appDelegate.managedObjectContext!
        entity      = NSEntityDescription.entityForName(entityName, inManagedObjectContext: context)
    }
    
    func add(title:String) {
        let nextId:NSInteger = self.getNextId()
        print("NextID  : \(nextId)")
        
        let param = NoteStore(entity: entity, insertIntoManagedObjectContext: context)
        param.title         = title
        param.note_id       = NSNumber(integer: nextId)
        param.submit_date   = NSDate()
        param.update_date   = NSDate()
        param.seq           = NSNumber(integer: 0) // 固定
        appDelegate.saveContext()
    }
    
    func delete(object:NoteStore) {
        context.deleteObject(object)
        var error:NSError? = nil
        do {
            try context.save()
            print("ノートを削除しました。")
        } catch let error1 as NSError {
            error = error1
            print("Error : %@", error!.localizedDescription)
            abort()
        }
    }
    
    func getByNoteId(noteId:NSNumber) -> NoteStore! {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.predicate = NSPredicate(format: "note_id = %@", noteId)
        if let results: NSArray! = try? context.executeFetchRequest(fetchRequest) {
            if results.count > 0 {
                return results[0] as! NoteStore
            }
        }
        return nil
    }
    
    func getList(ascending:Bool) -> NSArray {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        // 並び順（Seqの降順）
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "seq", ascending: ascending)]
        
        let results: NSArray! = try? context.executeFetchRequest(fetchRequest)
        return results
    }

    // 並び順振り直し
    func resetSeq() {
        let list = self.getList(true) as! [NoteStore]
        for (index, note) in list.enumerate() {
            print("Index : \(index)")
            note.seq = index + 1
            do {
                try note.managedObjectContext!.save()
            } catch _ {
            };
        }
    }
    
    // 次のIDを取得
    private func getNextId() -> NSInteger {
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        
        let keyPathExpression = NSExpression(forKeyPath: "note_id")
        let maxExpression = NSExpression(forFunction: "max:", arguments: [keyPathExpression])
        let description = NSExpressionDescription()
        description.name = "maxId"
        description.expression = maxExpression
        description.expressionResultType = .Integer32AttributeType
        
        fetchRequest.propertiesToFetch = [description]
        fetchRequest.resultType = .DictionaryResultType
        
        if let results = try? context.executeFetchRequest(fetchRequest) {
            if results.count > 0 {
                let maxId = results[0]["maxId"] as! Int
                return maxId + 1;
            }
        }
        return 1
    }
}
