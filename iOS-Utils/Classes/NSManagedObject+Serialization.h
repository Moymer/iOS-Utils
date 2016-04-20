//
//  CoreData.h
//  Pods
//
//  Created by Moymer on 20/04/16.
//
//
#import <CoreData/CoreData.h>

@interface NSManagedObject (Serialization)


- (NSDictionary*) toDictionary;


+ (NSManagedObject*) createManagedObjectFromDictionary:(NSDictionary*)dict
                                             inContext:(NSManagedObjectContext*)context for: (NSPersistentStore *) persistentStore;

- (NSManagedObject*) copyManagedObjectInContext:(NSManagedObjectContext*)context to: (NSPersistentStore *) persistentStore;
@end
