//
//  IconCollectionItem.m
//  SEOBox
//
//  Created by Syd on 10-2-28.
//  Copyright 2010 MusicPeace.ORG. All rights reserved.
//

#import "IconCollectionItem.h"
#import "IconViewBox.h"

@implementation IconCollectionItem

-(void)setSelected:(BOOL)flag {
    [super setSelected:flag];
    
    // tell the view that it has been selected
    IconViewBox* theView = (IconViewBox* )[self view];
    if([theView isKindOfClass:[IconViewBox class]]) {
        [theView setSelected:flag];
        [theView setNeedsDisplay:YES];
    }
}

- (void)doubleClick:(id)sender {
	if([self collectionView] && [[self collectionView] delegate] && [[[self collectionView] delegate] respondsToSelector:@selector(doubleClick:)]) {
		[[[self collectionView] delegate] performSelector:@selector(doubleClick:) withObject:self];
	}
}
@end
