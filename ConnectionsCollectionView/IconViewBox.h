//
//  IconViewBox.h
//  SEOBox
//
//  Created by Syd on 10-2-28.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface IconViewBox : NSBox
{
    BOOL selectedFlag;
	IBOutlet id delegate;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) BOOL selectedFlag;

-(void)setSelected:(BOOL)flag;
-(BOOL)selected;
@end
