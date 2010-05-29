//
//  Mongo.mm
//  MongoHub
//
//  Created by Syd on 10-4-25.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "MongoDB.h"
#import "NSString+Extras.h"
#import "JSON.h"
#import <mongo/client/dbclient.h>

@implementation MongoDB


- (id)init {
    self = [super init];
    return self;
}

- (id)initWithConn:(NSString *)host {
    self = [super init];
    [self connect:host];
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (bool)connect:(NSString *)host {
    conn = new mongo::DBClientConnection;
    try {
        conn->connect([host UTF8String]);
        NSLog(@"Connected to: %@", host);
        return true;
    }catch( mongo::DBException &e ) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
        return false;
    }
    return false;
}

- (void)authUser:(NSString *)user 
            pass:(NSString *)pass 
        database:(NSString *)db
{
    try {
        std::string errmsg;
        std::string dbname;
        if ([db isPresent]) {
            dbname = [db UTF8String];
        }else {
            dbname = "admin";
        }

        bool ok = conn->auth(dbname, std::string([user UTF8String]), std::string([pass UTF8String]), errmsg);
        if (!ok) {
            NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
        }
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
}

- (NSArray *)listDatabases {
    try {
        std::list<std::string> dbs = conn->getDatabaseNames();
        NSMutableArray *dblist = [[NSMutableArray alloc] initWithCapacity:dbs.size() ];
        for (std::list<std::string>::iterator it=dbs.begin();it!=dbs.end();++it)
        {
            NSString *db = [[NSString alloc] initWithUTF8String:(*it).c_str()];
            [dblist addObject:db];
            [db release];
        }
        NSArray *response = [NSArray arrayWithArray:dblist];
        [dblist release];
        return response;
    }catch( mongo::DBException &e ) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
    return nil;
}

- (NSArray *)listCollections:(NSString *)db 
                        user:(NSString *)user 
                    password:(NSString *)password {
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([db UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return nil;
            }
        }
        
        std::list<std::string> collections = conn->getCollectionNames([db UTF8String]);
        NSMutableArray *clist = [[NSMutableArray alloc] initWithCapacity:collections.size() ];
        unsigned int istartp = [db length] + 1;
        for (std::list<std::string>::iterator it=collections.begin();it!=collections.end();++it)
        {
            NSString *collection = [[NSString alloc] initWithUTF8String:(*it).c_str()];
            [clist addObject:[collection substringWithRange:NSMakeRange( istartp, [collection length]-istartp )] ];
            [collection release];
        }
        NSArray *response = [NSArray arrayWithArray:clist];
        [clist release];
        return response;
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
    return nil;
}

- (NSMutableArray *) serverStatus
{
    try {
        mongo::BSONObj retval;
        conn->runCommand("admin", BSON("serverStatus"<<1), retval);
        return [self bsonDictWrapper:retval];
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
    return [NSMutableArray arrayWithArray:nil];
}

- (NSMutableArray *) dbStats:(NSString *)dbname 
                        user:(NSString *)user 
                    password:(NSString *)password 
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return nil;
            }
        }
        mongo::BSONObj retval;
        conn->runCommand([dbname UTF8String], BSON("dbstats"<<1), retval);
        return [self bsonDictWrapper:retval];
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
    return nil;
}

- (void) dropDB:(NSString *)dbname 
                        user:(NSString *)user 
                    password:(NSString *)password 
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return;
            }
        }
        conn->dropDatabase([dbname UTF8String]);
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
}

- (NSMutableArray *) collStats:(NSString *)collectionname 
                         forDB:(NSString *)dbname 
                          user:(NSString *)user 
                      password:(NSString *)password 
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return nil;
            }
        }
        mongo::BSONObj retval;
        conn->runCommand([dbname UTF8String], BSON("collstats"<<[collectionname UTF8String]), retval);
        return [self bsonDictWrapper:retval];
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
    return nil;
}

