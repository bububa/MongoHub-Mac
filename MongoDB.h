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
    mongo::DBClientReplicaSet::DBClientReplicaSet *repl_conn;
    BOOL isRepl;
}
- (mongo::DBClientConnection *)mongoConnection;
- (mongo::DBClientReplicaSet::DBClientReplicaSet *)mongoReplConnection;

- (id)initWithConn:(NSString *)host;
- (id)initWithConn:(NSString *)name
             hosts:(NSArray *)hosts;
- (bool)connect:(NSString *)host;
- (bool)connect:(NSString *)name 
          hosts:(NSArray *)hosts;
- (bool)authUser:(NSString *)user 
            pass:(NSString *)pass 
        database:(NSString *)db;
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
- (void) saveInDB:(NSString *)dbname 
       collection:(NSString *)collectionname 
             user:(NSString *)user 
         password:(NSString *)password 
       jsonString:(NSString *)jsonString 
              _id:(NSString *)_id;
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
- (void) insertInDB:(NSString *)dbname 
         collection:(NSString *)collectionname 
               user:(NSString *)user 
           password:(NSString *)password 
               data:(NSDictionary *)insertData 
             fields:(NSArray *)fields 
         fieldTypes:(NSDictionary *)fieldTypes;
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
- (long long int) countInDB:(NSString *)dbname 
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

- (std::auto_ptr<mongo::DBClientCursor>) findAllCursorInDB:(NSString *)dbname collection:(NSString *)collectionname user:(NSString *)user password:(NSString *)password fields:(mongo::BSONObj) fields;

- (std::auto_ptr<mongo::DBClientCursor>) findCursorInDB:(NSString *)dbname collection:(NSString *)collectionname user:(NSString *)user password:(NSString *)password critical:(NSString *)critical fields:(NSString *)fields skip:(NSNumber *)skip limit:(NSNumber *)limit sort:(NSString *)sort;

- (void) updateBSONInDB:(NSString *)dbname 
             collection:(NSString *)collectionname 
                   user:(NSString *)user 
               password:(NSString *)password 
               critical:(mongo::Query)critical 
                 fields:(mongo::BSONObj)fields 
                  upset:(bool)upset;

- (mongo::BSONObj) serverStat;
- (NSDictionary *) serverMonitor:(mongo::BSONObj)a second:(mongo::BSONObj)b currentDate:(NSDate *)now previousDate:(NSDate *)previous;
- (double) diff:(NSString *)aName first:(mongo::BSONObj)a second:(mongo::BSONObj)b timeInterval:(NSTimeInterval)interval;
- (double) percent:(NSString *)aOut value:(NSString *)aVal first:(mongo::BSONObj)a second:(mongo::BSONObj)b;
@end
