//
//  DatabasesArrayCollection.h
//  MongoHub
//
//  Created by Syd on 10-4-25.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class Connection;
@class Database;

@interface DatabasesArrayController : NSArrayController {

}

- (id)newObjectWithConn:(Connection *)conn name:(NSString *)name user:(NSString *)user password:(NSString *)password;
- (void)clean:(Connection *)conn databases:(NSArray *)databases;
- (BOOL)checkDuplicate:(Connection *) conn name:(NSString *)name;
- (NSArray *)itemsUsingFetchPredicate:(NSPredicate *)fetchPredicate;
- (Database *)dbInfo:(Connection *) conn name:(NSString *)name;
@end