- (void) createCollection:(NSString *)collectionname 
                  forDB:(NSString *)dbname 
                   user:(NSString *)user 
               password:(NSString *)password 
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return;
            }
        }
        NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
        conn->createCollection([col UTF8String]);
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
}

- (void) dropCollection:(NSString *)collectionname 
                  forDB:(NSString *)dbname 
                   user:(NSString *)user 
               password:(NSString *)password 
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return;
            }
        }
        NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
        conn->dropCollection([col UTF8String]);
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
}


- (NSMutableArray *) findInDB:(NSString *)dbname 
                   collection:(NSString *)collectionname 
                         user:(NSString *)user 
                     password:(NSString *)password 
                     critical:(NSString *)critical 
                       fields:(NSString *)fields 
                         skip:(NSNumber *)skip 
                        limit:(NSNumber *)limit 
                         sort:(NSString *)sort
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return nil;
            }
        }
        NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
        mongo::BSONObj criticalBSON;
        if ([critical isPresent]) {
            NSError *error = nil;
            SBJSON *json = [SBJSON new];
            [json objectWithString:critical error:&error];
            [json release];
            if (error) {
                NSRunAlertPanel(@"Error", [error localizedDescription], @"OK", nil, nil);
                return nil;
            }
            try{
                criticalBSON = mongo::fromjson([critical UTF8String]);
            }catch (mongo::MsgAssertionException &e) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
                return nil;
            }
        }
        mongo::BSONObj sortBSON;
        if ([sort isPresent]) {
            NSError *error = nil;
            SBJSON *json = [SBJSON new];
            [json objectWithString:sort error:&error];
            [json release];
            if (error) {
                NSRunAlertPanel(@"Error", [error localizedDescription], @"OK", nil, nil);
                return nil;
            }
            try{
                sortBSON = mongo::fromjson([sort UTF8String]);
            }catch (mongo::MsgAssertionException &e) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
                return nil;
            }
        }
        mongo::BSONObj fieldsToReturn;
        if ([fields isPresent]) {
            NSArray *keys = [[NSArray alloc] initWithArray:[fields componentsSeparatedByString:@","]];
            NSMutableArray *tmpstr = [[NSMutableArray alloc] initWithCapacity:[keys count]];
            for (NSString *str in keys) {
                [tmpstr addObject:[NSString stringWithFormat:@"%@:1", str]];
            }
            NSString *jsFields = [[NSString alloc] initWithFormat:@"{%@}", [tmpstr componentsJoinedByString:@","] ];
            NSError *error = nil;
            SBJSON *json = [SBJSON new];
            [json objectWithString:jsFields error:&error];
            [json release];
            if (error) {
                NSRunAlertPanel(@"Error", [error localizedDescription], @"OK", nil, nil);
                return nil;
            }
            try{
                fieldsToReturn = mongo::fromjson([jsFields UTF8String]);
            }catch (mongo::MsgAssertionException &e) {
                [jsFields release];
                [tmpstr release];
                [keys release];
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
                return nil;
            }
            [jsFields release];
            [tmpstr release];
            [keys release];
        }
        std::auto_ptr<mongo::DBClientCursor> cursor = conn->query(std::string([col UTF8String]), mongo::Query(criticalBSON).sort(sortBSON), [limit intValue], [skip intValue], &fieldsToReturn);
        NSMutableArray *response = [[NSMutableArray alloc] initWithCapacity:[limit intValue]];
        while( cursor->more() )
        {
            mongo::BSONObj b = cursor->next();
            mongo::BSONElement e;
            b.getObjectID (e);
            NSString *oid;
            NSString *oidType;
            if (e.type() == mongo::jstOID)
            {
                oidType = [[NSString alloc] initWithString:@"ObjectId"];
                oid = [[NSString alloc] initWithUTF8String:e.__oid().str().c_str()];
            }else {
                oidType = [[NSString alloc] initWithString:@"String"];
                oid = [[NSString alloc] initWithUTF8String:e.str().c_str()];
            }
            
            NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:4];
            [item setObject:@"_id" forKey:@"name"];
            [item setObject:oidType forKey:@"type"];
            [item setObject:oid forKey:@"value"];
            [item setObject:[self bsonDictWrapper:b] forKey:@"child"];
            [response addObject:item];
            [oid release];
            [oidType release];
            [item release];
        }
        return response;
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
    return nil;
}

