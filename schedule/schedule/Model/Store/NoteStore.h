//
//  NoteStore.h
//  

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NoteStore : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * seq;
@property (nonatomic, retain) NSNumber * note_id;
@property (nonatomic, retain) NSDate * submit_date;
@property (nonatomic, retain) NSDate * update_date;

@end
