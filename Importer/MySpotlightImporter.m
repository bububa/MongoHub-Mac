//
//  MySpotlightImporter.m
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright MusicPeace.ORG 2010 . All rights reserved.
//

#import "MySpotlightImporter.h"

#define YOUR_STORE_TYPE NSXMLStoreType

@interface MySpotlightImporter ()
@property (nonatomic, retain) NSURL *modelURL;
@property (nonatomic, retain) NSURL *storeURL;
@end

@implementation MySpotlightImporter

@synthesize modelURL, storeURL;

- (BOOL)importFileAtPath:(NSString *)filePath attributes:(NSMutableDictionary *)spotlightData error:(NSError **)error {
        
    NSDictionary *pathInfo = [NSPersistentStoreCoordinator elementsDerivedFromExternalRecordURL:[NSURL fileURLWithPath:filePath]];
            
    self.modelURL = [NSURL fileURLWithPath:[pathInfo valueForKey:NSModelPathKey]];
    self.storeURL = [NSURL fileURLWithPath:[pathInfo valueForKey:NSStorePathKey]];


    NSURL  *objectURI = [pathInfo valueForKey:NSObjectURIKey];
    NSManagedObjectID *oid = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];

    if (!oid) {
        NSLog(@"%@:%s to find object id from path %@", [self class], _cmd, filePath);
        return NO;
    }

    NSManagedObject *instance = [[self managedObjectContext] objectWithID:oid];

    // how you process each instance will depend on the entity that the instance belongs to

    if ([[[instance entity] name] isEqualToString:@"YOUR_ENTITY_NAME"]) {

        // set the display name for Spotlight search result

        NSString *yourDisplayString =  [NSString stringWithFormat:@"YOUR_DISPLAY_STRING %@",[instance valueForKey:@"SOME_KEY"]]; 
        [spotlightData setObject: yourDisplayString forKey:(NSString *)kMDItemDisplayName];
        
         /*
            Determine how you want to store the instance information in 'spotlightData' dictionary.
            For each property, pick the key kMDItem... from MDItem.h that best fits its content.  
            If appropriate, aggregate the values of multiple properties before setting them in the dictionary.
            For relationships, you may want to flatten values. 

            id YOUR_FIELD_VALUE = [instance valueForKey: ATTRIBUTE_NAME];
            [spotlightData setObject: YOUR_FIELD_VALUE forKey: (NSString *) kMDItem...];
            ... more property values; 
            To determine if a property should be indexed, call isIndexedBySpotlight

         */

    }

    return YES;
}

- (void)dealloc {

    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
    [modelURL release];
    [storeURL release];
    
    [super dealloc];
}

/**
	Returns the managed object model. 
	The last read model is cached in a global variable and reused
	if the URL and modification date are identical
 */
static NSURL				*cachedModelURL = nil;
static NSManagedObjectModel *cachedModel = nil;
static NSDate				*cachedModelModificationDate =nil;

- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) return managedObjectModel;
	
	NSDictionary *modelFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[modelURL path] error:nil];
	NSDate *modelModificationDate =  [modelFileAttributes objectForKey:NSFileModificationDate];
	
	if ([cachedModelURL isEqual:modelURL] && [modelModificationDate isEqualToDate:cachedModelModificationDate]) {
		managedObjectModel = [cachedModel retain];
	} 	
	
	if (!managedObjectModel) {
		managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

		if (!managedObjectModel) {
			NSLog(@"%@:%s unable to load model at URL %@", [self class], _cmd, modelURL);
			return nil;
		}

		// Clear out all custom classes used by the model to avoid having to link them
		// with the importer. Remove this code if you need to access your custom logic.
		NSString *managedObjectClassName = [NSManagedObject className];
		for (NSEntityDescription *entity in managedObjectModel) {
			[entity setManagedObjectClassName:managedObjectClassName];
		}
		
		// cache last loaded model

		[cachedModelURL release];
		cachedModelURL = [modelURL retain];
		[cachedModel release];
		cachedModel = [managedObjectModel retain];
		[cachedModelModificationDate release];
		cachedModelModificationDate = [modelModificationDate retain];
	}
	
	return managedObjectModel;
}

/**
    Returns the persistent store coordinator for the importer.  
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSError *error = nil;
        
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:YOUR_STORE_TYPE 
										configuration:nil 
										URL:storeURL 
										options:nil 
										error:&error]){
        NSLog(@"%@:%s unable to add persistent store coordinator - %@", [self class], _cmd, error);
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the importer; already
    bound to the persistent store coordinator. 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (!coordinator) {
        NSLog(@"%@:%s unable to get persistent store coordinator", [self class], _cmd);
		return nil;
	}

	managedObjectContext = [[NSManagedObjectContext alloc] init];
	[managedObjectContext setPersistentStoreCoordinator: coordinator];
    
    return managedObjectContext;
}

@end
