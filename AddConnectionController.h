//
//  AddConnectionController.h
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ConnectionsArrayController;

@interface AddConnectionController : NSWindowController {
    IBOutlet NSTextField *hostTextField;
    IBOutlet NSTextField *hostportTextField;
    IBOutlet NSTextField *aliasTextField;
    IBOutlet NSTextField *adminuserTextField;
    IBOutlet NSSecureTextField *adminpassTextField;
    IBOutlet NSTextField *defaultdbTextField;
    IBOutlet NSButton *usesshCheckBox;
    IBOutlet NSTextField *bindaddressTextField;
    IBOutlet NSTextField *bindportTextField;
    IBOutlet NSTextField *sshhostTextField;
    IBOutlet NSTextField *sshportTextField;
    IBOutlet NSTextField *sshuserTextField;
    IBOutlet NSSecureTextField *sshpasswordTextField;
    IBOutlet ConnectionsArrayController *connectionsArrayController;
    NSDictionary *connectionInfo;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSTextField *hostTextField;
@property (nonatomic, retain) NSTextField *hostportTextField;
@property (nonatomic, retain) NSTextField *aliasTextField;
@property (nonatomic, retain) NSTextField *adminuserTextField;
@property (nonatomic, retain) NSSecureTextField *adminpassTextField;
@property (nonatomic, retain) NSTextField *defaultdbTextField;
@property (nonatomic, retain) NSButton *usesshCheckBox;
@property (nonatomic, retain) NSTextField *bindaddressTextField;
@property (nonatomic, retain) NSTextField *bindportTextField;
@property (nonatomic, retain) NSTextField *sshhostTextField;
@property (nonatomic, retain) NSTextField *sshportTextField;
@property (nonatomic, retain) NSTextField *sshuserTextField;
@property (nonatomic, retain) NSSecureTextField *sshpasswordTextField;
@property (nonatomic, retain) NSDictionary *connectionInfo;
@property (nonatomic, retain) ConnectionsArrayController *connectionsArrayController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (IBAction)cancel:(id)sender;
- (IBAction)add:(id)sender;
- (IBAction)enableSSH:(id)sender;
- (BOOL)validateConnection;

@end
