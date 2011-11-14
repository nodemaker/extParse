//
//  NSArrayAdditions.h
//  extParse
//
//  Created by Sumeru Chatterjee on 11/12/11.
//  Copyright (c) 2011 Sumeru Chatterjee. All rights reserved.
//

#import <Parse/PFConstants.h>
#import <Foundation/Foundation.h>

@interface NSArray (PFCategory)

+(NSArray*) arrayWithParseObjectArray:(NSArray*)parseObjectArray;

-(NSArray*) parseSerializableArray;
/*!
 Saves a collection of objects all at once and sets an error if necessary.
 @param objects The array of objects to save.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns whether the save succeeded.
 */
- (BOOL)parseSaveAll:(NSError **)error;

/*!
 Saves a collection of objects all at once asynchronously.
 @param objects The array of objects to save.
 */
- (void)parseSaveAllInBackground;

/*!
 Saves a collection of objects all at once asynchronously and calls a callback when done.
 @param objects The array of objects to save.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithError:(NSError *)error. error will be nil on success and set if there was an error. 
 */
- (void)parseSaveAllInBackgroundwithTarget:(id)target selector:(SEL)selector;

/*!
 Saves a collection of objects all at once asynchronously and the block when done.
 @param objects The array of objects to save.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error) 
 */
- (void)parseSaveAllInBackgroundwithBlock:(PFBooleanResultBlock)block;


@end
