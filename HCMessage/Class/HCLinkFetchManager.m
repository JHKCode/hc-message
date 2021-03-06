//
//  HCLinkFetchManager.m
//  HCMessage
//
//  Created by Jinhong Kim on 5/4/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import "HCLinkFetchManager.h"

#import "HCLinkFetchInfo.h"


#define kHCLinkFetchingMaxCount     4
#define kHCLinkFetchRetryCount      3


NSString *taskID( NSURLSessionTask *task )
{
    return [@([task taskIdentifier]) stringValue];
}


@interface HCLinkFetchManager ()
{
    // queue
    NSMutableDictionary *_fetchingQueue;
    NSMutableArray      *_waitingQueue;
    
    // operation queue
    NSOperationQueue *_operationQueue;

    // session
    NSURLSession *_session;
    
    // title cache
    NSMutableDictionary *_titles;
}
@end


@implementation HCLinkFetchManager


- (instancetype)init
{
    self = [super init];
    
    if ( self ) {
        // create queue
        _fetchingQueue = [[NSMutableDictionary alloc] initWithCapacity:kHCLinkFetchingMaxCount];
        _waitingQueue  = [[NSMutableArray alloc] initWithCapacity:(kHCLinkFetchingMaxCount * 4)];
        
        
        // create operation queue
        _operationQueue = [[NSOperationQueue alloc] init];
        [_operationQueue setMaxConcurrentOperationCount:1];
        
        
        // create url session
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                 delegate:self
                                            delegateQueue:_operationQueue];
        
        // create cache
        _titles = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


- (void)dealloc
{
    [self cancelAll];
}


- (void)cancelAll
{
    [_operationQueue cancelAllOperations];
    [_session invalidateAndCancel];
}


#pragma mark - Fetch


- (void)fetchLink:(NSString *)link completionHandler:(HCLinkFetchResultHandler)handler
{
    if ( handler == nil ) {
        return;
    }
    
    
    // starting fetch or queueing is operated in operation queue for thread safety.
    [_operationQueue addOperationWithBlock:^{
        // check cache
        NSString *title = [_titles objectForKey:link];
        
        if ( [title length] > 0 ) {
            handler(link, title, nil);
            
            return;
        }
        
        
        HCLinkFetchInfo *linkInfo = [[HCLinkFetchInfo alloc] initWithLink:link completionHandler:handler];
        
        if ( [_fetchingQueue count] < kHCLinkFetchingMaxCount ) {
            [self startFetch:linkInfo];
        }
        else {
            [_waitingQueue addObject:linkInfo];
        }
    }];
}


- (void)startFetch:(HCLinkFetchInfo *)linkInfo
{
    // create task
    NSURLSessionDataTask *task = [_session dataTaskWithURL:[linkInfo URL]];
    
    
    // queue linkInfo
    [_fetchingQueue setObject:linkInfo forKey:taskID(task)];
    
    
    // start fetch
    [task resume];
    
    
    // increment retry count
    [linkInfo setRetryCount:([linkInfo retryCount] + 1)];
}


- (void)fetchNext
{
    HCLinkFetchInfo *linkInfo = [_waitingQueue firstObject];
    
    if ( linkInfo ) {
        [_waitingQueue removeObjectAtIndex:0];
        
        [self startFetch:linkInfo];
    }
}


#pragma mark - Task


- (void)finishTask:(NSURLSessionTask *)task
{
    [task cancel];

    
    HCLinkFetchInfo *linkInfo = [_fetchingQueue objectForKey:taskID(task)];

    if ( linkInfo == nil ) {
        return;
    }
    
    
    if ( [linkInfo completionHandler] ) {
        [linkInfo completionHandler]([linkInfo link], [linkInfo title], [linkInfo error]);
        [linkInfo setCompletionHandler:nil];
    }
    
    
    [_fetchingQueue removeObjectForKey:taskID(task)];
}


#pragma mark - NSURLSessionDelegate


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    HCLinkFetchInfo *linkInfo = [_fetchingQueue objectForKey:taskID(task)];
    
    if ( linkInfo == nil ) {
        return;
    }
    
    
    // check retry count
    if ( error ) {
        NSLog(@"%@ error, %@", [linkInfo link], error);
        
        if ( [linkInfo retryCount] >= kHCLinkFetchRetryCount ) {
            // set error
            [linkInfo setError:error];
            
            // finish task
            if ( [linkInfo isFinished] == NO ) {
                [linkInfo setFinished:YES];
                
                [self finishTask:task];
                [self fetchNext];
            }
        }
        else {
            // reset link info
            [linkInfo setData:[NSMutableData data]];
            [linkInfo setEncoding:NSASCIIStringEncoding];
            
            // remove from fetching queue
            [_fetchingQueue removeObjectForKey:taskID(task)];
            
            // retry
            [self startFetch:linkInfo];
        }
    }
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)task didReceiveData:(NSData *)data
{
    HCLinkFetchInfo *linkInfo = [_fetchingQueue objectForKey:taskID(task)];
    
    if ( linkInfo == nil ) {
        return;
    }
    
    
    if ( [data length] > 0 ) {
        [[linkInfo data] appendData:data];
        
        // creat html string
        NSString *HTMLString = [[NSString alloc] initWithData:[linkInfo data] encoding:[linkInfo encoding]];
        
        if ( [HTMLString length] == 0 ) {
            return;
        }
        
        
        // find title
        [self findTitleInHTML:HTMLString linkInfo:linkInfo];
        
        
        // perform completion if title is found or title doesn't exist.
        if ( [linkInfo isFinished] ) {
            [self finishTask:task];
            [self fetchNext];
        }
    }
}


- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)task
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    // find matching NSStringEncoding with content-type's character set in http response header
    NSString *encodingName = [response textEncodingName];
    
    if ( [encodingName length] > 0 ) {
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding( (__bridge CFStringRef)encodingName );

        if ( encoding != kCFStringEncodingInvalidId ) {
            NSStringEncoding stringEncoding = CFStringConvertEncodingToNSStringEncoding( encoding );

            if ( stringEncoding != kCFStringEncodingInvalidId ) {
                HCLinkFetchInfo *linkInfo = [_fetchingQueue objectForKey:taskID(task)];
                
                [linkInfo setEncoding:stringEncoding];
            }
        }
    }

    
    // call completion handler to continue
    if ( completionHandler ) {
        completionHandler( NSURLSessionResponseAllow );
    }
}


#pragma mark - Finding Title


/**
 @method findTitleInHTML:linkInfo:
 
 @abstract find title in HTMLString and store the title in linkInfo
 @param HTMLString the html string from the link
 @param linkInfo the fetching link information
 @discussion If <title> tag doesn't exist in <head>, mark linkInfo finished 
  since url session doesn't need to download html any more.
 */
- (void)findTitleInHTML:(NSString *)HTMLString linkInfo:(HCLinkFetchInfo *)linkInfo
{
    // create regular expression
    NSError *error = nil;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<title>(.+)</title>"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    if ( error ) {
        NSLog(@"[ERROR] creating regular expression error, %@", error);
        
        return;
    }
    
    
    // find title
    NSTextCheckingResult *result = [regex firstMatchInString:HTMLString options:0 range:NSMakeRange(0, [HTMLString length])];
    
    if ( [result numberOfRanges] < 2 ) {
        return;
    }
    
    NSRange  range  = [result rangeAtIndex:1];
    NSString *title = nil;
    
    if ( range.location != NSNotFound && range.length > 0 ) {
        title = [HTMLString substringWithRange:range];
        
        // set title
        [linkInfo setTitle:title];
        [linkInfo setFinished:YES];
        
        // set cache
        [_titles setObject:title forKey:[linkInfo link]];
        
        return;
    }
    
    
    // failed to find title, but try to find </head> or <body
    // if </head> or <body exists, there will be no title in the rest of html.
    regex = [NSRegularExpression regularExpressionWithPattern:@"</head>|<body"
                                                      options:NSRegularExpressionCaseInsensitive
                                                        error:&error];
    
    if ( error ) {
        NSLog(@"[ERROR] creating 2nd regular expression error, %@", error);
        
        return;
    }
    
    
    result = [regex firstMatchInString:HTMLString options:0 range:NSMakeRange(0, [HTMLString length])];
    range  = [result range];
    
    if ( range.location != NSNotFound && range.length > 0 ) {
        [linkInfo setFinished:YES];
        
        NSLog(@"title doesn't exist on %@", [linkInfo link]);
        
        return;
    }
}


@end
