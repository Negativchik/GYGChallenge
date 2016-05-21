//
//  ReviewParser.h
//  GYGChallenge
//
//  Created by Michael Smirnov on 21.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Review;

@interface ReviewParser : NSObject

@property (nonatomic, strong, readonly) NSData *data;

- (instancetype)initWithData:(NSData *)data;
- (Review *)reviewFromDictionary:(NSDictionary *)dictionary;
- (void)parseWithCompletion:(void (^)(NSArray<Review *> *reviews, NSUInteger totalReviews))completion
		    failure:(void (^)(NSError *error))failure;

@end
