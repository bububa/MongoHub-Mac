//
//  EditConnectionController.m
//  MongoHub
//
//  Created by Syd on 10-4-25.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "Configure.h"
#import "EditConnectionController.h"
#import "ConnectionsArrayController.h"
#import "Connection.h"


@implementation EditConnectionController

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
@synthesize connection;
@synthesize connectionsArrayController;
@synthesize managedObjectContext;

- (id)init {
    if (![super initWithWindowNibName:@"EditConnection"]) return nil;
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
    [connection release];
    [connectionsArrayController release];
    [managedObjectContext release];
    [super dealloc];
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (IBAction)showWindow:(id)sender {
    [super showWindow:sender];
    [hostTextField bind:@"value" toObject:connection withKeyPath:@"host"  options:nil];
    [hostportTextField bind:@"value" toObject:connection withKeyPath:@"hostport"  options:nil];
    [serversTextField bind:@"value" toObject:connection withKeyPath:@"servers"  options:nil];
    [replnameTextField bind:@"value" toObject:connection withKeyPath:@"repl_name"  options:nil];
    [usereplCheckBox bind:@"value" toObject:connection withKeyPath:@"userepl"  options:nil];
    [aliasTextField bind:@"value" toObject:connection withKeyPath:@"alias"  options:nil];
    [adminuserTextField bind:@"value" toObject:connection withKeyPath:@"adminuser"  options:nil];
    [adminpassTextField bind:@"value" toObject:connection withKeyPath:@"adminpass"  options:nil];
    [defaultdbTextField bind:@"value" toObject:connection withKeyPath:@"defaultdb" options:nil];
    [bindaddressTextField bind:@"value" toObject:connection withKeyPath:@"bindaddress"  options:nil];
    [bindportTextField bind:@"value" toObject:connection withKeyPath:@"bindport"  options:nil];
    [sshhostTextField bind:@"value" toObject:connection withKeyPath:@"sshhost"  options:nil];
    [sshportTextField bind:@"value" toObject:connection withKeyPath:@"sshport"  options:nil];
    [sshuserTextField bind:@"value" toObject:connection withKeyPath:@"sshuser"  options:nil];
    [sshpasswordTextField bind:@"value" toObject:connection withKeyPath:@"sshpassword"  options:nil];
    [sshkeyfileTextField bind:@"value" toObject:connection withKeyPath:@"sshkeyfile"  options:nil];
    [usesshCheckBox bind:@"value" toObject:connection withKeyPath:@"usessh"  options:nil];
    [self enableSSH:nil];
    [self enableRepl:nil];
}

- (IBAction)cancel:(id)sender {
    [self close];
}

- (IBAction)save:(id)sender {
    NSString *host;
    NSUInteger hostport;
    NSString *servers;
    NSString *repl_name;
    NSUInteger userepl = 0;
    NSString *alias;
    NSString *adminuser = [[NSString alloc] initWithString:[adminuserTextField stringValue]];
    NSString *adminpass = [[NSString alloc] initWithString:[adminpassTextField stringValue]];
    NSString *defaultdb = [[NSString alloc] initWithString:[defaultdbTextField stringValue]];
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
    if ([ [sshportTextField stringValue] length] == 0) {
        sshport = 22;
    }else{
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
    NSDictionary *connectionInfo = [[NSDictionary alloc] initWithObjects:objs forKeys:keys];
    [keys release];
    [objs release];
    [host release];
    [servers release];
    [repl_name release];
    [alias release];
    [adminuser release];
    [adminpass release];
    [defaultdb release];
    [sshhost release];
    [sshuser release];
    [sshpassword release];
    [sshkeyfile release];
    [bindaddress release];
    
    if ([self validateConnection:connectionInfo]) {
        connection.host = [connectionInfo objectForKey:@"host"];
        connection.hostport = [connectionInfo objectForKey:@"hostport"];
        connection.servers = [connectionInfo objectForKey:@"servers"];
        connection.repl_name = [connectionInfo objectForKey:@"repl_name"];
        connection.userepl = [connectionInfo objectForKey:@"userepl"];
        connection.alias = [connectionInfo objectForKey:@"alias"];
        connection.adminuser = [connectionInfo objectForKey:@"adminuser"];
        connection.adminpass = [connectionInfo objectForKey:@"adminpass"];
        connection.defaultdb = [connectionInfo objectForKey:@"defaultdb"];
        connection.usessh = [connectionInfo objectForKey:@"usessh"];
        connection.bindaddress = [connectionInfo objectForKey:@"bindaddress"];
        connection.bindport = [connectionInfo objectForKey:@"bindport"];
        connection.sshhost = [connectionInfo objectForKey:@"sshhost"];
        connection.sshport = [connectionInfo objectForKey:@"sshport"];
        connection.sshuser = [connectionInfo objectForKey:@"sshuser"];
        connection.sshpassword = [connectionInfo objectForKey:@"sshpassword"];
        connection.sshkeyfile = [connectionInfo objectForKey:@"sshkeyfile"];
        [self close];
    }
    [connectionInfo release];
}

- (BOOL)validateConnection:(NSDictionary *)connectionInfo
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
    if (![[connectionInfo objectForKey:@"alias"] isEqualToString:connection.alias] && [connectionsArrayController checkDuplicate:[connectionInfo objectForKey:@"alias"]]) {
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
        [sshportTextField setEnabled:YES];
        [sshpasswordTextField setEnabled:YES];
        [sshkeyfileTextField setEnabled:YES];
    }else {
        [bindaddressTextField setEnabled:NO];
        [bindportTextField setEnabled:NO];
        [sshhostTextField setEnabled:NO];
        [sshportTextField setEnabled:NO];
        [sshuserTextField setEnabled:NO];
        [sshpasswordTextField setEnabled:NO];
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
