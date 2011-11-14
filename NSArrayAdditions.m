//
//  NSArrayAdditions.m
//  UsherMoney
//
//  Created by Sumeru Chatterjee on 11/12/11.
//  Copyright (c) 2011 Sumeru Chatterjee. All rights reserved.
//

#import "NSArrayAdditions.h"
#import "NSObjectAdditions.h"
#import "PFObjectAdditions.h"
#import "NSDictionaryAdditions.h"
#import <objc/runtime.h>

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSArray (PFCategory)

///////////////////////////////////////////////////////////////////////////////////////////////////
+(NSArray*) arrayWithParseObjectArray:(NSArray*)parseObjectArray {
    
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:parseObjectArray.count];
    for (id object in parseObjectArray) {
        
        if ([object isEqual:kNullValue]) {
            continue;
        }
        
        if([object isKindOfClass:[NSArray class]]||
           [object isKindOfClass:[NSMutableArray class]]) {
             
            [array addObject:[NSArray arrayWithParseObjectArray:object]];
        } else if(([object isKindOfClass:[NSDictionary class]]||
                   [object isKindOfClass:[NSMutableDictionary class]])&&
                  ([(NSDictionary*)object objectForKey:kParseObjectClassKey])) {
            
            PFObject* parseObject = [PFObject objectWithParseDictionary:object];
            [array addObject:[NSObject objectFromParseObject:parseObject]];
        } else if([object isKindOfClass:[NSDictionary class]]||
                  [object isKindOfClass:[NSMutableDictionary class]]) {
            
            [array addObject:[NSDictionary dictionaryWithParseObjectDictionary:object]];
        } else if([object isKindOfClass:[PFObject class]]){
            
            [array addObject:[NSObject objectFromParseObject:object]];
        } else {
            
            [array addObject:object];
        }
    }
    return [NSArray arrayWithArray:array];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSArray*) parseSerializableArray {
    
    NSMutableArray* serializableArray = [NSMutableArray arrayWithCapacity:self.count];
    for (NSObject* object in self) {
        
        if ([object isKindOfClass:[NSArray class]]||
            [object isKindOfClass:[NSMutableArray class]]) {
            
            [serializableArray addObject:[(NSArray*)object parseSerializableArray]];
        } else if  ([object isKindOfClass:[NSDictionary class]]||
                    [object isKindOfClass:[NSMutableDictionary class]]) {
            
            [serializableArray addObject:[(NSDictionary*)object parseSerializableDictionary]];
        } else if  ([object isParseSerializable]) {
            
            [serializableArray addObject:object];
        } else {
            
            NSMutableDictionary* objectDictionary = (NSMutableDictionary*)[object parseSerializableDictionary];
            [objectDictionary setObject:NSStringFromClass([object class]) forKey:kParseObjectClassKey];
            [serializableArray addObject:objectDictionary]; 
        }
    }
    return serializableArray;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)parseSaveAll:(NSError **)error {
    
    //To be implemented
    return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseSaveAllInBackground {
    
    //To be implemented
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseSaveAllInBackgroundwithTarget:(id)target selector:(SEL)selector {
    
    //To be implemented
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseSaveAllInBackgroundwithBlock:(PFBooleanResultBlock)block {
    
    //To be implemented
}

@end
