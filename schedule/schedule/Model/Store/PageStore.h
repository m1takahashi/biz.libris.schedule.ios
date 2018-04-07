//
//  PageStore.h
//  

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PageStore : NSManagedObject

@property (nonatomic, retain) NSNumber * page_id;
@property (nonatomic, retain) NSNumber * note_id;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * seq;
@property (nonatomic, retain) NSDate * submit_date;
@property (nonatomic, retain) NSDate * update_date;

@end
