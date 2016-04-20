//
//  CoreData.m
//  Pods
//
//  Created by Moymer on 20/04/16.
//
//

#import "NSManagedObject+Serialization.h"

@implementation NSManagedObject (Serialization)

#define DATE_ATTR_PREFIX @"dAtEaTtr:"

#pragma mark -
#pragma mark Dictionary conversion methods

- (NSMutableDictionary*) toDictionaryWithTraversalHistory:(NSMutableArray*)traversalHistory andLoad: (NSMutableDictionary*) allGenerated  {
    NSArray* attributes = [[[self entity] attributesByName] allKeys];
    NSArray* relationships = [[[self entity] relationshipsByName] allKeys];
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:
                                 [attributes count] + [relationships count] + 1];
    
    NSMutableArray *localTraversalHistory = nil;
    if (traversalHistory == nil) {
        localTraversalHistory = [NSMutableArray arrayWithCapacity:[attributes count] + [relationships count] + 1];
    } else {
        localTraversalHistory = traversalHistory;
    }
    if (allGenerated == nil) {
        allGenerated = [[NSMutableDictionary alloc] init];
    }
    [localTraversalHistory addObject:self];
    
    NSString *description =[[self class] description];
    
    if(description){
        [dict setObject:description forKey:@"classe"];
    }
    
    for (NSString* attr in attributes) {
        NSObject* value = [self valueForKey:attr];
        
        @try {
            
            if (value != nil) {
                if ([value isKindOfClass:[NSDate class]]) {
                    NSTimeInterval date = [(NSDate*)value timeIntervalSinceReferenceDate];
                    NSString *dateAttr = [NSString stringWithFormat:@"%@%@", DATE_ATTR_PREFIX, attr];
                    NSNumber *dateN = [NSNumber numberWithDouble:date];
                    
                    if(dateN && dateAttr){
                        [dict setObject:dateN forKey:dateAttr];
                    }
                    
                } else {
                    
                    
                    if ([value isKindOfClass:[NSString class]]) {
                        
                        if ([attr isEqualToString:@"id"]) {
                            [dict setValue:(NSString*) value  forKey:@"id"];
                        }
                        else
                        {
                            [dict setValue:(NSString*) value  forKey:attr];
                        }
                    }
                    else
                    {
                        if(value && attr){
                            
                            [dict setObject:value forKey:attr];
                        }
                    }
                }
            }
            
        }
        @catch (NSException *e) {
            NSLog(@"Exception: %@", e);
        }
        @finally {
        }
    }
    for (NSString* relationship in relationships) {
        NSObject* value = [self valueForKey:relationship];
        if ([value isKindOfClass:[NSSet class]]) {
            // To-many relationship
            // The core data set holds a collection of managed objects
            NSSet* relatedObjects = (NSSet*) value;
            // Our set holds a collection of dictionaries
            NSMutableArray* dictSet = [NSMutableArray arrayWithCapacity:[relatedObjects count]];
            for (NSManagedObject* relatedObject in relatedObjects) {
                if ([localTraversalHistory containsObject:relatedObject] == NO) {
                    if(localTraversalHistory && allGenerated){
                        [dictSet addObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory andLoad:allGenerated]];
                    }
                }
                else
                {
                    NSDictionary *aux = [allGenerated valueForKey:relatedObject.description];
                    if(aux)
                    {
                        [dictSet addObject:aux];
                    }
                }
            }
            
            NSArray *dictSetArray = [NSArray arrayWithArray:dictSet];
            if(dictSetArray && relationship){
                [dict setObject:dictSetArray forKey:relationship];
            }
        }
        else if ([value isKindOfClass:[NSManagedObject class]]) {
            // To-one relationship
            NSManagedObject* relatedObject = (NSManagedObject*) value;
            if ([localTraversalHistory containsObject:relatedObject] == NO) {
                // Call toDictionary on the referenced object and put the result back into our dictionary.
                if(localTraversalHistory && allGenerated){
                    [dict setObject:[relatedObject toDictionaryWithTraversalHistory:localTraversalHistory andLoad:allGenerated] forKey:relationship];
                }
            }
            else
            {
                NSDictionary *aux = [allGenerated valueForKey:relatedObject.description];
                if(aux && relationship)
                {
                    [dict setObject:aux forKey:relationship];
                }
            }
            
        }
    }
    if (traversalHistory == nil) {
        [localTraversalHistory removeAllObjects];
    }
    if(dict && self.description){
        [allGenerated setObject:dict forKey:self.description];
    }
    return dict;
}

- (NSMutableDictionary*) toDictionary {
    return [self toDictionaryWithTraversalHistory:nil andLoad:nil];
}

