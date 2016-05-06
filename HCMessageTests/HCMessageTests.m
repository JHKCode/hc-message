//
//  HCMessageTests.m
//  HCMessageTests
//
//  Created by Jinhong Kim on 5/3/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "HCEmoticon.h"
#import "HCChatMessage.h"
#import "HCContentsInfoManager.h"


@interface HCMessageTests : XCTestCase
{
    HCContentsInfoManager *_contentsManager;
}
@end


@implementation HCMessageTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    _contentsManager = [[HCContentsInfoManager alloc] init];
}


- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    _contentsManager = nil;
}


- (void)testMention
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    
    NSString *jinhong  = @"jinhong";
    NSString *koala    = @"koala";
    NSString *kangaroo = @"kangaroo";
    NSArray  *names    = @[jinhong, koala, kangaroo];
    
    NSString      *text    = [NSString stringWithFormat:@"Hello, @%@, @%@, @%@", jinhong, koala, kangaroo];
    HCChatMessage *message = [[HCChatMessage alloc] initWithText:text];
    
    [_contentsManager parseMessage:message completionHandler:^{
        NSArray *mentions  = [message mentions];
        NSArray *emoticons = [message emoticons];
        NSArray *links     = [message links];
        
        XCTAssert(([mentions count] == [names count]), @"number of mention sholud be %d", (int)[names count]);
        XCTAssert(([emoticons count] == 0), @"number of emoticons sholud be 0");
        XCTAssert(([links count] == 0), @"number of links sholud be 0");

        XCTAssert([names isEqual:mentions], @"mentions has different name");
        
        dispatch_semaphore_signal(sema);
    }];
    
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}


- (void)testEmoticon
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    
    NSString *santa   = @"santa";
    NSString *pumpkin = @"pumpkin";
    NSString *beer    = @"beer";
    NSArray  *icons   = @[santa, pumpkin, beer];
    
    NSString      *text    = [NSString stringWithFormat:@"Hello, (%@), (%@), (%@)", santa, pumpkin, beer];
    HCChatMessage *message = [[HCChatMessage alloc] initWithText:text];
    
    [_contentsManager parseMessage:message completionHandler:^{
        NSArray *mentions  = [message mentions];
        NSArray *emoticons = [message emoticons];
        NSArray *links     = [message links];
        
        XCTAssert(([mentions count] == 0), @"number of mention sholud be 0");
        XCTAssert(([emoticons count] == [icons count]), @"number of emoticons sholud be %d", (int)[icons count]);
        XCTAssert(([links count] == 0), @"number of links sholud be 0");
        
        XCTAssert([icons isEqual:emoticons], @"emoticons has different icon");
        
        dispatch_semaphore_signal(sema);
    }];
    
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}


- (void)testLink
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    
    NSString *link  = @"jhkcode.blogspot.kr";
    NSString *title = @"Hello World!";
    
    NSString      *text    = [NSString stringWithFormat:@"Hello, %@", link];
    HCChatMessage *message = [[HCChatMessage alloc] initWithText:text];
    
    [_contentsManager parseMessage:message completionHandler:^{
        NSArray *mentions  = [message mentions];
        NSArray *emoticons = [message emoticons];
        NSArray *links     = [message links];
        
        XCTAssert(([mentions count] == 0), @"number of mention sholud be 0");
        XCTAssert(([emoticons count] == 0), @"number of emoticons sholud be 0");
        XCTAssert(([links count] == 1), @"number of links sholud be 1");
        

        NSString *linkTitle = [[links firstObject] objectForKey:HCContentInfoLinkKeyTitle];
        NSString *linkURL   = [[links firstObject] objectForKey:HCContentInfoLinkKeyURL];
        
        XCTAssert([linkURL isEqualToString:link], @"link sholud be %@", link);
        XCTAssert([linkTitle isEqualToString:title], @"title sholud be %@", title);
        
        dispatch_semaphore_signal(sema);
    }];
    
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}


- (void)testAll
{
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    
    // mention
    NSString *sydney = @"sydney";
    
    
    // emoticon
    NSString *heart = @"heart";
    
    
    // link
    NSString *link  = @"jhkcode.blogspot.kr";
    NSString *title = @"Hello World!";
    
    
    // create message
    NSString      *text    = [NSString stringWithFormat:@"Hello, @%@, (%@), %@", sydney, heart, link];
    HCChatMessage *message = [[HCChatMessage alloc] initWithText:text];
    
    
    // parse message
    [_contentsManager parseMessage:message completionHandler:^{
        // check mentions
        NSArray *mentions  = [message mentions];
        
        XCTAssert(([mentions count] == 1), @"number of mention sholud be 1");
        XCTAssert([sydney isEqual:[mentions firstObject]], @"mentions has different name");
        
        
        // check emoticons
        NSArray *emoticons = [message emoticons];

        XCTAssert(([emoticons count] == 1), @"number of emoticons sholud be 1");
        XCTAssert([heart isEqual:[emoticons firstObject]], @"emoticons has different name");
        
        
        // check links
        NSArray *links      = [message links];
        NSString *linkTitle = [[links firstObject] objectForKey:HCContentInfoLinkKeyTitle];
        NSString *linkURL   = [[links firstObject] objectForKey:HCContentInfoLinkKeyURL];

        XCTAssert(([links count] == 1), @"number of links sholud be 1");
        XCTAssert([linkURL isEqualToString:link], @"link sholud be %@", link);
        XCTAssert([linkTitle isEqualToString:title], @"title sholud be %@", title);
        
        dispatch_semaphore_signal(sema);
    }];
    
    
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}


@end
