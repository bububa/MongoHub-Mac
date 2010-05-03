//
//  Mongo.h
//  MongoHub
//
//  Created by Syd on 10-4-25.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <mongo/client/dbclient.h>

@interface MongoDB : NSObject {
    mongo::DBClientConnection *conn;
}

- (id)initWithConn:(NSString *)host;
- (bool)connect:(NSString *)host;
- (NSArray *)listDatabases;
- (NSArray *)listCollections:(NSString *)db 
                        user:(NSString *)user 
                    password:(NSString *)password;
- (NSMutableArray *) serverStatus;
- (NSMutableArray *) dbStats:(NSString *)dbname 
                        user:(NSString *)user 
                    password:(NSString *)password;
- (void) dropDB:(NSString *)dbname 
           user:(NSString *)user 
       password:(NSString *)password;
- (NSMutableArray *) collStats:(NSString *)collectionname 
                         forDB:(NSString *)dbname
                          user:(NSString *)user 
                      password:(NSString *)password;
- (void) createCollection:(NSString *)collectionname 
                    forDB:(NSString *)dbname 
                     user:(NSString *)user 
                 password:(NSString *)password;
- (void) dropCollection:(NSString *)collectionname 
                  forDB:(NSString *)dbname 
                   user:(NSString *)user 
               password:(NSString *)password;
- (NSMutableArray *) findInDB:(NSString *)dbname 
                   collection:(NSString *)collectionname 
                         user:(NSString *)user 
                     password:(NSString *)password 
                     critical:(NSString *)critical 
                       fields:(NSString *)fields 
                         skip:(NSNumber *)skip 
                        limit:(NSNumber *)limit 
                         sort:(NSString *)sort;
- (void) updateInDB:(NSString *)dbname 
         collection:(NSString *)collectionname 
               user:(NSString *)user 
           password:(NSString *)password 
           critical:(NSString *)critical 
             fields:(NSString *)fields 
              upset:(NSNumber *)upset;
- (void) removeInDB:(NSString *)dbname 
         collection:(NSString *)collectionname 
               user:(NSString *)user 
           password:(NSString *)password 
           critical:(NSString *)critical;
- (void) insertInDB:(NSString *)dbname 
         collection:(NSString *)collectionname 
               user:(NSString *)user 
           password:(NSString *)password 
           insertData:(NSString *)insertData;
- (NSMutableArray *) indexInDB:(NSString *)dbname 
                    collection:(NSString *)collectionname 
                          user:(NSString *)user 
                      password:(NSString *)password;
- (void) ensureIndexInDB:(NSString *)dbname 
              collection:(NSString *)collectionname 
                    user:(NSString *)user 
                password:(NSString *)password 
               indexData:(NSString *)indexData;
- (void) reIndexInDB:(NSString *)dbname 
          collection:(NSString *)collectionname 
                user:(NSString *)user 
            password:(NSString *)password;
- (void) dropIndexInDB:(NSString *)dbname 
            collection:(NSString *)collectionname 
                  user:(NSString *)user 
              password:(NSString *)password 
             indexName:(NSString *)indexName;
- (int) countInDB:(NSString *)dbname 
       collection:(NSString *)collectionname 
             user:(NSString *)user 
         password:(NSString *)password 
         critical:(NSString *)critical;
- (NSMutableArray *)mapReduceInDB:dbname 
                       collection:collectionname 
                             user:user 
                         password:password 
                            mapJs:mapFunction 
                         reduceJs:reduceFunction 
                         critical:critical 
                           output:output;
- (NSMutableArray *) bsonDictWrapper:(mongo::BSONObj)retval;
- (NSMutableArray *) bsonArrayWrapper:(mongo::BSONObj)retval;
@end
