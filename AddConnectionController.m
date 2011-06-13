//
//  AddConnectionController.m
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "Configure.h"
#import "AddConnectionController.h"
#import "ConnectionsArrayController.h"

@implementation AddConnectionController

@synthesize hostTextField;
@synthesize hostportTextField;
@synthesize usereplCheckBox;
@synthesize serversTextField;
@synthesize replnameTextField;
@synthesize aliasTextField;
@synthesize adminuserTextField;
@synthesize adminpassTextField;
@synthesize defaultdbTextField;
@synthesize usesshCheckBox;
@synthesize bindaddressTextField;
@synthesize bindportTextField;
@synthesize sshhostTextField;
@synthesize sshportTextField;
@synthesize sshuserTextField;
@synthesize sshpasswordTextField;
@synthesize sshkeyfileTextField;
@synthesize connectionInfo;
@synthesize connectionsArrayController;
@synthesize managedObjectContext;

- (id)init {
    if (![super initWithWindowNibName:@"NewConnection"]) return nil;
    return self;
}

- (void)dealloc {
    [hostTextField release];
    [hostportTextField release];
    [usereplCheckBox release];
    [serversTextField release];
    [replnameTextField release];
    [aliasTextField release];
    [adminuserTextField release];
    [adminpassTextField release];
    [defaultdbTextField release];
    [usesshCheckBox release];
    [bindaddressTextField release];
    [bindportTextField release];
    [sshhostTextField release];
    [sshportTextField release];
    [sshuserTextField release];
    [sshpasswordTextField release];
    [sshkeyfileTextField release];
    [connectionInfo release];
    [connectionsArrayController release];
    [managedObjectContext release];
    [super dealloc];
}

- (void)windowDidLoad {
    //NSLog(@"New Connection Window Loaded");
    [super windowDidLoad];
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewConnectionWindowWillClose object:connectionInfo];
}

- (IBAction)cancel:(id)sender {
    connectionInfo = nil;
    [self close];
}

- (IBAction)add:(id)sender {
    NSString *host;
    NSUInteger hostport;
    NSString *servers;
    NSString *repl_name;
    NSUInteger userepl = 0;
    NSString *alias;
    NSString *adminuser = [adminuserTextField stringValue];
    NSString *adminpass = [adminpassTextField stringValue];
    NSString *defaultdb = [defaultdbTextField stringValue];
    NSUInteger usessh = 0;
    NSString *bindaddress;
    NSUInteger bindport;
    NSString *sshhost;
    NSUInteger sshport;
    NSString *sshuser;
    NSString *sshpassword;
    NSString *sshkeyfile;
    if ([ [hostTextField stringValue] length] == 0) {
        host = [[NSString alloc] initWithString:@"localhost"];
    }else{
        host = [[NSString alloc] initWithString:[hostTextField stringValue]];
    }
    if ([hostportTextField intValue] == 0) {
        hostport = 27017;
    }else{
        hostport = [hostportTextField intValue];
    }
    
    servers = [[NSString alloc] initWithString:[serversTextField stringValue]];
    repl_name = [[NSString alloc] initWithString:[replnameTextField stringValue]];
    if ([usereplCheckBox state])
    {
        userepl = 1;
    }
    
    if ([ [aliasTextField stringValue] length] == 0) {
        alias = [[NSString alloc] initWithString:@"localhost"];
    }else{
        alias = [[NSString alloc] initWithString:[aliasTextField stringValue]];
    }
    if ([ [bindaddressTextField stringValue] length] == 0) {
        bindaddress = [[NSString alloc] initWithString:@"127.0.0.1"];
    }else{
        bindaddress = [[NSString alloc] initWithString:[bindaddressTextField stringValue]];
    }
    if ([ [bindportTextField stringValue] length] == 0) {
        bindport = 8888;
    }else{
        bindport = [bindportTextField intValue];
    }
    sshhost = [[NSString alloc] initWithString:[sshhostTextField stringValue]];
    if ([[sshportTextField stringValue] length] == 0) {
        sshport = 22;
    }else {
        sshport = [sshportTextField intValue];
    }
    
    sshuser = [[NSString alloc] initWithString:[sshuserTextField stringValue]];
    sshpassword = [[NSString alloc] initWithString:[sshpasswordTextField stringValue]];
    sshkeyfile = [[NSString alloc] initWithString:[sshkeyfileTextField stringValue]];
    if ([usesshCheckBox state])
    {
        usessh = 1;
        
    }
    NSArray *keys = [[NSArray alloc] initWithObjects:@"host", @"hostport", @"userepl", @"servers", @"repl_name", @"alias", @"adminuser", @"adminpass", @"defaultdb", @"usessh", @"bindaddress", @"bindport", @"sshhost", @"sshport", @"sshuser", @"sshpassword", @"sshkeyfile", nil];
    NSArray *objs = [[NSArray alloc] initWithObjects:host, [NSNumber numberWithInt:hostport], [NSNumber numberWithInt:userepl], servers, repl_name, alias, adminuser, adminpass, defaultdb, [NSNumber numberWithInt:usessh], bindaddress, [NSNumber numberWithInt:bindport], sshhost, [NSNumber numberWithInt:sshport], sshuser, sshpassword, sshkeyfile, nil];
    if (!connectionInfo) {
        connectionInfo = [[NSMutableDictionary alloc] initWithCapacity:13]; 
    }
    connectionInfo = [NSMutableDictionary dictionaryWithObjects:objs forKeys:keys];
    [keys release];
    [objs release];
    [host release];
    [alias release];
    [servers release];
    [repl_name release];
    [sshhost release];
    [sshuser release];
    [sshpassword release];
    [sshkeyfile release];
    [bindaddress release];
    if ([self validateConnection]) {
        [self close];
    }
}

