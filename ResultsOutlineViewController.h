//
//  ResultsOutlineViewController.h
//  MongoHub
//
//  Created by Syd on 10-4-26.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ResultsOutlineViewController : NSObject{
    IBOutlet NSOutlineView *myOutlineView;
    NSMutableArray *results;
}

@property (nonatomic, retain) NSOutlineView  *myOutlineView;
@property (nonatomic, retain) NSMutableArray *results;

- (id)rootForItem:(id)item;

@end
