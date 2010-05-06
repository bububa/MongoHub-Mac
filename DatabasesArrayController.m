//
//  DatabasesArrayCollection.m
//  MongoHub
//
//  Created by Syd on 10-4-25.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "DatabasesArrayController.h"
#import "Connection.h"
#import "Database.h"

@implementation DatabasesArrayController

- (void)awakeFromNib
{
	if ([NSArrayController instancesRespondToSelector:@selector(awakeFromNib)])
	{
		[super awakeFromNib];
	}
	[self setClearsFilterPredicateOnInsertion:NO];
}

- (id)newObjectWithConn:(Connection *) conn name:(NSString *)name user:(NSString *)user password:(NSString *)password
{
    id newObj = [super newObject];
    [newObj setValue:conn forKey:@"connection"];
    [newObj setValue:name forKey:@"name"];
    [newObj setValue:user forKey:@"user"];
    [newObj setValue:password forKey:@"password"];
    return newObj;
}

- (void)clean:(Connection *)conn databases:(NSArray *)databases
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"connection=%@", conn];
    NSArray *dblist = [self itemsUsingFetchPredicate:predicate];
    for (Database *db in dblist) {
        bool exist = false;
        for (NSString *d in databases) {
            if (db.name == d) {
                exist = true;
                break;
            }
        }
        if (!exist) {
            [super remove:db];
        }
    }
}

- (Database *)dbInfo:(Connection *) conn name:(NSString *)name
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"connection=%@ AND name=%@", conn, name];
    if ([[self itemsUsingFetchPredicate:predicate] count]>0) {
        return [[self itemsUsingFetchPredicate:predicate] objectAtIndex:0];
    }
    return nil;
}

- (BOOL)checkDuplicate:(Connection *) conn name:(NSString *)name
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"connection=%@ AND name=%@", conn, name];
    if ([[self itemsUsingFetchPredicate:predicate] count]>0) {
        return YES;
    }else {
        return NO;
    }
}

- (NSArray *)itemsUsingFetchPredicate:(NSPredicate *)fetchPredicate
{
    NSError *error = nil;
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:[self entityName]
                                   inManagedObjectContext:[self managedObjectContext]]];
    NSArray *objects = [[self managedObjectContext]  
                        executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Fetch error! In AWViewPositionArrayController:itemsUseingFetchPredicate");
    }
    return [objects filteredArrayUsingPredicate:fetchPredicate];
}

@end