- (BOOL)validateConnection
{
    if ([[connectionInfo objectForKey:@"host"] length] == 0) {
        NSRunAlertPanel(@"Error", @"Connection host should not be empty", @"OK", nil, nil);
        return NO;
    }
    if ([[connectionInfo objectForKey:@"host"] isEqualToString:@"flame.mongohq.com"] && [[connectionInfo objectForKey:@"defaultdb"] length] == 0) {
        NSRunAlertPanel(@"Error", @"DB should not be empty if you are using mongohq", @"OK", nil, nil);
        return NO;
    }
    if ([[connectionInfo objectForKey:@"alias"] length]<3) {
        NSRunAlertPanel(@"Error", @"Connection name should not be less than 3 charaters", @"OK", nil, nil);
        return NO;
    }
    if ([connectionsArrayController checkDuplicate:[connectionInfo objectForKey:@"alias"]]) {
        NSRunAlertPanel(@"Error", @"Connection alias name has been existed!", @"OK", nil, nil);
        return NO;
    }
    if ([usesshCheckBox state] == 1 && ([[connectionInfo objectForKey:@"bindaddress"] length] == 0 || [[connectionInfo objectForKey:@"sshhost"] length] == 0)) {
        NSRunAlertPanel(@"Error", @"Please full fill ssh information!", @"OK", nil, nil);
        return NO;
    }
    if ([usereplCheckBox state] == 1 && ([[connectionInfo objectForKey:@"servers"] length] == 0 || [[connectionInfo objectForKey:@"repl_name"] length] == 0)) {
        NSRunAlertPanel(@"Error", @"Please full fill replica-set information!", @"OK", nil, nil);
        return NO;
    }
    return YES;
}

- (IBAction)enableSSH:(id)sender
{
    if ([usesshCheckBox state] == 1)
    {
        [bindaddressTextField setEnabled:YES];
        [bindportTextField setEnabled:YES];
        [sshhostTextField setEnabled:YES];
        [sshuserTextField setEnabled:YES];
        [sshpasswordTextField setEnabled:YES];
        [sshportTextField setEnabled:YES];
        [sshkeyfileTextField setEnabled:YES];
    }else {
        [bindaddressTextField setEnabled:NO];
        [bindportTextField setEnabled:NO];
        [sshhostTextField setEnabled:NO];
        [sshuserTextField setEnabled:NO];
        [sshpasswordTextField setEnabled:NO];
        [sshportTextField setEnabled:NO];
        [sshkeyfileTextField setEnabled:NO];
    }

}

- (IBAction)enableRepl:(id)sender
{
    if ([usereplCheckBox state] == 1)
    {
        [serversTextField setEnabled:YES];
        [replnameTextField setEnabled:YES];
    }else {
        [serversTextField setEnabled:NO];
        [replnameTextField setEnabled:NO];
    }
    
}

- (IBAction)chooseKeyPath:(id)sender
{
    NSOpenPanel *tvarNSOpenPanelObj	= [NSOpenPanel openPanel];
    NSInteger tvarNSInteger	= [tvarNSOpenPanelObj runModalForTypes:nil];
    if(tvarNSInteger == NSOKButton){
     	NSLog(@"doOpen we have an OK button");
        //NSString * tvarDirectory = [tvarNSOpenPanelObj directory];
        //NSLog(@"doOpen directory = %@",tvarDirectory);
        NSString * tvarFilename = [tvarNSOpenPanelObj filename];
        NSLog(@"doOpen filename = %@",tvarFilename);
        [sshkeyfileTextField setStringValue:tvarFilename];
    } else if(tvarNSInteger == NSCancelButton) {
     	NSLog(@"doOpen we have a Cancel button");
     	return;
    } else {
     	NSLog(@"doOpen tvarInt not equal 1 or zero = %3d",tvarNSInteger);
     	return;
    } // end if
}

@end
