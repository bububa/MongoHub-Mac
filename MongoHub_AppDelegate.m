//
//  MongoHub_AppDelegate.m
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright MusicPeace.ORG 2010 . All rights reserved.
//

#import "Configure.h"
#import "MongoHub_AppDelegate.h"
#import "AddConnectionController.h"
#import "EditConnectionController.h"
#import "ConnectionsArrayController.h"
#import "ConnectionsCollectionView.h"
#import "ConnectionWindowController.h"
#import "Connection.h"

#define YOUR_EXTERNAL_RECORD_EXTENSION @"mgo"
#define YOUR_STORE_TYPE NSXMLStoreType

@implementation MongoHub_AppDelegate

@synthesize window;
@synthesize connectionsCollectionView;
@synthesize connectionsArrayController;
@synthesize addConnectionController;
@synthesize editConnectionController;
@synthesize bundleVersion;

/**
    Returns the support directory for the application, used to store the Core Data
    store file.  This code uses a directory named "MongoHub" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"MongoHub"];
}

/**
    Returns the external records directory for the application.
	This code uses a directory named "MongoHub" for the content, 
	either in the ~/Library/Caches/Metadata/CoreData location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)externalRecordsDirectory {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Metadata/CoreData/MongoHub"];
}

/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel) return managedObjectModel;
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The directory for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator) return persistentStoreCoordinator;

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSAssert(NO, @"Managed object model is nil");
        NSLog(@"%@:%s No model to generate a store from", [self class], _cmd);
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *applicationSupportDirectory = [self applicationSupportDirectory];
    NSError *error = nil;
    
    if ( ![fileManager fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
		if (![fileManager createDirectoryAtPath:applicationSupportDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
            NSLog(@"Error creating application support directory at %@ : %@",applicationSupportDirectory,error);
            return nil;
		}
    }

    NSString *externalRecordsDirectory = [self externalRecordsDirectory];
    if ( ![fileManager fileExistsAtPath:externalRecordsDirectory isDirectory:NULL] ) {
        if (![fileManager createDirectoryAtPath:externalRecordsDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Error creating external records directory at %@ : %@",externalRecordsDirectory,error);
            NSAssert(NO, ([NSString stringWithFormat:@"Failed to create external records directory %@ : %@", externalRecordsDirectory,error]));
            NSLog(@"Error creating external records directory at %@ : %@",externalRecordsDirectory,error);
            return nil;
        };
    }

    NSURL *url = [NSURL fileURLWithPath: [applicationSupportDirectory stringByAppendingPathComponent: @"storedata"]];
    // set store options to enable spotlight indexing
    NSMutableDictionary *storeOptions = [NSMutableDictionary dictionary];
    [storeOptions setObject:YOUR_EXTERNAL_RECORD_EXTENSION forKey:NSExternalRecordExtensionOption];
    [storeOptions setObject:externalRecordsDirectory forKey:NSExternalRecordsDirectoryOption];
    [storeOptions setObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
    [storeOptions setObject:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: mom];
    if (![persistentStoreCoordinator addPersistentStoreWithType:YOUR_STORE_TYPE 
                                                configuration:nil 
                                                URL:url 
                                                options:storeOptions 
                                                error:&error]){
        [[NSApplication sharedApplication] presentError:error];
        [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
        return nil;
    }    

    return persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext) return managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator: coordinator];

    return managedObjectContext;
}

/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    if (!managedObjectContext) return NSTerminateNow;

    if (![managedObjectContext commitEditing]) {
        NSLog(@"%@:%s unable to commit editing to terminate", [self class], _cmd);
        return NSTerminateCancel;
    }

    if (![managedObjectContext hasChanges]) return NSTerminateNow;

    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
    
        // This error handling simply presents error information in a panel with an 
        // "Ok" button, which does not include any attempt at error recovery (meaning, 
        // attempting to fix the error.)  As a result, this implementation will 
        // present the information to the user and then follow up with a panel asking 
        // if the user wishes to "Quit Anyway", without saving the changes.

        // Typically, this process should be altered to include application-specific 
        // recovery steps.  
                
        BOOL result = [sender presentError:error];
        if (result) return NSTerminateCancel;

        NSString *question = NSLocalizedString(@"Could not save changes while quitting.  Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) return NSTerminateCancel;

    }

    return NSTerminateNow;
}

/**
    Implementation of application:openFiles:, to respond to an open file request from an external record file
 */
- (void)application:(NSApplication *)theApplication openFiles:(NSArray *)files {
    
    NSString *aPath = [files lastObject]; // just an example to get at one of the paths

    if (aPath && [aPath hasSuffix:YOUR_EXTERNAL_RECORD_EXTENSION]) {
        // decode URI from path
        NSURL *objectURI = [[NSPersistentStoreCoordinator elementsDerivedFromExternalRecordURL:[NSURL fileURLWithPath:aPath]] objectForKey:NSObjectURIKey];
        if (objectURI) {
            NSManagedObjectID *moid = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];
            if (moid) {
                    NSManagedObject *mo = [[self managedObjectContext] objectWithID:moid];
                    NSLog(@"The record for path %@ is %@",moid,mo);
                    
                    // your code to select the object in your application's UI
            }
            
        }
    }
    
}