- (void) updateInDB:(NSString *)dbname 
         collection:(NSString *)collectionname 
               user:(NSString *)user 
           password:(NSString *)password 
           critical:(NSString *)critical 
             fields:(NSString *)fields 
              upset:(NSNumber *)upset
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return;
            }
        }
        NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
        mongo::BSONObj criticalBSON;
        if ([critical isPresent]) {
            NSError *error = nil;
            SBJSON *json = [SBJSON new];
            [json objectWithString:critical error:&error];
            [json release];
            if (error) {
                NSRunAlertPanel(@"Error", [error localizedDescription], @"OK", nil, nil);
                return;
            }
            try{
                criticalBSON = mongo::fromjson([critical UTF8String]);
            }catch (mongo::MsgAssertionException &e) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
                return;
            }
        }
        mongo::BSONObj fieldsBSON;
        if ([fields isPresent]) {
            NSError *error = nil;
            SBJSON *json = [SBJSON new];
            [json objectWithString:fields error:&error];
            [json release];
            if (error) {
                NSRunAlertPanel(@"Error", [error localizedDescription], @"OK", nil, nil);
                return;
            }
            try{
                //fieldsBSON = mongo::fromjson([[NSString stringWithFormat:@"{$set:%@}", fields] UTF8String]);
                fieldsBSON = mongo::fromjson([fields UTF8String]);
            }catch (mongo::MsgAssertionException &e) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
                return;
            }
        }
        conn->update(std::string([col UTF8String]), criticalBSON, fieldsBSON, (bool)[upset intValue]);
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
}

- (void) removeInDB:(NSString *)dbname 
         collection:(NSString *)collectionname 
               user:(NSString *)user 
           password:(NSString *)password 
           critical:(NSString *)critical
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return;
            }
        }
        NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
        mongo::BSONObj criticalBSON;
        if ([critical isPresent]) {
            NSError *error = nil;
            SBJSON *json = [SBJSON new];
            [json objectWithString:critical error:&error];
            [json release];
            if (error) {
                NSRunAlertPanel(@"Error", [error localizedDescription], @"OK", nil, nil);
                return;
            }
            try{
                criticalBSON = mongo::fromjson([critical UTF8String]);
            }catch (mongo::MsgAssertionException &e) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
                return;
            }
            conn->remove(std::string([col UTF8String]), criticalBSON);
        }
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
}

- (void) insertInDB:(NSString *)dbname 
         collection:(NSString *)collectionname 
               user:(NSString *)user 
           password:(NSString *)password 
           insertData:(NSString *)insertData
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return;
            }
        }
        NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
        mongo::BSONObj insertDataBSON;
        if ([insertData isPresent]) {
            NSError *error = nil;
            SBJSON *json = [SBJSON new];
            [json objectWithString:insertData error:&error];
            [json release];
            if (error) {
                NSRunAlertPanel(@"Error", [error localizedDescription], @"OK", nil, nil);
                return;
            }
            try{
                insertDataBSON = mongo::fromjson([insertData UTF8String]);
            }catch (mongo::MsgAssertionException &e) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
                return;
            }
            conn->insert(std::string([col UTF8String]), insertDataBSON);
        }
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
}

