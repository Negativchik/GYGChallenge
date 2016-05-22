//
//  WriteReviewTableViewController.m
//  GYGChallenge
//
//  Created by Michael Smirnov on 22.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "HCSStarRatingView.h"
#import "WriteReviewTableViewController.h"
#import <UITextView_Placeholder/UITextView+Placeholder.h>

@interface WriteReviewTableViewController ()

@end

@implementation WriteReviewTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.messageTextView.placeholder = @"Review";
}

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

#pragma mark <UITableViewDelegate>

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	switch (indexPath.row) {
//	case 2:
//		return tableView.frame.size.height / 2;
//	default:
//		return 44;
//	}
//	return 0;
//}

#pragma mark Actions

- (IBAction)cancel:(id)sender {
	[self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)done:(id)sender {
	[self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)changeRating:(HCSStarRatingView *)sender {
}

@end
