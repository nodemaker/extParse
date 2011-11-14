//
//  PFObjectAdditions.m
//  extParse
//
//  Created by Sumeru Chatterjee on 11/13/11.
//  Copyright (c) 2011 Sumeru Chatterjee. All rights reserved.
//

#import "NSObjectAdditions.h"
#import "PFObjectAdditions.h"

@implementation PFObject (PFCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
+(PFObject*) objectWithParseDictionary:(NSDictionary*)parseDictionary {
    
    NSString* className = [parseDictionary objectForKey:kParseObjectClassKey];
    
    if (!className) {
        return nil;
    }
    
    PFObject* parseObject = [PFObject objectWithClassName:className];
    
    for (NSString* key in parseDictionary) {
        if(![key isEqualToString:kParseObjectClassKey]) {
            
            id object = [parseDictionary objectForKey:key];
            [parseObject setObject:object forKey:key];
        }
    }
    
    return parseObject;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) className {
    return className;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSArray*) allKeys {
    return [data allKeys];
}

@end
