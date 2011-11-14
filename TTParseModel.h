//
//  TTParseModel.h
//  extParse
//
//  Created by Sumeru Chatterjee on 11/13/11.
//  Copyright (c) 2011 Sumeru Chatterjee. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

/**
 * An implementation of TTModel which is built to work with Parse.
 */
@interface TTParseModel : TTModel  {
    
    NSDate* _loadedTime;
    PFQuery* _query;
    NSArray* _objects;
    BOOL _isLoading;
}

-(id) initWithQuery:(PFQuery*)query;
/**
 * Valid upon loading the Parse Model at least once. Represents the timestamp of the last time the parse model was loaded.
 */
@property (nonatomic, retain) NSDate*   loadedTime;
@property (nonatomic, readonly) PFQuery* query;
@property (nonatomic, retain) NSArray* objects;
@end
