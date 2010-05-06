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
@synthesize aliasTextField;
@synthesize adminuserTextField;
@synthesize adminpassTextField;
@synthesize usesshCheckBox;
@synthesize bindaddressTextField;
@synthesize bindportTextField;
@synthesize sshhostTextField;
@synthesize sshportTextField;
@synthesize sshuserTextField;
@synthesize sshpasswordTextField;
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
    [aliasTextField release];
    [adminuserTextField release];
    [adminpassTextField release];
    [usesshCheckBox release];
    [bindaddressTextField release];
    [bindportTextField release];
    [sshhostTextField release];
    [sshportTextField release];
    [sshuserTextField release];
    [sshpasswordTextField release];
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
    [aliasTextField bind:@"value" toObject:connection withKeyPath:@"alias"  options:nil];
    [adminuserTextField bind:@"value" toObject:connection withKeyPath:@"adminuser"  options:nil];
    [adminpassTextField bind:@"value" toObject:connection withKeyPath:@"adminpass"  options:nil];
    [bindaddressTextField bind:@"value" toObject:connection withKeyPath:@"bindaddress"  options:nil];
    [bindportTextField bind:@"value" toObject:connection withKeyPath:@"bindport"  options:nil];
    [sshhostTextField bind:@"value" toObject:connection withKeyPath:@"sshhost"  options:nil];
    [sshportTextField bind:@"value" toObject:connection withKeyPath:@"sshport"  options:nil];
    [sshuserTextField bind:@"value" toObject:connection withKeyPath:@"sshuser"  options:nil];
    [sshpasswordTextField bind:@"value" toObject:connection withKeyPath:@"sshpassword"  options:nil];
    [usesshCheckBox bind:@"value" toObject:connection withKeyPath:@"usessh"  options:nil];
    [self enableSSH:nil];
}

- (IBAction)cancel:(id)sender {
    [self close];
}

- (IBAction)save:(id)sender {
    NSString *host;
    NSUInteger hostport;
    NSString *alias;
    NSString *adminuser = [[NSString alloc] initWithString:[adminuserTextField stringValue]];
    NSString *adminpass = [[NSString alloc] initWithString:[adminpassTextField stringValue]];
    NSUInteger usessh = 0;
    NSString *bindaddress;
    NSUInteger bindport;
    NSString *sshhost;
    NSUInteger sshport;
    NSString *sshuser;
    NSString *sshpassword;
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
    if ([ [aliasTextField stringValue] length] == 0) {
        alias = [[NSString alloc] initWithString:@"localhost"];
    }else{
        alias = [[NSString alloc] initWithString:[aliasTextField stringValue]];
    }
    if ([usesshCheckBox state])
    {
        usessh = 1;
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
    }else{
        bindaddress = @"127.0.0.1";
        bindport = 8888;
        sshhost = @"";
        sshuser = @"";
        sshport = 22;
        sshpassword = @"";
    }
    NSArray *keys = [[NSArray alloc] initWithObjects:@"host", @"hostport", @"alias", @"adminuser", @"adminpass", @"usessh", @"bindaddress", @"bindport", @"sshhost", @"sshport", @"sshuser", @"sshpassword", nil];
    NSArray *objs = [[NSArray alloc] initWithObjects:host, [NSNumber numberWithInt:hostport], alias, adminuser, adminpass, [NSNumber numberWithInt:usessh], bindaddress, [NSNumber numberWithInt:bindport], sshhost, [NSNumber numberWithInt:sshport], sshuser, sshpassword, nil];
    NSDictionary *connectionInfo = [[NSDictionary alloc] initWithObjects:objs forKeys:keys];
    [keys release];
    [objs release];
    [host release];
    [alias release];
    [adminuser release];
    [adminpass release];
    if (usessh == 1)
    {
        [sshhost release];
        [sshuser release];
        [sshpassword release];
        [bindaddress release];
    }
    if ([self validateConnection:connectionInfo]) {
        connection.host = [connectionInfo objectForKey:@"host"];
        connection.hostport = [connectionInfo objectForKey:@"hostport"];
        connection.alias = [connectionInfo objectForKey:@"alias"];
        connection.adminuser = [connectionInfo objectForKey:@"adminuser"];
        connection.adminpass = [connectionInfo objectForKey:@"adminpass"];
        connection.usessh = [connectionInfo objectForKey:@"usessh"];
        connection.bindaddress = [connectionInfo objectForKey:@"bindaddress"];
        connection.bindport = [connectionInfo objectForKey:@"bindport"];
        connection.sshhost = [connectionInfo objectForKey:@"sshhost"];
        connection.sshport = [connectionInfo objectForKey:@"sshport"];
        connection.sshuser = [connectionInfo objectForKey:@"sshuser"];
        connection.sshpassword = [connectionInfo objectForKey:@"sshpassword"];
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
    }else {
        [bindaddressTextField setEnabled:NO];
        [bindportTextField setEnabled:NO];
        [sshhostTextField setEnabled:NO];
        [sshportTextField setEnabled:NO];
        [sshuserTextField setEnabled:NO];
        [sshpasswordTextField setEnabled:NO];
    }
    
}
@end
