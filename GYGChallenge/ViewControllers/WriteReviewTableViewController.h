//
//  WriteReviewTableViewController.h
//  GYGChallenge
//
//  Created by Michael Smirnov on 22.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCSStarRatingView;
@class Review;

@interface WriteReviewTableViewController : UITableViewController

@property (nonatomic, strong) Review *review;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *starsView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@end
