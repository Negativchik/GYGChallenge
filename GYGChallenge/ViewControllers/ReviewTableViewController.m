//
//  ReviewTableViewController.m
//  GYGChallenge
//
//  Created by Michael Smirnov on 22.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "LoadMoreTableViewCell.h"
#import "Review.h"
#import "ReviewTableViewCell.h"
#import "ReviewTableViewController.h"
#import "ReviewsLoader.h"

@interface ReviewTableViewController ()

@property (nonatomic, strong) NSMutableArray<Review *> *reviews;
@property (nonatomic, strong) ReviewsLoader *loader;
@property (nonatomic) NSUInteger totalCount;// Number of review items on server
@property (nonatomic) BOOL loading;

@end

@implementation ReviewTableViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = 85.0;

	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];

	self.loader = [[ReviewsLoader alloc] init];

	[self refresh];
}

#pragma mark <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.reviews.count == 0 || self.reviews.count == self.totalCount) {
		return self.reviews.count;
	} else {
		return self.reviews.count + 1;// Add 1 to show 'Load More' cell
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row > self.reviews.count - 1) {// Show 'Load More' cell
		LoadMoreTableViewCell *cell =
		    [tableView dequeueReusableCellWithIdentifier:@"LoadMoreCell" forIndexPath:indexPath];
		if (self.loading) {
			[cell.activityIndicator startAnimating];
		} else {
			[cell.activityIndicator stopAnimating];
		}
		return cell;
	} else {
		Review *review = self.reviews[indexPath.row];

		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		dateFormatter.dateStyle = NSDateFormatterShortStyle;

		ReviewTableViewCell *cell =
		    [tableView dequeueReusableCellWithIdentifier:@"ReviewCell" forIndexPath:indexPath];
		cell.dateLabel.text = [dateFormatter stringFromDate:review.date];
		cell.titleLabel.text = review.title;
		cell.authorLabel.text = review.author;
		cell.messageLabel.text = review.message;
		cell.starRatingView.value = review.rating;
		return cell;
	}
}

#pragma mark <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (self.loading) {
		return;
	}
	if (indexPath.row > self.reviews.count - 1) {
		[self loadMore];
		LoadMoreTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		[cell.activityIndicator startAnimating];
	}
}

#pragma mark -

- (void)refresh {
	self.loading = YES;
	[self.loader load:10
	    skip:0
	    rating:0
	    sortDirection:SortDirectionDescending
	    sortField:SortFieldDateOfReview
	    completion:^(NSArray<Review *> *reviews, NSUInteger totalReviews) {
		    self.reviews = [reviews mutableCopy];
		    self.totalCount = totalReviews;
		    [self.tableView reloadData];
		    [self.refreshControl endRefreshing];
		    self.loading = NO;
	    }
	    failure:^(NSError *error) {
		    [self.refreshControl endRefreshing];
		    self.loading = NO;
            [self handleError: error];
	    }];
}

- (void)loadMore {
	self.loading = YES;
	[self.loader load:10
	    skip:self.reviews.count
	    rating:0
	    sortDirection:SortDirectionDescending
	    sortField:SortFieldDateOfReview
	    completion:^(NSArray<Review *> *reviews, NSUInteger totalReviews) {
		    [self.reviews addObjectsFromArray:reviews];
		    self.totalCount = totalReviews;
		    [self.tableView reloadData];
		    [self.refreshControl endRefreshing];
		    self.loading = NO;
	    }
	    failure:^(NSError *error) {
		    [self.refreshControl endRefreshing];
            self.loading = NO;
            [self handleError: error];
	    }];
}

- (void)handleError: (NSError *)error {
    if (error.localizedDescription) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:error.localizedDescription message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
