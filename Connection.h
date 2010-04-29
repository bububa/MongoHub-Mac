//
//  Database.h
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "Database.h"

@interface Connection: NSManagedObject {
    NSString *host;
    NSNumber *hostport;
    NSString *alias;
    NSString *sshhost;
    NSNumber *sshport;
    NSString *sshuser;
    NSString *sshpassword;
    NSString *bindaddress;
    NSNumber *bindport;
    NSSet *databases;
    NSNumber *usessh;
}

@property (nonatomic, retain) NSString *host;
@property (nonatomic, retain) NSNumber *hostport;
@property (nonatomic, retain) NSString *alias;
@property (nonatomic, retain) NSSet *databases;
@property (nonatomic, retain) NSString *sshhost;
@property (nonatomic, retain) NSNumber *sshport;
@property (nonatomic, retain) NSString *sshuser;
@property (nonatomic, retain) NSString *sshpassword;
@property (nonatomic, retain) NSString *bindaddress;
@property (nonatomic, retain) NSNumber *bindport;
@property (nonatomic, retain) NSNumber *usessh;

@end
