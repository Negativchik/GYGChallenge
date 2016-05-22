//
//  ReviewParserTest.m
//  GYGChallenge
//
//  Created by Michael Smirnov on 21.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "Review.h"
#import "ReviewParser.h"
#import <XCTest/XCTest.h>

@interface ReviewParserTests : XCTestCase

@end

@implementation ReviewParserTests

- (void)testInitializationWithData {
	// given
	NSData *data = [[NSData alloc] initWithContentsOfFile:@"Response"];

	// when
	ReviewParser *parser = [[ReviewParser alloc] initWithData:data];

	// then
	XCTAssertEqual(parser.data, data);
}

- (void)testParseResponseWithCorrectData {
	// given
	NSString *path = [[NSBundle bundleForClass:[self class]] resourcePath];
	NSData *data = [[NSData alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:@"Response"]];
	XCTestExpectation *expectation = [self expectationWithDescription:@"Parsing is finished"];
	NSUInteger correctArrayLength = 5;
	NSUInteger correctTotalCount = 201;

	// when
	NSArray __block *parsedArray;
	NSUInteger __block totalCount;
	ReviewParser *parser = [[ReviewParser alloc] initWithData:data];
	[parser parseWithCompletion:^(NSArray<Review *> *reviews, NSUInteger totalReviews) {
		[expectation fulfill];
		parsedArray = reviews;
		totalCount = totalReviews;
	}
	    failure:^(NSError *error) {
		    XCTFail(@"Error during correct data parsing: %@", error);
		    [expectation fulfill];
	    }];

	// then
	[self waitForExpectationsWithTimeout:10.0
				     handler:^(NSError *_Nullable error) {
					     XCTAssertEqual(correctArrayLength, parsedArray.count);
					     XCTAssertEqual(correctTotalCount, totalCount);
				     }];
}

- (void)testParseResponseWithWrongData {
	// given
	NSData *data = [@"Some wrong data" dataUsingEncoding:NSUTF8StringEncoding];
	XCTestExpectation *expectation = [self expectationWithDescription:@"Parsing is finished"];
	NSError *correctError = [[NSError alloc] initWithDomain:@"com.GYG.challenge" code:10 userInfo:nil];

	// when
	NSError __block *error;
	ReviewParser *parser = [[ReviewParser alloc] initWithData:data];
	[parser parseWithCompletion:^(NSArray<Review *> *reviews, NSUInteger totalReviews) {
		[expectation fulfill];
	}
	    failure:^(NSError *returnedError) {
		    error = returnedError;
		    [expectation fulfill];
	    }];

	// then
	[self waitForExpectationsWithTimeout:3.0
				     handler:^(NSError *_Nullable error) {
					     if (error == nil) {
						     XCTAssert(@"Should return error");
					     } else {
						     XCTAssertEqual(error, correctError);
					     }
				     }];
}

- (void)testParseObjectFromDictionary {
	// given
	NSDictionary *dictionary = @{
		@"review_id" : @123280,
		@"rating" : @"2.0",
		@"title" : @"Title string",
		@"message" : @"The best!",
		@"author" : @"Bernhard \u2013 Lilienthal, Germany",
		@"foreignLanguage" : @YES,
		@"date" : @"June 3, 2014",
		@"date_unformatted" : @{},
		@"languageCode" : @"de",
		@"traveler_type" : @"couple"
	};
	Review *correctReview = [[Review alloc] init];
	correctReview.reviewID = 123280;
	correctReview.rating = 2.0;
	correctReview.title = @"Title string";
	correctReview.message = @"The best!";
	correctReview.author = @"Bernhard \u2013 Lilienthal, Germany";
	correctReview.foregroundLanguage = YES;

    NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	dateComponents.year = 2014;
	dateComponents.month = 6;
	dateComponents.day = 3;
    correctReview.date = [calendar dateFromComponents:dateComponents];

	correctReview.dateUnformatted = @{};
	correctReview.languageCode = @"de";
	correctReview.travelerType = @"couple";

	// when
	ReviewParser *parser = [[ReviewParser alloc] init];
	Review *review = [parser reviewFromDictionary:dictionary];

	// then
	XCTAssertEqual(correctReview.reviewID, review.reviewID);
	XCTAssertEqual(correctReview.rating, review.rating);
	XCTAssertEqual(correctReview.title, review.title);
	XCTAssertEqual(correctReview.message, review.message);
	XCTAssertEqual(correctReview.author, review.author);
	XCTAssertEqual(correctReview.foregroundLanguage, review.foregroundLanguage);
	XCTAssertTrue([correctReview.date isEqual:review.date]);
	XCTAssertEqual(correctReview.dateUnformatted, review.dateUnformatted);
	XCTAssertEqual(correctReview.languageCode, review.languageCode);
	XCTAssertEqual(correctReview.travelerType, review.travelerType);
}

@end
