//
//  ViewController.m
//  HC Message
//
//  Created by Jinhong Kim on 5/3/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupAppDescTextView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupAppDescTextView
{
    NSMutableString *text = [NSMutableString string];
    
    [text appendString:@"1. You can start to test message that can contain mentions or emoticons or links by tapping below button \"Go Message Test\""];
    [text appendString:@"\n\n"];
    
    [text appendString:@"2. If you input text and tap send button, the text will be displayed on list at top of the view with GRAY background color"];
    [text appendString:@"\n\n"];
    
    [text appendString:@"3. When extracting contents information from text finish, the contents information will be displayed below the text in JSON format with WHITE background color"];
    [text appendString:@"\n\n"];
    
    [text appendString:@"4. If there is a link and fetching a title from link failed, the contents information will be displayed below the text in JSON format with RED background color"];
    [text appendString:@"\n\n"];
    
    [text appendString:@"5. When fetching a title failed, it will retry 2 more times to fetch title"];
    [text appendString:@"\n\n"];

    [text appendString:@"6. If a link has been fetched and title of the link exists, it will use cached title information"];
    [text appendString:@"\n\n"];

    [text appendString:@"7. Emoticons which user input are only valid if it is included on the site, https://www.hipchat.com/emoticons"];
    
    [_appDescTextView setText:text];
}


@end