- (NSMutableArray *) indexInDB:(NSString *)dbname 
         collection:(NSString *)collectionname 
               user:(NSString *)user 
           password:(NSString *)password
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return nil;
            }
        }
        NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
        std::auto_ptr<mongo::DBClientCursor> cursor = conn->getIndexes(std::string([col UTF8String]));
        NSMutableArray *response = [[NSMutableArray alloc] init];
        while( cursor->more() )
        {
            mongo::BSONObj b = cursor->next();
            NSString *name = [[NSString alloc] initWithUTF8String:b.getStringField("name")];
            NSMutableDictionary *item = [[NSMutableDictionary alloc] initWithCapacity:4];
            [item setObject:@"name" forKey:@"name"];
            [item setObject:@"String" forKey:@"type"];
            [item setObject:name forKey:@"value"];
            [item setObject:[self bsonDictWrapper:b] forKey:@"child"];
            [response addObject:item];
            [name release];
            [item release];
        }
        return response;
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
    return nil;
}

- (void) ensureIndexInDB:(NSString *)dbname 
         collection:(NSString *)collectionname 
               user:(NSString *)user 
           password:(NSString *)password 
         indexData:(NSString *)indexData
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return;
            }
        }
        NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
        mongo::BSONObj indexDataBSON;
        if ([indexData isPresent]) {
            NSError *error = nil;
            SBJSON *json = [SBJSON new];
            [json objectWithString:indexData error:&error];
            [json release];
            if (error) {
                NSRunAlertPanel(@"Error", [error localizedDescription], @"OK", nil, nil);
                return;
            }
            try{
                indexDataBSON = mongo::fromjson([indexData UTF8String]);
            }catch (mongo::MsgAssertionException &e) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
                return;
            }
        }
        conn->ensureIndex(std::string([col UTF8String]), indexDataBSON);
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
}

- (void) reIndexInDB:(NSString *)dbname 
              collection:(NSString *)collectionname 
                    user:(NSString *)user 
                password:(NSString *)password
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return;
            }
        }
        NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
        conn->reIndex(std::string([col UTF8String]));
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
}

- (void) dropIndexInDB:(NSString *)dbname 
              collection:(NSString *)collectionname 
                    user:(NSString *)user 
                password:(NSString *)password 
               indexName:(NSString *)indexName
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return;
            }
        }
        NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
        conn->dropIndex(std::string([col UTF8String]), [indexName UTF8String]);
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
}

- (int) countInDB:(NSString *)dbname 
                   collection:(NSString *)collectionname 
                         user:(NSString *)user 
                     password:(NSString *)password 
                     critical:(NSString *)critical 
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return nil;
            }
        }
        NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
        mongo::BSONObj criticalBSON;
        if ([critical isPresent]) {
            NSError *error = nil;
            SBJSON *json = [SBJSON new];
            [json objectWithString:critical error:&error];
            [json release];
            if (error) {
                NSRunAlertPanel(@"Error", [error localizedDescription], @"OK", nil, nil);
                return nil;
            }
            try{
                criticalBSON = mongo::fromjson([critical UTF8String]);
            }catch (mongo::MsgAssertionException &e) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
                return nil;
            }
        }
        int counter = conn->count(std::string([col UTF8String]), criticalBSON);
        return counter;
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
    return 0;
}

- (NSMutableArray *)mapReduceInDB:dbname 
                       collection:collectionname 
                             user:user 
                         password:password 
                            mapJs:mapJs 
                         reduceJs:reduceJs 
                         critical:critical 
                           output:output
{
    try {
        if ([user length]>0 && [password length]>0) {
            std::string errmsg;
            bool ok = conn->auth(std::string([dbname UTF8String]), std::string([user UTF8String]), std::string([password UTF8String]), errmsg);
            if (!ok) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:errmsg.c_str()], @"OK", nil, nil);
                return nil;
            }
        }
        if (![mapJs isPresent] || ![reduceJs isPresent]) {
            return nil;
        }
        NSString *col = [NSString stringWithFormat:@"%@.%@", dbname, collectionname];
        mongo::BSONObj criticalBSON;
        if ([critical isPresent]) {
            NSError *error = nil;
            SBJSON *json = [SBJSON new];
            [json objectWithString:critical error:&error];
            [json release];
            if (error) {
                NSRunAlertPanel(@"Error", [error localizedDescription], @"OK", nil, nil);
                return nil;
            }
            try{
                criticalBSON = mongo::fromjson([critical UTF8String]);
            }catch (mongo::MsgAssertionException &e) {
                NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
                return nil;
            }
        }
        mongo::BSONObj retval = conn->mapreduce(std::string([col UTF8String]), std::string([mapJs UTF8String]), std::string([reduceJs UTF8String]), criticalBSON, std::string([output UTF8String]));
        return [self bsonDictWrapper:retval];
    }catch (mongo::DBException &e) {
        NSRunAlertPanel(@"Error", [NSString stringWithUTF8String:e.what()], @"OK", nil, nil);
    }
    return nil;
}

