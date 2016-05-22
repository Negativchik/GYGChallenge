//
//  WriteReviewTableViewController.m
//  GYGChallenge
//
//  Created by Michael Smirnov on 22.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "HCSStarRatingView.h"
#import "Review.h"
#import "ReviewsLoader.h"
#import "WriteReviewTableViewController.h"
#import <UITextView_Placeholder/UITextView+Placeholder.h>

@interface WriteReviewTableViewController ()

@property (nonatomic, strong) ReviewsLoader *loader;
@property (nonatomic, strong) UIAlertController *loadingAlertController;

@end

@implementation WriteReviewTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.messageTextView.placeholder = @"Review";

	_loader = [[ReviewsLoader alloc] init];
	[self.loader loadCurrentUserReviewWithCompletion:^(Review *review) {
		self.review = review;
        [self fillTableView];
		if (self.loadingAlertController != nil) {
			[self.loadingAlertController dismissViewControllerAnimated:YES completion:nil];
		}
	}
	    failure:^(NSError *error){
		// TODO: Show error alert
	    }];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self fillTableView];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (self.review == nil) {
		self.loadingAlertController = [UIAlertController alertControllerWithTitle:@"Wait a second please"
										  message:nil
									   preferredStyle:UIAlertControllerStyleAlert];
		[self presentViewController:self.loadingAlertController animated:YES completion:nil];
	}
}

- (void)fillTableView {
	if (self.review != nil) {
		self.starsView.value = self.review.rating;
		self.titleTextField.text = self.review.title;
		self.messageTextView.text = self.review.message;
    } else {
        self.starsView.value = 0;
        self.titleTextField.text = @"";
        self.messageTextView.text = @"";
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
	if (self.self.starsView.value == 0) {// User did not change rating
		[self dismissViewControllerAnimated:true completion:nil];
		return;
	}

	[self.loader createReview:@"path_to_guide"
	    rating:self.starsView.value
	    title:self.titleTextField.text
	    message:self.messageTextView.text
	    completion:^{
		    [self dismissViewControllerAnimated:true completion:nil];
	    }
	    failure:^(NSError *error) {
		    [self handleError:error];
	    }];
}

- (void)handleError:(NSError *)error {
	if (error.localizedDescription) {
		UIAlertController *alertController =
		    [UIAlertController alertControllerWithTitle:error.localizedDescription
							message:nil
						 preferredStyle:UIAlertControllerStyleAlert];
		[alertController addAction:[UIAlertAction actionWithTitle:@"Ok"
								    style:UIAlertActionStyleCancel
								  handler:^(UIAlertAction *_Nonnull action) {
									  [alertController
									      dismissViewControllerAnimated:YES
												 completion:nil];
								  }]];
		[self presentViewController:alertController animated:YES completion:nil];
	}
}

@end
