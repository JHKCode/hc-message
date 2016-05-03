//
//  HCMessageViewController.h
//  HC Message
//
//  Created by Jinhong Kim on 5/3/16.
//  Copyright © 2016 Jinhong Kim. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HCMessageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

// view
@property (weak, nonatomic) IBOutlet UIView *textInputView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


// contraint
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textInputViewBottomConstraint;


// method
- (IBAction)handleSendButtonTap:(id)sender;
- (IBAction)handleViewTap:(id)sender;


@end
