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
        return YES;
	}
	    withStubResponse:^OHHTTPStubsResponse *_Nonnull(NSURLRequest *_Nonnull request) {
		    NSString *path = OHPathForFileInBundle(@"Response", [NSBundle bundleForClass:[self class]]);
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
	    failure:^(NSError *returnedError) {
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

@end
