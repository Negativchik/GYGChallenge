//
//  WriteReviewTableViewController.m
//  GYGChallenge
//
//  Created by Michael Smirnov on 22.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "HCSStarRatingView.h"
#import "Review.h"
#import "WriteReviewTableViewController.h"
#import <UITextView_Placeholder/UITextView+Placeholder.h>

@interface WriteReviewTableViewController ()

@end

@implementation WriteReviewTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.messageTextView.placeholder = @"Review";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (self.review == nil) {
		self.review = [[Review alloc] init];
	} else {
		self.starsView.value = self.review.rating;
		self.titleTextField.text = self.review.title;
		self.messageTextView.text = self.review.message;
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (self.review == nil) {
		UIAlertController *alertController =
		    [UIAlertController alertControllerWithTitle:@"Wait a second please"
							message:nil
						 preferredStyle:UIAlertControllerStyleAlert];
		[alertController.view addSubview:[[UIActivityIndicatorView alloc]
						     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
		[self presentViewController:alertController animated:YES completion:nil];
	}
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

#pragma mark Actions

- (IBAction)cancel:(id)sender {
	[self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)done:(id)sender {
	[self dismissViewControllerAnimated:true completion:nil];
}

@end
