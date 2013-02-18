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
@implementation TTParseModel

@synthesize loadedTime  = _loadedTime;
@synthesize query = _query;
@synthesize objects = _objects;

///////////////////////////////////////////////////////////////////////////////////////////////////
-(id) initWithQuery:(PFQuery*)query {
    
    if(self=[super init]) {
        _query = [query retain];
        _query.cachePolicy  = kPFCachePolicyNetworkElseCache;
        _query.limit = kQueryLimit;
        _alwaysLoading = NO;
        _objects = nil;
        _loadedTime = nil;
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
- (void)dealloc {
    
    TT_RELEASE_SAFELY(_objects);
    TT_RELEASE_SAFELY(_loadedTime);
    TT_RELEASE_SAFELY(_query);
    
    [super dealloc];
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
 
    if(_alwaysLoading){
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
    
    TT_RELEASE_SAFELY(_loadedTime);
    _loadedTime = [[NSDate date] retain];    
    
    TT_RELEASE_SAFELY(_objects);
    _objects = [[NSMutableArray arrayWithArray:result] retain];
    
    [self didFinishLoad];     
}

@end

@implementation TTParseSearchModel
@synthesize filteredObjects = _filteredObjects;
@synthesize searchDelegate = _searchDelegate;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithParseModel:(TTParseModel*)parseModel{
    if(self=[super init]) {
        
        _parseModel = [parseModel retain];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    
    TT_RELEASE_SAFELY(_filteredObjects);
    TT_RELEASE_SAFELY(_parseModel);
    
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)search:(NSString*)text{
    
    TT_RELEASE_SAFELY(_filteredObjects);
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