+ (id) decodedValueFrom:(id)codedValue forKey:(NSString*)key {
    if ([key hasPrefix:DATE_ATTR_PREFIX] == YES) {
        // This is a date attribute
        NSTimeInterval dateAttr = [(NSNumber*)codedValue doubleValue];
        return [NSDate dateWithTimeIntervalSinceReferenceDate:dateAttr];
    } else {
        // This is an attribute
        return codedValue;
    }
}


- (void) populateFromDictionary:(NSMutableDictionary*)dict for: (NSPersistentStore *) persistentStore
{
    NSManagedObjectContext* context = [self managedObjectContext];
    for (NSString* key in dict) {
        if ([key isEqualToString:@"classe"]) {
            continue;
        }
        
        NSObject* value = [dict objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            // This is a to-one relationship
            NSManagedObject* relatedObject =
            [NSManagedObject createManagedObjectFromDictionary:(NSMutableDictionary*)value
                                                     inContext:context for: persistentStore eNivelUm:NO];
            //A PROPRIEDADE NAO EXISTE NO CORE DATA
            @try {
                [self setValue:relatedObject forKey:key];
            }
            
            @catch (NSException *e) {
                NSLog(@"Exception: %@", e);
            }
            @finally {
                // Added to show finally works as well
            }
            
        }
        else if ([value isKindOfClass:[NSArray class]]) {
            // This is a to-many relationship
            NSArray* relatedObjectDictionaries = (NSArray*) value;
            // Get a proxy set that represents the relationship, and add related objects to it.
            // (Note: this is provided by Core Data)
            NSMutableSet* relatedObjects = [self mutableSetValueForKey:key];
            for (NSMutableDictionary* relatedObjectDict in relatedObjectDictionaries) {
                NSManagedObject* relatedObject =
                [NSManagedObject createManagedObjectFromDictionary:relatedObjectDict
                                                         inContext:context for: persistentStore eNivelUm:NO];
                //A LISTA NAO EXISTE NO CORE DATA
                
                @try {
                    [relatedObjects addObject:relatedObject];
                }
                
                @catch (NSException *e) {
                    NSLog(@"Exception: %@", e);
                }
                @finally {
                    // Added to show finally works as well
                }
                
                
            }
        }
        else if (value != nil && ![value isKindOfClass:[NSNull class]]) {
            
            @try {
                if ([key isEqualToString:@"id"]) {
                    [self setValue:[NSManagedObject decodedValueFrom:value forKey:key] forKey:@"id"];
                    
                }
                else
                {
                    [self setValue:[NSManagedObject decodedValueFrom:value forKey:key] forKey:key];
                }
                
            }
            
            @catch (NSException *e) {
                NSLog(@"Exception: %@", e);
            }
            @finally {
                // Added to show finally works as well
            }
        }
    }
}

/**INICIA COM CONTROLE DE REPETICAO*/
+ (NSManagedObject*) createManagedObjectFromDictionary:(NSMutableDictionary*)dict
                                             inContext:(NSManagedObjectContext*)context for: (NSPersistentStore *) persistentStore
{
    
    return [NSManagedObject createManagedObjectFromDictionary:dict inContext:context for:persistentStore eNivelUm:YES];
}




/** COM CONTROLE DE REPETICAO*/
+ (NSManagedObject*)createManagedObjectFromDictionary:(NSMutableDictionary*)dictNotMutable
                                            inContext:(NSManagedObjectContext*)context
                                                  for:(NSPersistentStore *)persistentStore
                                             eNivelUm:(BOOL)nivelUm
{
    
    
    NSMutableDictionary *dict = [dictNotMutable mutableCopy];
    NSString* class = [dict objectForKey:@"classe"];
    NSString* idObject = [dict objectForKey:@"id"];
    
    
    if(idObject!=nil)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:class];
        request.affectedStores = [[NSArray alloc] initWithObjects:persistentStore, nil];
        request.predicate = [NSPredicate predicateWithFormat:@"id == %@",idObject];
        
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if(matches && [matches count]==1)
        {
            return [matches firstObject];
        }
        
        NSManagedObject* newObject =
        (NSManagedObject*)[NSEntityDescription insertNewObjectForEntityForName:class
                                                        inManagedObjectContext:context];
        
        [context assignObject:newObject toPersistentStore:persistentStore ];
        
        [newObject populateFromDictionary:dict for: persistentStore];
        return newObject;
    }
    
    return nil;
    
}


- (NSManagedObject*) copyManagedObjectInContext:(NSManagedObjectContext*)context to: (NSPersistentStore *) persistentStore

{
    
    NSDictionary * dict = [self toDictionary];
    
    
    return [NSManagedObject createManagedObjectFromDictionary:dict inContext:context for:persistentStore];
    
}

@end
