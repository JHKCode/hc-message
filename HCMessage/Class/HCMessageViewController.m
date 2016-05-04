//
//  HCMessageViewController.m
//  HC Message
//
//  Created by Jinhong Kim on 5/3/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import "HCMessageViewController.h"

#import "HCChatMessage.h"
#import "HCContentsInfoManager.h"


static NSString * const HCContentInfoKeyMentions  = @"mentions";
static NSString * const HCContentInfoKeyEmoticons = @"emoticons";
static NSString * const HCContentInfoKeyLinks     = @"links";


@interface HCMessageViewController ()
{
    HCContentsInfoManager *_contentsInfoManager;
}
@end


@implementation HCMessageViewController


#pragma mark - UIViewController


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self setupContentsInfoManager];
    [self setupNotification];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Setup


- (void)setupNotification
{
    // keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChangeFrameNotification:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
}


- (void)setupContentsInfoManager
{
    _contentsInfoManager = [[HCContentsInfoManager alloc] init];
}


#pragma mark - UI Action


- (IBAction)handleSendButtonTap:(id)sender
{
    NSString *text = [[_textView text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ( [text length] == 0 ) {
        return;
    }

    
    HCChatMessage *msg = [[HCChatMessage alloc] initWithText:text];
    
    [_contentsInfoManager parseMessage:msg completionHandler:^{
        NSMutableDictionary *contentInfo = [NSMutableDictionary dictionaryWithCapacity:3];
        
        if ( [[msg mentions] count] > 0 ) {
            [contentInfo setObject:[msg mentions] forKey:HCContentInfoKeyMentions];
        }
        
        if ( [[msg emoticons] count] > 0 ) {
            [contentInfo setObject:[msg emoticons] forKey:HCContentInfoKeyEmoticons];
        }
        
        if ( [[msg links] count] > 0 ) {
            [contentInfo setObject:[msg links] forKey:HCContentInfoKeyLinks];
        }

        
        if ( [contentInfo count] > 0 ) {
            NSError *error = nil;
            NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:contentInfo options:NSJSONWritingPrettyPrinted error:&error];
            
            if ( jsonData ) {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                
                if ( jsonString ) {
                    NSLog(@"json : %@", jsonString);
                }
            }
        }
    }];
    
    
    // clear text view
    [_textView setText:nil];
}


- (IBAction)handleViewTap:(id)sender
{
    [_textView resignFirstResponder];
}


#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


#pragma makr - Notification


- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect        frame    = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat       duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:0
                     animations:^{
                         [[self textInputViewBottomConstraint] setConstant:frame.size.height];
                         [[self view] layoutIfNeeded];
                     }
                     completion:nil];
}


- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGFloat       duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:0
                     animations:^{
                         [[self textInputViewBottomConstraint] setConstant:0];
                         [[self view] layoutIfNeeded];
                     }
                     completion:nil];
}


- (void)keyboardWillChangeFrameNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect        frame    = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat       duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:0
                     animations:^{
                         [[self textInputViewBottomConstraint] setConstant:frame.size.height];
                         [[self view] layoutIfNeeded];
                     }
                     completion:nil];
}


@end
