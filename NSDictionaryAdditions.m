//
//  NSDictionaryAdditions.m
//  extParse
//
//  Created by Sumeru Chatterjee on 11/13/11.
//  Copyright (c) 2011 Sumeru Chatterjee. All rights reserved.
//

#import "NSObjectAdditions.h"
#import "NSArrayAdditions.h"
#import "PFObjectAdditions.h"
#import "NSDictionaryAdditions.h"

@implementation NSDictionary (PFCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
+(NSDictionary*) dictionaryWithParseObjectDictionary:(NSDictionary*)parseObjectDictionary {
    
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithCapacity:parseObjectDictionary.count];
    
    for (NSString* key in parseObjectDictionary) {
        
        id object = [parseObjectDictionary objectForKey:key];
        if ([object isEqual:kNullValue]) {
            continue;
        }
        
        if([object isKindOfClass:[NSArray class]]||
           [object isKindOfClass:[NSMutableArray class]]) {
            
            [dictionary setObject:[NSArray arrayWithParseObjectArray:object] forKey:key];
        } else if(([object isKindOfClass:[NSDictionary class]]||
                   [object isKindOfClass:[NSMutableDictionary class]])&&
                  ([(NSDictionary*)object objectForKey:kParseObjectClassKey])) {
            
            PFObject* parseObject = [PFObject objectWithParseDictionary:object];
            [dictionary setObject:[NSObject objectFromParseObject:parseObject] forKey:key];
            
        } else if([object isKindOfClass:[NSDictionary class]]||
                  [object isKindOfClass:[NSMutableDictionary class]]) {
            
            [dictionary setObject:[NSDictionary dictionaryWithParseObjectDictionary:object] forKey:key];
        } else if([object isKindOfClass:[PFObject class]]){
            
            [dictionary setObject:[NSObject objectFromParseObject:object] forKey:key];
        } else {
            
            [dictionary setObject:[NSObject objectFromParseObject:object] forKey:key];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}


//////////////////////////////////////////////////////////////////////////////////////////////////
-(NSDictionary*) parseSerializableDictionary {
    NSMutableDictionary* serializableDictionary = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    for (NSString* key in self) {
        
        NSObject* object = [self objectForKey:key];
        
        if ([object isKindOfClass:[NSArray class]]||
            [object isKindOfClass:[NSMutableArray class]]) {
            
            [serializableDictionary setObject:[(NSArray*)object parseSerializableArray] forKey:key];
        } else if([object isKindOfClass:[NSDictionary class]]||
                  [object isKindOfClass:[NSMutableDictionary class]]) {
            
            [serializableDictionary setObject:[object parseSerializableDictionary] forKey:key];
        } else if  ([object isParseSerializable]) {
            
            [serializableDictionary setObject:object forKey:key];
        } else {
            
            NSMutableDictionary* objectDictionary = (NSMutableDictionary*)[object parseSerializableDictionary];
            [objectDictionary setObject:NSStringFromClass([object class]) forKey:kParseObjectClassKey];
            [serializableDictionary setObject:objectDictionary forKey:key];    
        }
    }
    return serializableDictionary;
}

@end