/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void)dealloc {

    [window release];
    [managedObjectContext release];
    [persistentStoreCoordinator release];
    [managedObjectModel release];
    
    [connectionsCollectionView release];
    [connectionsArrayController release];
	[addConnectionController release];
    [editConnectionController release];
    
    [bundleVersion release];
    
    [super dealloc];
}


- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addConection:) name:kNewConnectionWindowWillClose object:nil];
    NSString *appVersion = [[NSString alloc] initWithFormat:@"version(%@[%@])", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey] ];
    [bundleVersion setStringValue: appVersion];
    [appVersion release];
}

#pragma mark connections related method
- (IBAction)showAddConnectionPanel:(id)sender {
    if (!addConnectionController) {
        addConnectionController = [[AddConnectionController alloc] init];
    }
    addConnectionController.managedObjectContext = self.managedObjectContext;
    [addConnectionController showWindow:self];
}

- (IBAction)addConection:(id)sender {
    if (![sender object]) {
        return;
    }
    Connection *newObj = [[connectionsArrayController newObject] autorelease];
    [newObj setValue:[[sender object] objectForKey:@"host"] forKey:@"host"];
    [newObj setValue:[[sender object] objectForKey:@"hostport"] forKey:@"hostport"];
    [newObj setValue:[[sender object] objectForKey:@"alias"] forKey:@"alias"];
    [newObj setValue:[[sender object] objectForKey:@"adminuser"] forKey:@"adminuser"];
    [newObj setValue:[[sender object] objectForKey:@"adminpass"] forKey:@"adminpass"];
    [newObj setValue:[[sender object] objectForKey:@"defaultdb"] forKey:@"defaultdb"];
    [newObj setValue:[[sender object] objectForKey:@"usessh"] forKey:@"usessh"];
    [newObj setValue:[[sender object] objectForKey:@"bindaddress"] forKey:@"bindaddress"];
    [newObj setValue:[[sender object] objectForKey:@"bindport"] forKey:@"bindport"];
    [newObj setValue:[[sender object] objectForKey:@"sshhost"] forKey:@"sshhost"];
    [newObj setValue:[[sender object] objectForKey:@"sshport"] forKey:@"sshport"];
    [newObj setValue:[[sender object] objectForKey:@"sshkeyfile"] forKey:@"sshkeyfile"];
    [newObj setValue:[[sender object] objectForKey:@"sshuser"] forKey:@"sshuser"];
    [newObj setValue:[[sender object] objectForKey:@"sshpassword"] forKey:@"sshpassword"];
    [connectionsArrayController addObject:newObj];
    [self saveAction:sender];
}

- (IBAction)deleteConnection:(id)sender {
    [connectionsArrayController remove:sender];
    [self saveAction:sender];
}

- (IBAction)showEditConnectionPanel:(id)sender {
    if (![connectionsArrayController selectedObjects]) {
        return;
    }
    Connection *connection = [[connectionsArrayController selectedObjects] objectAtIndex:0];
    if (!editConnectionController) {
        editConnectionController = [[EditConnectionController alloc] init];
    }
    editConnectionController.connection = connection;
    editConnectionController.managedObjectContext = self.managedObjectContext;
    [editConnectionController showWindow:self];
}

- (IBAction)editConnection:(id)sender {
    if (![sender object]) {
        return;
    }
    [self saveAction:sender];
}

- (IBAction)resizeConnectionItemView:(id)sender {
    CGFloat theSize = [sender floatValue]/100.0f*360.0f;
    [connectionsCollectionView setSubviewSize:theSize];
}

- (IBAction)showConnectionWindow:(id)sender {
    if (![connectionsArrayController selectedObjects]) {
        return;
    }
    [self doubleClick:[[connectionsArrayController selectedObjects] objectAtIndex:0]];
}

- (void)doubleClick:(id)sender {
    if (![sender isKindOfClass:[Connection class]]) {
        sender = [[connectionsArrayController selectedObjects] objectAtIndex:0];
    }
    if ([self isOpenedConnection:sender]) {
        return;
    }
    ConnectionWindowController *connectionWindowController = [[ConnectionWindowController alloc] init];
    connectionWindowController.managedObjectContext = self.managedObjectContext;
    connectionWindowController.conn = sender;
    [connectionWindowController showWindow:sender];
}

- (BOOL)isOpenedConnection:(Connection *)aConnection {
    NSWindow *aWindow;
    for (aWindow in [[NSApplication sharedApplication] windows])
    {
        id aDelegate = [aWindow delegate];
        if ([aDelegate isKindOfClass:[ConnectionWindowController class]] && [aDelegate conn] == aConnection) {
            [aWindow makeKeyAndOrderFront:nil];
            return YES;
        }
    }
    return NO;
}

@end
