//
//  ReviewsLoaderTests.m
//  GYGChallenge
//
//  Created by Michael Smirnov on 21.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "Review.h"
#import "ReviewsLoader.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHPathHelpers.h>
#import <XCTest/XCTest.h>

@interface ReviewsLoaderTests : XCTestCase

@end

@implementation ReviewsLoaderTests

- (void)testsLoadReviews {
	// given
	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
		return [request.URL.host isEqualToString:@"www.getyourguide.com"] &&
		       [request.URL.path isEqualToString:@"/berlin-l17/"
							 @"tempelhof-2-hour-airport-history-tour-berlin-airlift-more-"
							 @"t23776/reviews.json"];
	}
	    withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
		    NSString *path = OHPathForFileInBundle(@"ReviewsResponse", [NSBundle bundleForClass:[self class]]);
		    return [OHHTTPStubsResponse responseWithFileAtPath:path
							    statusCode:200
							       headers:@{
								       @"Content-Type" : @"text/json"
							       }];
	    }];
	XCTestExpectation *expectation = [self expectationWithDescription:@"Reviews are loaded"];
	NSUInteger correctLoaded = 5;
	NSUInteger correctTotal = 201;

	// when
	NSArray<Review *> __block *reviews;
	NSUInteger __block totalReviews;

	ReviewsLoader *loader = [[ReviewsLoader alloc] init];
	[loader load:5
	    skip:1
	    rating:0
	    sortDirection:SortDirectionDescending
	    sortField:SortFieldDateOfReview
	    completion:^(NSArray<Review *> *_reviews, NSUInteger _totalReviews) {
		    reviews = _reviews;
		    totalReviews = _totalReviews;
		    [expectation fulfill];
	    }
	    failure:^(NSError *error) {
		    [expectation fulfill];
	    }];

	// then
	[self waitForExpectationsWithTimeout:5.0
				     handler:^(NSError *_Nullable error) {
					     if (reviews == nil) {
						     XCTAssertEqual(correctLoaded, reviews.count);
						     XCTAssertEqual(correctTotal, totalReviews);
					     }

				     }];
}

- (void)testsLoadCurrentUserReviewButThereIsNoReview {
	// given
	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
		return [request.URL.host isEqualToString:@"www.getyourguide.com"] &&
		       [request.URL.path isEqualToString:@"/berlin-l17/"
							 @"tempelhof-2-hour-airport-history-tour-berlin-airlift-more-"
							 @"t23776/review.json"];
	}
	    withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
		    NSString *path = OHPathForFileInBundle(@"CurrentUserReviewResponseNoReview",
							   [NSBundle bundleForClass:[self class]]);
		    return [OHHTTPStubsResponse responseWithFileAtPath:path
							    statusCode:204
							       headers:@{
								       @"Content-Type" : @"text/json"
							       }];
	    }];
	XCTestExpectation *expectation = [self expectationWithDescription:@"Review is loaded"];

	// when
	Review __block *review;
	NSError __block *error = nil;

	ReviewsLoader *loader = [[ReviewsLoader alloc] init];
	[loader loadCurrentUserReviewWithCompletion:^(Review *_review) {
		review = _review;
		[expectation fulfill];
	}
	    failure:^(NSError *_error) {
		    error = _error;
		    [expectation fulfill];
	    }];

	// then
	[self waitForExpectationsWithTimeout:5.0
				     handler:^(NSError *_Nullable _error) {
					     XCTAssertNil(error);
					     XCTAssertNil(review);
				     }];
}

- (void)testsLoadCurrentUserReview {
	// given
	[OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *_Nonnull request) {
		return [request.URL.host isEqualToString:@"www.getyourguide.com"] &&
		       [request.URL.path isEqualToString:@"/berlin-l17/"
							 @"tempelhof-2-hour-airport-history-tour-berlin-airlift-more-"
							 @"t23776/review.json"];
	}
	    withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
		    NSString *path =
			OHPathForFileInBundle(@"CurrentUserReviewResponse", [NSBundle bundleForClass:[self class]]);
		    return [OHHTTPStubsResponse responseWithFileAtPath:path
							    statusCode:200
							       headers:@{
								       @"Content-Type" : @"text/json"
							       }];
	    }];
	XCTestExpectation *expectation = [self expectationWithDescription:@"Review is loaded"];
	Review *correctReview = [[Review alloc] init];
	correctReview.reviewID = 123280;
	correctReview.rating = 2.0;
	correctReview.title = @"Title string";
	correctReview.message = @"The best!";
	correctReview.author = @"Bernhard \u2013 Lilienthal, Germany";
	correctReview.foregroundLanguage = YES;

	// when
	Review __block *review;
	NSError __block *error;

	ReviewsLoader *loader = [[ReviewsLoader alloc] init];
	[loader loadCurrentUserReviewWithCompletion:^(Review *_review) {
		review = _review;
		[expectation fulfill];
	}
	    failure:^(NSError *_error) {
		    error = _error;
		    [expectation fulfill];
	    }];

	// then
	[self waitForExpectationsWithTimeout:5.0
				     handler:^(NSError *_Nullable _error) {
					     XCTAssertNil(error);
					     XCTAssertTrue([correctReview isEqual:review]);
				     }];
}

@end
