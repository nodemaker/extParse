//
//  TTParseModel.m
//  extParse
//
//  Created by Sumeru Chatterjee on 11/13/11.
//  Copyright (c) 2011 Sumeru Chatterjee. All rights reserved.
//

#import "TTParseModel.h"

const NSInteger kQueryLimit = 40;

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTParseModel {
    BOOL _isLoading;
    BOOL _alwaysLoading;
    BOOL _alwaysError;
}

@synthesize loadedTime  = _loadedTime;
@synthesize query = _query;
@synthesize objects = _objects;

///////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init {
    if(self = [super init]){
        _alwaysLoading = NO;
        _alwaysError = NO;
        _objects = nil;
        _loadedTime = nil;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(id) initWithQuery:(PFQuery*)query {
    if(self=[self init]) {
        _query = query;
        _query.cachePolicy  = kPFCachePolicyNetworkElseCache;
        _query.limit = kQueryLimit;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setQueryLimit:(NSInteger)queryLimit{
    _query.limit = queryLimit;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)queryLimit{
    return _query.limit;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(id) initAsLoadingModel {
    
    if(self=[super init]) {
        _alwaysLoading = YES;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(id) initAsErrorModel {
    if(self=[super init]) {
        _alwaysError = YES;
    }
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModel


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
    if(_alwaysLoading){
        return NO;
    }
    
    return !!_loadedTime;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
    if(_alwaysLoading){
        return YES;
    }
    
    return _isLoading;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
 
    if(_alwaysError){
        NSError* error = [NSError errorWithDomain:NSCocoaErrorDomain code:5000 userInfo:nil];
        _loadedTime = [NSDate date];
        _isLoading = NO;
        [self didFailLoadWithError:error];
    }
    
    if(_alwaysLoading||!self.query){
        return;
    }
    
    [self.query findObjectsInBackgroundWithTarget:self selector:@selector(callbackWithResult:error:)];
    _isLoading = YES;
    [self didStartLoad];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
    //To be implemented
    [self didCancelLoad];
}
    
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Parse CallBackSelector

///////////////////////////////////////////////////////////////////////////////////////////////////
-(void)callbackWithResult:(NSArray*)result error:(NSError*)error {         
   
    _isLoading = NO;
    if (error) {
        [self didFailLoadWithError:error]; 
        return;
    } 
    
    _loadedTime = [NSDate date];    
    _objects = [NSMutableArray arrayWithArray:result];
    
    [self didFinishLoad];     
}

@end

@implementation TTParseSearchModel{
    __strong TTParseModel* _parseModel;
}
@synthesize filteredObjects = _filteredObjects;
@synthesize searchDelegate = _searchDelegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithParseModel:(TTParseModel*)parseModel{
    if(self=[super init]) {
        
        _parseModel = parseModel;
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)search:(NSString*)text{
    
    _filteredObjects = nil;
    if (text.length) {
        NSMutableArray* filteredObjects = [NSMutableArray array];
        for(PFObject* object in _parseModel.objects){
            if([self.searchDelegate respondsToSelector:@selector(isObject:validForSearchQuery:)]){
                if([self.searchDelegate isObject:object validForSearchQuery:text]){
                    [filteredObjects addObject:object];
                }
            }
        }
        _filteredObjects = [[NSArray alloc] initWithArray:filteredObjects];
        [self didFinishLoad];
    } else {
        _filteredObjects = [[NSArray alloc] init];
        [self didChange];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
    return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
    return NO;
}


@end
