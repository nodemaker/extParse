//
//  NSObjectAdditions.h
//  extParse
//
//  Created by Sumeru Chatterjee on 11/12/11.
//  Copyright (c) 2011 Sumeru Chatterjee. All rights reserved.
//

#import <Parse/PFConstants.h>
#import <Foundation/Foundation.h>

extern NSString* const kParseObjectClassKey;
extern NSString* const kNullValue;

@interface NSObject (PFCategory)

+(NSObject*) objectFromParseObject:(PFObject*)parseObject;

-(BOOL) isParseSerializable;
-(NSDictionary*) parseSerializableDictionary;
-(void) syncParseObject;https://dl.dropbox.com/u/23360122/iTunesArtwork.png

/////SAVE//////
/*!
 Saves the NSObject as a PFObject.
 @result Returns whether the save succeeded.
 */
- (BOOL)parseSave;

/*!
 Saves the NSObject as a PFObject and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns whether the save succeeded.
 */
- (BOOL)parseSave:(NSError **)error;
/*!
 Saves the NSObject as a PFObject asynchronously.
 */
- (void)parseSaveInBackground;
/*!
 Saves the NSObject as a PFObject asynchronously and calls the given callback.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. error will be nil on success and set if there was an error. [result boolValue] will tell you whether the call succeeded or not.
 */
- (void)parseSaveInBackgroundWithTarget:(id)target selector:(SEL)selector;
/*!
 Saves the NSObject as a PFObject asynchronously and executes the given callback block.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error) 
 */
- (void)parseSaveInBackgroundWithBlock:(PFBooleanResultBlock)block;



/////REFRESH//////

/*!
 Refreshes the NSObject as a PFObject with the current data from the server.
 */
- (void)parseRefresh;

/*!
 Refreshes the NSObject as a PFObject with the current data from the server and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 */
- (void)parseRefresh:(NSError **)error;

/*!
 Refreshes the NSObject as a PFObject asynchronously and calls the given callback.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(PFObject *)refreshedObject error:(NSError *)error. error will be nil on success and set if there was an error. refreshedObject will be the PFObject with the refreshed data.
 */
- (void)parseRefreshInBackgroundWithTarget:(id)target selector:(SEL)selector;

/*!
 Refreshes the NSObject as a PFObject asynchronously and executes the given callback block.
 @param block The block to execute. The block should have the following argument signature: (PFObject *object, NSError *error) 
 */
- (void)parseRefreshInBackgroundWithBlock:(PFObjectResultBlock)block;


////DELETE//////

/*!
 Deletes the NSObject as a PFObject.
 @result Returns whether the delete succeeded.
 */
- (BOOL)parseDelete;   

/*!
 Deletes the NSObject as a PFObject and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns whether the delete succeeded.
 */
- (BOOL)parseDelete:(NSError **)error;

/*!
 Deletes the NSObject as a PFObject asynchronously.
 */
- (void)parseDeleteInBackground;

/*!
 Deletes the NSObject as a PFObject asynchronously and calls the given callback.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. error will be nil on success and set if there was an error. [result boolValue] will tell you whether the call succeeded or not.
 */
- (void)parseDeleteInBackgroundWithTarget:(id)target selector:(SEL)selector;

/*!
 Deletes the NSObject as a PFObject asynchronously and executes the given callback block.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error) 
 */
- (void)parseDeleteInBackgroundWithBlock:(PFBooleanResultBlock)block;


@property (nonatomic,readonly) PFObject* parseObject;
@property (nonatomic,readonly) NSString* parseObjectID;
@property (nonatomic,readonly) NSDate* updatedAt;
@property (nonatomic,readonly) NSDate* createdAt;

@end
