//
//  ReviewsLoader.h
//  GYGChallenge
//
//  Created by Michael Smirnov on 21.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Review;

typedef enum : NSUInteger {
	SortDirectionAscending,
	SortDirectionDescending,
} SortDirection;

typedef enum : NSUInteger {
	SortFieldDateOfReview,
} SortField;

@interface ReviewsLoader : NSObject

- (void)load:(NSUInteger)count
	     skip:(NSUInteger)skip
	   rating:(float)rating
    sortDirection:(SortDirection)sortDirection
	sortField:(SortField)sortField
       completion:(void (^)(NSArray<Review *> *reviews, NSUInteger totalReviews))completion
	  failure:(void (^)(NSError *returnedError))failure;

@end