#pragma mark BSON to NSMutableArray
- (NSMutableArray *) bsonDictWrapper:(mongo::BSONObj)retval
{
    if (!retval.isEmpty())
    {
        std::set<std::string> fieldNames;
        retval.getFieldNames(fieldNames);
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:fieldNames.size()];
        for(std::set<std::string>::iterator it=fieldNames.begin();it!=fieldNames.end();++it)
        {
            mongo::BSONElement e = retval.getField((*it));
            NSString *fieldName = [[NSString alloc] initWithUTF8String:(*it).c_str()];
            NSMutableArray *child = [[NSMutableArray alloc] init];
            NSString *value;
            NSString *fieldType;
            if (e.type() == mongo::Array) {
                mongo::BSONObj b = e.embeddedObject();
                NSMutableArray *tmp = [self bsonArrayWrapper:b];
                if (tmp!=nil) {
                    child = tmp;
                    value = @"";
                }else {
                    value = @"[ ]";
                }

                fieldType = @"Array";
            }else if (e.type() == mongo::Object) {
                mongo::BSONObj b = e.embeddedObject();
                NSMutableArray *tmp = [self bsonDictWrapper:b];
                if (tmp!=nil) {
                    child = tmp;
                    value = @"";
                }else {
                    value = @"{ }";
                }

                fieldType = @"Object";
            }else{
                if (e.type() == mongo::Bool) {
                    fieldType = @"Bool";
                    if (e.boolean()) {
                        value = @"YES";
                    }else {
                        value = @"NO";
                    }
                }else if (e.type() == mongo::NumberDouble) {
                    fieldType = @"Double";
                    value = [NSString stringWithFormat:@"%f", e.number()];
                }else if (e.type() == mongo::NumberInt) {
                    fieldType = @"Int";
                    value = [NSString stringWithFormat:@"%d", (int)(e.number())];
                }else if (e.type() == mongo::Date) {
                    fieldType = @"Date";
                    value = [NSString stringWithFormat:@"%d", (int)e.date()];
                }else if (e.type() == mongo::BinData) {
                    int binlen;
                    fieldType = @"BinData";
                    value = [NSString stringWithUTF8String:e.binData(binlen)];
                }else if (e.type() == mongo::NumberLong) {
                    fieldType = @"Long";
                    value = [NSString stringWithFormat:@"%d", (long long int)(e.number())];
                }else if ([fieldName isEqualToString:@"_id" ]) {
                    if (e.type() == mongo::jstOID)
                    {
                        fieldType = @"ObjectId";
                        value = [NSString stringWithUTF8String:e.__oid().str().c_str()];
                    }else {
                        fieldType = @"String";
                        value = [NSString stringWithUTF8String:e.str().c_str()];
                    }
                }else {
                    fieldType = @"String";
                    value = [NSString stringWithUTF8String:e.str().c_str()];
                }
            }
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:4];
            [dict setObject:fieldName forKey:@"name"];
            [dict setObject:fieldType forKey:@"type"];
            [dict setObject:value forKey:@"value"];
            [dict setObject:child forKey:@"child"];
            [arr addObject:dict];
            [dict release];
            [fieldName release];
            [child release];
        }
        return arr;
    }
    return nil;
}

