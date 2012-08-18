//
//  PFObjectAdditions.h
//  extParse
//
//  Created by Sumeru Chatterjee on 11/13/11.
//  Copyright (c) 2011 Sumeru Chatterjee. All rights reserved.
//

#import <Parse/Parse.h>
#import <Foundation/Foundation.h>

@interface PFObject (PFCategory)
@property (nonatomic,readonly) NSString* className;
@property (nonatomic,readonly) NSArray* allKeys;
+(PFObject*) objectWithParseDictionary:(NSDictionary*)parseDictionary;
@end
