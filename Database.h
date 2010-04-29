//
//  Database.h
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

@class Connection;

@interface Database : NSManagedObject {
    NSString *name;
    NSString *user;
    NSString *password;
    Connection *connection;
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, retain) Connection *connection;

@end
