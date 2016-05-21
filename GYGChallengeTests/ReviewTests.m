//
//  Review.m
//  GYGChallenge
//
//  Created by Michael Smirnov on 22.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Review.h"

@interface ReviewTests : XCTestCase

@end

@implementation ReviewTests

- (void)testsCheckHash {
    // given
    Review *review = [[Review alloc] init];
    review.reviewID = 123280;
    review.rating = 2.0;
    review.title = @"Title string";
    review.message = @"The best!";
    review.author = @"Bernhard \u2013 Lilienthal, Germany";
    review.foregroundLanguage = YES;
    
    NSUInteger correctHash = 123280;
    
    // when
    NSUInteger hash = [review hash];
    
    // then
    XCTAssertEqual(correctHash, hash);
}

- (void)testsEqualityOfEqualReviews {
    // given
    Review *review1 = [[Review alloc] init];
    review1.reviewID = 123280;
    review1.rating = 2.0;
    review1.title = @"Title string";
    review1.message = @"The best!";
    review1.author = @"Bernhard \u2013 Lilienthal, Germany";
    review1.foregroundLanguage = YES;
    
    Review *review2 = [[Review alloc] init];
    review2.reviewID = 123280;
    review2.rating = 2.0;
    review2.title = @"Title string";
    review2.message = @"The best!";
    review2.author = @"Bernhard \u2013 Lilienthal, Germany";
    review2.foregroundLanguage = YES;
    
    // when
    BOOL isEqual = [review1 isEqual:review2];
    
    // then
    XCTAssertTrue(isEqual);
}

- (void)testsEqualityOfNonEqualReviews {
    // given
    Review *review1 = [[Review alloc] init];
    review1.reviewID = 123280;
    review1.rating = 2.0;
    review1.title = @"Title string";
    review1.message = @"The best!";
    review1.author = @"Bernhard \u2013 Lilienthal, Germany";
    review1.foregroundLanguage = YES;
    
    Review *review2 = [[Review alloc] init];
    review2.reviewID = 321312;
    review2.rating = 3.0;
    review2.title = @"Title string 2";
    review2.message = @"The best!";
    review2.author = @"Mr X";
    review2.foregroundLanguage = NO;
    
    // when
    BOOL isEqual = [review1 isEqual:review2];
    
    // then
    XCTAssertFalse(isEqual);
}

@end
