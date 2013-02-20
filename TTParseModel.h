//
//  TTParseModel.h
//  extParse
//
//  Created by Sumeru Chatterjee on 11/13/11.
//  Copyright (c) 2011 Sumeru Chatterjee. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@protocol TTParseModelSearchDelegate;
/**
 * An implementation of TTModel which is built to work with Parse.
 */
@interface TTParseModel : TTModel  
- (id)initWithQuery:(PFQuery*)query;
-(id) initAsLoadingModel ;

/**
 * Valid upon loading the Parse Model at least once. Represents the timestamp of the last time the parse model was loaded.
 */
@property (nonatomic, strong) NSDate*   loadedTime;
@property (strong,nonatomic, readonly) PFQuery* query;
@property (nonatomic, strong) NSMutableArray* objects;

@property (nonatomic, assign) NSInteger queryLimit;
@end

@interface TTParseSearchModel : TTParseModel 
- (id)initWithParseModel:(TTParseModel*)parseModel;
- (void)search:(NSString*)text;
@property (nonatomic, strong) NSArray* filteredObjects;
@property (nonatomic, weak) id<TTParseModelSearchDelegate> searchDelegate;
@end


@protocol TTParseModelSearchDelegate <NSObject>
-(BOOL)isObject:(PFObject*)object validForSearchQuery:(NSString*)query;
@end