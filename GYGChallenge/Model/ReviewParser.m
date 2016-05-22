//
//  ReviewParser.m
//  GYGChallenge
//
//  Created by Michael Smirnov on 21.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "Review.h"
#import "ReviewParser.h"

NSString *const kReviewIdFieldName = @"review_id";
NSString *const kRatingFieldName = @"rating";
NSString *const kTitleFieldName = @"title";
NSString *const kMessageFieldName = @"message";
NSString *const kAuthorFieldName = @"author";
NSString *const kForeignLanguageFieldName = @"foreignLanguage";
NSString *const kDateFieldName = @"date";
NSString *const kDateUnformattedFieldName = @"date_unformatted";
NSString *const kLanguageCodeFieldName = @"languageCode";
NSString *const kTravelerTypeFieldName = @"traveler_type";

NSString *const kStatusFieldName = @"status";
NSString *const kTotalReviewsFieldName = @"total_reviews";
NSString *const kDataFieldName = @"data";

@interface ReviewParser ()

@property (nonatomic) dispatch_queue_t parsingQueue;

@end

@implementation ReviewParser

- (instancetype)initWithData:(NSData *)data {
	self = [super init];
	if (self == nil) {
		return nil;
	}
	_parsingQueue = dispatch_queue_create("com.GYG.reviewsParsingQueue", NULL);
	_data = data;

	return self;
}

- (void)parseWithCompletion:(void (^)(NSArray<Review *> *, NSUInteger))completion failure:(void (^)(NSError *))failure {
	dispatch_async(self.parsingQueue, ^{
		if (self.data == nil) {
			dispatch_async(dispatch_get_main_queue(), ^{
				failure([[NSError alloc] initWithDomain:@"com.GYG.challenge" code:10 userInfo:nil]);
			});
			return;
		}

		NSError *error;
		NSDictionary *dictionaryResponse =
		    [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&error];
		if (error != nil) {
			dispatch_async(dispatch_get_main_queue(), ^{
				failure([[NSError alloc] initWithDomain:@"com.GYG.challenge" code:10 userInfo:nil]);
			});
			return;
		}

		if (dictionaryResponse[kTotalReviewsFieldName] == nil) {
			dispatch_async(dispatch_get_main_queue(), ^{
				failure([[NSError alloc] initWithDomain:@"com.GYG.challenge" code:10 userInfo:nil]);
			});
			return;
		}
		NSUInteger totalCount = [dictionaryResponse[kTotalReviewsFieldName] unsignedIntegerValue];
		NSArray<NSDictionary *> *rawReviews = dictionaryResponse[kDataFieldName];
		NSMutableArray<Review *> *reviews = [NSMutableArray arrayWithCapacity:rawReviews.count];
		for (NSDictionary *reviewDic in rawReviews) {
			Review *review = [self reviewFromDictionary:reviewDic];
			[reviews addObject:review];
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			completion([reviews copy], totalCount);
		});
	});
}

- (Review *)reviewFromDictionary:(NSDictionary *)dictionary {
	Review *review = [[Review alloc] init];
	if (dictionary[kReviewIdFieldName] != nil) {
		review.reviewID = [dictionary[kReviewIdFieldName] unsignedIntegerValue];
	}
	if (dictionary[kRatingFieldName] != nil) {
		review.rating = [dictionary[kRatingFieldName] floatValue];
	}
	review.title = dictionary[kTitleFieldName];
	review.message = dictionary[kMessageFieldName];
	review.author = dictionary[kAuthorFieldName];
	if (dictionary[kForeignLanguageFieldName] != nil) {
		review.foregroundLanguage = [dictionary[kForeignLanguageFieldName] boolValue];
	}
	review.dateUnformatted = dictionary[kDateUnformattedFieldName];
	review.languageCode = dictionary[kLanguageCodeFieldName];
	review.travelerType = dictionary[kTravelerTypeFieldName];

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"MMMM d, yyyy";
	review.date = [dateFormatter dateFromString:dictionary[kDateFieldName]];
	return review;
}

@end
