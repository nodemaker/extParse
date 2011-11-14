//
//  NSObjectAdditions.m
//  extParse
//
//  Created by Sumeru Chatterjee on 11/12/11.
//  Copyright (c) 2011 Sumeru Chatterjee. All rights reserved.
//

#import <Parse/Parse.h>
#import <objc/runtime.h>

#import "TTParseErrorCodes.h"

#import "PFObjectAdditions.h"
#import "NSObjectAdditions.h"
#import "NSArrayAdditions.h"
#import "NSDictionaryAdditions.h"
#import "NSString+Trimming.h"

char* const kParseObjectKey = "_parseObject";
NSString* const kParseObjectClassKey = @"object_class";
NSString* const kNullValue = @"(null)";

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface NSObject ()
@property (nonatomic,retain) PFObject* parseObject;
@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation NSObject (PFCategory)

@dynamic parseObjectID;
@dynamic updatedAt;
@dynamic createdAt;

///////////////////////////////////////////////////////////////////////////////////////////////////
+(NSObject*) objectFromParseObject:(PFObject*)parseObject {
    
    
    
    
    const char* className = [[parseObject className] cStringUsingEncoding:NSASCIIStringEncoding];
    if(!objc_lookUpClass(className)) {
        
        //TODO Raise Exception
        return nil;
    }
    //TODO assert that object is of type NSObject
    
    Class parseObjectClass = NSClassFromString([parseObject className]);
    NSObject* object =[[parseObjectClass alloc] init];
    
    for (NSString* key in [parseObject allKeys]) {
        
        id value = [parseObject objectForKey:key];
        if ([value isEqual:kNullValue]) {
            continue;
        }
        
        @try {
            
            if ([value isKindOfClass:[NSArray class]]||
                [value isKindOfClass:[NSMutableArray class]]) {
                
                [object setValue:[NSArray arrayWithParseObjectArray:(NSArray*)value] forKey:key];
            }  else if(([value isKindOfClass:[NSDictionary class]]||
                        [value isKindOfClass:[NSMutableDictionary class]])&&
                       ([(NSDictionary*)value objectForKey:kParseObjectClassKey])) {
                
                PFObject* parseObject = [PFObject objectWithParseDictionary:value];
                NSObject* newObject = [NSObject objectFromParseObject:parseObject];
                
                if(newObject) {
                    [object setValue:newObject forKey:key];
                } else {
                    [object setValue:[NSDictionary dictionaryWithParseObjectDictionary:value] forKey:key];
                }
                
            }  else if([value isKindOfClass:[NSDictionary class]]||
                       [value isKindOfClass:[NSMutableDictionary class]]) {
                
                [object setValue:[NSDictionary dictionaryWithParseObjectDictionary:(NSDictionary*)value] forKey:key];
            }  else if([value isKindOfClass:[PFObject class]]){
                
                [object setValue:[NSObject objectFromParseObject:value] forKey:key];
            } else {
                
                [object setValue:value forKey:key];
            }
        }
        @catch (NSException* exception) {
            NSLog(@"extParse_Exception:%@",[exception reason]);
        }
        @finally {
            continue;
        }
    }
    
    object.parseObject = parseObject;
    return [object autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark-
#pragma Public Methods

///////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL) isParseSerializable {
    
    return ([self isKindOfClass:[NSData class]]||
            [self isKindOfClass:[NSMutableData class]]||
            [self isKindOfClass:[NSNumber class]]||
            [self isKindOfClass:[NSMutableString class]]||
            [self isKindOfClass:[NSString class]]||
            [self isKindOfClass:[NSDate class]]); 
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSDictionary*) parseSerializableDictionary {
    
    unsigned int varCount;
    Ivar *vars = class_copyIvarList([self class],&varCount);
    NSMutableDictionary* serializableDictionary = [NSMutableDictionary dictionaryWithCapacity:varCount];
    
    //loop through all the ivars in the Object and add them to ParseObject
    for (int i=0;i<varCount; i++) {
		Ivar var = vars[i];
      
        //Parse does not like leading underscores or other bullshit characters
        //hence remove them 
        NSString* iVarName = [[NSString stringWithCString:ivar_getName(var) encoding:NSASCIIStringEncoding]
                              stringByTrimmingLeadingCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]];
        
        id iVarObject = [self valueForKey:iVarName];   
        
        if (iVarObject) {
            
            if ([iVarObject isKindOfClass:[NSArray class]]||
                [iVarObject isKindOfClass:[NSMutableArray class]]) {
                
                [serializableDictionary setObject:[iVarObject parseSerializableArray] forKey:iVarName];
            } else if([iVarObject isKindOfClass:[NSDictionary class]]||
                      [iVarObject isKindOfClass:[NSMutableDictionary class]]) {
                
                [serializableDictionary setObject:[iVarObject parseSerializableDictionary] forKey:iVarName];
            } else if  ([iVarObject isParseSerializable]) {
                
                [serializableDictionary setObject:iVarObject forKey:iVarName];
            } else {
                NSMutableDictionary* objectDictionary = (NSMutableDictionary*)[iVarObject parseSerializableDictionary];
                [objectDictionary setObject:NSStringFromClass([iVarObject class]) forKey:kParseObjectClassKey];
                [serializableDictionary setObject:objectDictionary forKey:iVarName];    
            }
                
        } else {
            [serializableDictionary setObject:kNullValue forKey:iVarName];
        }
    } 
    
    return serializableDictionary;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void) syncParseObject {
    
    if([self isParseSerializable]) {
        return;
    }
    
    //lazy initialization and sync
    if (!self.parseObject) {
        self.parseObject = [[PFObject alloc] initWithClassName:NSStringFromClass([self class])];
    }
    
    //Todo delete all keys in the parseobject
    NSDictionary* serializableDictionary = [self parseSerializableDictionary];
    for (NSString* key in serializableDictionary) {
        NSObject* object = [serializableDictionary objectForKey:key];
        [self.parseObject setObject:object forKey:key];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (PFObject*) parseObject {
    
    if([self isParseSerializable]) {
        return nil;
    }
    
    PFObject* parseObject = objc_getAssociatedObject(self,(void*)kParseObjectKey);
    return parseObject;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void) setParseObject:(PFObject *)parseObject {
    
    if([self isParseSerializable]) {
        return;
    }
    
    objc_setAssociatedObject(self,(void*)kParseObjectKey,parseObject,OBJC_ASSOCIATION_RETAIN_NONATOMIC);    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) parseObjectID {
    
    return [self.parseObject objectId];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSDate*) createdAt {
    
    return [self.parseObject createdAt];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSDate*) updatedAt {
    
    return [self.parseObject updatedAt];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark-
#pragma Save Methods

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)parseSave {
    
    if([self isParseSerializable]) {
        return NO;
    }
    
    [self syncParseObject];
    return [self.parseObject save]; 
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)parseSave:(NSError **)error {
    
    if([self isParseSerializable]) {
        
        NSString* description = @"NextStep objects which are json serialable cannot be saved to parse directly";
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey]; 
        *error = [NSError errorWithDomain:kTTExtParseErrorDomain 
                                             code:kTTExtParseErrorCodeInvalidObject
                                         userInfo:userInfo];
        return NO;
    }
    
    [self syncParseObject];
    return [self.parseObject save:error];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseSaveInBackground {
    
    if([self isParseSerializable]) {
        return;
    }
    
    [self syncParseObject];
    [self.parseObject saveInBackground];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseSaveInBackgroundWithTarget:(id)target selector:(SEL)selector {
    
    if([self isParseSerializable]) {
        return;
    }
    
    [self syncParseObject];
    [self.parseObject saveInBackgroundWithTarget:target selector:selector];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseSaveInBackgroundWithBlock:(PFBooleanResultBlock)block {
    
    
    if([self isParseSerializable]) {
        return;
    }
    
    
    [self syncParseObject];
    [self.parseObject saveInBackgroundWithBlock:block];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark-
#pragma Refresh Methods

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseRefresh {
    
    if([self isParseSerializable]) {
        return;
    }
    
    [self syncParseObject];
    return [self.parseObject refresh];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseRefresh:(NSError **)error {
    
    if([self isParseSerializable]) {
        
        NSString* description = @"NextStep objects which are json serialable cannot be saved to parse directly";
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey]; 
        *error = [NSError errorWithDomain:kTTExtParseErrorDomain 
                                     code:kTTExtParseErrorCodeInvalidObject
                                 userInfo:userInfo];
        return;
    }
    
    [self syncParseObject];
    [self.parseObject refresh:error];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseRefreshInBackgroundWithTarget:(id)target selector:(SEL)selector {
    
    if([self isParseSerializable]) {
        return;
    }
    
    [self syncParseObject];
    [self.parseObject refreshInBackgroundWithTarget:target selector:selector];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseRefreshInBackgroundWithBlock:(PFObjectResultBlock)block {
    
    if([self isParseSerializable]) {
        return;
    }
    
    [self syncParseObject];
    [self.parseObject refreshInBackgroundWithBlock:block];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark-
#pragma Delete Methods


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)parseDelete{ 
    
    if([self isParseSerializable]) {
        return NO;
    }
    
    [self syncParseObject];
    return [self.parseObject delete];
}    

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)parseDelete:(NSError **)error {
    
    if([self isParseSerializable]) {
        
        NSString* description = @"NextStep objects which are json serialable cannot be saved to parse directly";
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:description forKey:NSLocalizedDescriptionKey]; 
        *error = [NSError errorWithDomain:kTTExtParseErrorDomain 
                                     code:kTTExtParseErrorCodeInvalidObject
                                 userInfo:userInfo];
        return NO;
    }
    
    [self syncParseObject];
    return [self.parseObject delete:error];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseDeleteInBackground {
    
    if([self isParseSerializable]) {
        return;
    }
    
    [self syncParseObject];
    return [self.parseObject deleteInBackground];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseDeleteInBackgroundWithTarget:(id)target selector:(SEL)selector {
    
    if([self isParseSerializable]) {
        return;
    }
    
    [self syncParseObject];
    return [self.parseObject deleteInBackgroundWithTarget:target selector:selector];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)parseDeleteInBackgroundWithBlock:(PFBooleanResultBlock)block {
    
    if([self isParseSerializable]) {
        return;
    }
    
    [self syncParseObject];
    return [self.parseObject deleteInBackgroundWithBlock:block];
}


@end