- (NSMutableArray *) bsonArrayWrapper:(mongo::BSONObj)retval
{
    if (!retval.isEmpty())
    {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        mongo::BSONElement idElm;
        bool hasId = retval.getObjectID(idElm);
        mongo::BSONObjIterator it (retval);
        unsigned int i=0;
        while(it.more())
        {
            mongo::BSONElement e = it.next();
            NSString *fieldName = [[NSString alloc] initWithFormat:@"%d", i];
            NSString *value;
            NSString *fieldType;
            NSMutableArray *child = [[NSMutableArray alloc] init];
            if (e.type() == mongo::Array) {
                mongo::BSONObj b = e.embeddedObject();
                NSMutableArray *tmp = [self bsonArrayWrapper:b];
                if (tmp == nil) {
                    value = @"[ ]";
                    if (hasId) {
                        [arr addObject:@"[ ]"];
                    }
                }else {
                    child = tmp;
                    value = @"";
                    if (hasId) {
                        [arr addObject:tmp];
                    }
                }
                fieldType = @"Array";
            }else if (e.type() == mongo::Object) {
                mongo::BSONObj b = e.embeddedObject();
                NSMutableArray *tmp = [self bsonDictWrapper:b];
                if (tmp == nil) {
                    value = @"";
                    if (hasId) {
                        [arr addObject:@"{ }"];
                    }
                }else {
                    child = tmp;
                    value = @"{ }";
                    if (hasId) {
                        [arr addObject:tmp];
                    }
                }
                fieldType = @"Object";
            }else{
                if (e.type() == mongo::Bool) {
                    fieldType = @"Bool";
                    if (e.boolean()) {
                        value = @"YES";
                    }else {
                        value = @"NO";
                    }
                    if (hasId) {
                        [arr addObject:[NSNumber numberWithBool:e.boolean()]];
                    }
                }else if (e.type() == mongo::NumberDouble) {
                    fieldType = @"Double";
                    value = [NSString stringWithFormat:@"%f", e.number()];
                    if (hasId) {
                        [arr addObject:[NSNumber numberWithDouble:e.number()]];
                    }
                }else if (e.type() == mongo::NumberInt) {
                    fieldType = @"Int";
                    value = [NSString stringWithFormat:@"%d", (int)(e.number())];
                    if (hasId) {
                        [arr addObject:[NSNumber numberWithInt:e.number()]];
                    }
                }else if (e.type() == mongo::Date) {
                    fieldType = @"Date";
                    value = [NSString stringWithFormat:@"%d", (int)e.date()];
                    if (hasId) {
                        [arr addObject:[NSNumber numberWithInt:e.date()]];
                    }
                }else if (e.type() == mongo::BinData) {
                    fieldType = @"BinData";
                    int binlen;
                    value = [NSString stringWithUTF8String:e.binData(binlen)];
                    if (hasId) {
                        [arr addObject:[NSString stringWithUTF8String:e.binData(binlen)]];
                    }
                }else if (e.type() == mongo::NumberLong) {
                    fieldType = @"Long";
                    value = [NSString stringWithFormat:@"%d", (long long int)(e.number())];
                    if (hasId) {
                        [arr addObject:[NSString stringWithFormat:@"%d", (long long int)(e.number())]];
                    }
                }else {
                    fieldType = @"String";
                    value = [NSString stringWithUTF8String:e.str().c_str()];
                    if (hasId) {
                        [arr addObject:[NSString stringWithUTF8String:e.str().c_str()]];
                    }
                }
            }
            if (!hasId) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:4];
                [dict setObject:fieldName forKey:@"name"];
                [dict setObject:fieldType forKey:@"type"];
                [dict setObject:value forKey:@"value"];
                [dict setObject:child forKey:@"child"];
                [arr addObject:dict];
                [dict release];
            }
            [fieldName release];
            [child release];
            i ++;
        }
        return arr;
    }
    return nil;
}

@end
