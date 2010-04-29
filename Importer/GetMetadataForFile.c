//
//  GetMetadataForFile.c
//  MongoHub Spotlight Importer
//
//  Created by Syd on 10-4-24.
//  Copyright (c) 2010 MusicPeace.ORG. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#import <CoreData/CoreData.h>

#import "MySpotlightImporter.h"


//==============================================================================
//
//	Get metadata attributes from document files
//
//	The purpose of this function is to extract useful information from the
//	file formats for your document, and set the values into the attribute
//  dictionary for Spotlight to include.
//
//==============================================================================


Boolean GetMetadataForFile(void* thisInterface, 
			   CFMutableDictionaryRef attributes, 
			   CFStringRef contentTypeUTI,
			   CFStringRef pathToFile)
{
    /* Pull any available metadata from the file at the specified path */
    /* Return the attribute keys and attribute values in the dict */
    /* Return TRUE if successful, FALSE if there was no data provided */
	/* The path could point to either a Core Data store file in which */
	/* case we import the store's metadata, or it could point to a Core */
	/* Data external record file for a specific record instances */

    NSAutoreleasePool *pool  = [[NSAutoreleasePool alloc] init];
    NSError *error = nil;
    Boolean ok = FALSE;
    
    if ([(NSString *)contentTypeUTI isEqualToString:@"YOUR_STORE_FILE_UTI"]) {
    
        // import from store file metadata
        
        // Create the URL, then attempt to get the meta-data from the store
        NSURL *url = [NSURL fileURLWithPath: (NSString *)pathToFile];
        NSDictionary *metadata = [NSPersistentStoreCoordinator 
            metadataForPersistentStoreOfType:nil URL:url error:&error];

        // If there is no error, add the info
        if ( error == NULL ) {

			// Get the information you are interested in from the dictionary
			// "YOUR_INFO" should be replaced by key(s) you are interested in
			
			NSObject *contentToIndex = [metadata objectForKey: @"YOUR_INFO"];
			if ( contentToIndex != nil ) {
			
			  // Add the metadata to the text content for indexing
			  [(NSMutableDictionary *)attributes setObject:contentToIndex 
				forKey:(NSString *)kMDItemTextContent];
			  ok = TRUE;    
			}
        }
    
    } else if ([(NSString *)contentTypeUTI isEqualToString:@"YOUR_EXTERNAL_RECORD_UTI"]) {
    
        // import from an external record file
		
        MySpotlightImporter *importer = [[MySpotlightImporter alloc] init];

        ok = [importer importFileAtPath:(NSString *)pathToFile attributes:(NSMutableDictionary *)attributes error:&error];
        [importer release];
        
    }

    
	// Return the status
    [pool drain];
	
    return ok;
}
