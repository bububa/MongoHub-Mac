//
//  ProjectsCollectionView.m
//  SEOBox
//
//  Created by Syd on 10-2-28.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "ConnectionsCollectionView.h"


@implementation ConnectionsCollectionView

-(void)setSubviewSize:(CGFloat)theSubviewSize {
    [self setMaxItemSize:NSMakeSize(theSubviewSize,theSubviewSize)];
    [self setMinItemSize:NSMakeSize(theSubviewSize,theSubviewSize)];
}

-(void)drawRect:(NSRect)rect {
	[[NSColor colorWithCalibratedHue: 0 saturation: 0 brightness: 0.13 alpha: 1.0] set];
	NSRectFill([self frame]);
}
@end
