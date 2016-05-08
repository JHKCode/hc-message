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

#import "HCMessageTableViewCell.h"


@interface HCMessageViewController ()
{
    // contents manager
    HCContentsInfoManager *_contentsInfoManager;
    
    // message model
    NSMutableArray *_messages;
    
    // cached attributed strings
    NSMutableDictionary *_messageAttrStrings;
    
    // attributes for message
    NSDictionary *_messageAttributes;
    
    // attributes for json contents
    NSDictionary *_contentsAttributes;
}
@end


@implementation HCMessageViewController


#pragma mark - UIViewController


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_messages removeAllObjects];
    [_messageAttrStrings removeAllObjects];

    _messages = nil;
    _messageAttrStrings  = nil;
    _contentsInfoManager = nil;
    _messageAttributes   = nil;
    _contentsAttributes  = nil;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self setupMessages];
    [self setupContentsInfoManager];
    [self setupNotification];
    [self setupTableView];
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


- (void)setupMessages
{
    _messages = [[NSMutableArray alloc] init];
    _messageAttrStrings = [[NSMutableDictionary alloc] init];
}


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


- (void)setupTableView
{
    UINib *msgNib = [UINib nibWithNibName:HCMessageCellID bundle:[NSBundle mainBundle]];
    
    [_tableView registerNib:msgNib forCellReuseIdentifier:HCMessageCellID];
    
    
    _messageAttributes  = [HCMessageTableViewCell messageAttribute];
    _contentsAttributes = [HCMessageTableViewCell contentsAttribute];
}


#pragma mark - UI Action


- (IBAction)handleSendButtonTap:(id)sender
{
    NSString *text = [[_textView text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ( [text length] == 0 ) {
        return;
    }

    
    // add message model
    HCChatMessage *msg = [[HCChatMessage alloc] initWithText:text];
    
    [_messages insertObject:msg atIndex:0];
    
    
    // add to ui
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [_tableView insertRowsAtIndexPaths:@[indexPath]
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    
    
    // parse message
    __weak HCMessageViewController *weakSelf = self;
    
    [_contentsInfoManager parseMessage:msg completionHandler:^{
        if ( weakSelf == nil ) {
            return;
        }


        // update message
        [msg setParsed:YES];
        

        // notify message updated
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf notifyMessageDidUpdate:msg];
        });
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
    return [_messages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HCMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HCMessageCellID];

    
    // set max width
    CGFloat maxWidth = [tableView bounds].size.width - kHCMessageLabelLeftMargin - kHCMessageLabelRightMargin;
    
    [[cell messageLabel] setPreferredMaxLayoutWidth:maxWidth];
    
    
    // set text
    NSAttributedString *attrString = [self attrStringAtIndexPath:indexPath];

    [[cell messageLabel] setAttributedText:attrString];
    
    
    // set background color
    HCChatMessage *message = [_messages objectAtIndex:[indexPath row]];
    UIColor       *color   = nil;
    
    if ( [message parsed] ) {
        if ( [message hasLinkFetchError] ) {
            color = [UIColor redColor];
        }
        else {
            color = [UIColor whiteColor];
        }
    }
    else {
        color = [UIColor lightGrayColor];
    }
    
    [[cell contentView] setBackgroundColor:color];
    
    
    return cell;
}


#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAttributedString *attrString = [self attrStringAtIndexPath:indexPath];
    
    
    // calculate row height
    CGFloat maxWidth = [tableView bounds].size.width - kHCMessageLabelLeftMargin - kHCMessageLabelRightMargin;
    
    CGRect rect = [attrString boundingRectWithSize:CGSizeMake(maxWidth, 10000)
                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                           context:nil];
    
    
    return ceilf(rect.size.height + kHCMessageLabelTopMargin + kHCMessageLabelBottomMargin);
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


#pragma mark - Message


- (NSAttributedString *)attrStringAtIndexPath:(NSIndexPath *)indexPath
{
    // find or generate attributed string
    HCChatMessage *message = [_messages objectAtIndex:[indexPath row]];
    NSMutableAttributedString *attrString = [_messageAttrStrings objectForKey:[message messageID]];
    
    
    // check cache
    if ( [attrString length] == 0 ) {
        // create message string
        attrString = [[NSMutableAttributedString alloc] initWithString:[message text] attributes:_messageAttributes];

        
        // append json contents if parsing completed.
        if ( [message parsed] ) {
            NSString *contents = [message JSONContents];
            
            if ( [contents length] > 0 ) {
                NSAttributedString *contentsString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\n%@", contents]
                                                                                     attributes:_contentsAttributes];
                [attrString appendAttributedString:contentsString];
            }
        }
        
        
        // cache attributed string
        [_messageAttrStrings setObject:attrString forKey:[message messageID]];
    }
    
    
    return attrString;
}


- (void)notifyMessageDidUpdate:(HCChatMessage *)message
{
    NSString *msgID = [message messageID];
    NSArray  *indexPaths = [_tableView indexPathsForVisibleRows];
    
    
    // clear cache
    [_messageAttrStrings removeObjectForKey:msgID];
    
    
    // find & update cell
    for ( NSIndexPath *indexPath in indexPaths ) {
        HCChatMessage *visibleMessage = [_messages objectAtIndex:[indexPath row]];
        
        if ( [msgID isEqualToString:[visibleMessage messageID]] ) {
            [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
    }
}


@end
