//
//  ReviewsLoader.m
//  GYGChallenge
//
//  Created by Michael Smirnov on 21.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "ReviewParser.h"
#import "ReviewsLoader.h"

@implementation ReviewsLoader

- (NSURLSessionDataTask *)load:(NSUInteger)count
			  skip:(NSUInteger)skip
			rating:(float)rating
		 sortDirection:(SortDirection)sortDirection
		     sortField:(SortField)sortField
		    completion:(void (^)(NSArray<Review *> *, NSUInteger))completion
		       failure:(void (^)(NSError *))failure {
	NSUInteger page = skip / count;

	NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];

	NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];

	NSURL *URL =
	    [NSURL URLWithString:@"https://www.getyourguide.com/berlin-l17/"
				 @"tempelhof-2-hour-airport-history-tour-berlin-airlift-more-t23776/reviews.json"];
	NSDictionary *URLParams = @{
		@"count" : [NSString stringWithFormat:@"%lu", (unsigned long)count],
		@"page" : [NSString stringWithFormat:@"%lu", (unsigned long)page],
		@"rating" : [NSString stringWithFormat:@"%f", rating],
		@"sortBy" : stringFromSortField(sortField),
		@"direction" : stringFromSortDirection(sortDirection),
	};
	URL = nsurlByAppendingQueryParameters(URL, URLParams);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
	request.HTTPMethod = @"GET";

	/* Start a new Task */
	NSURLSessionDataTask *task =
	    [session dataTaskWithRequest:request
		       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			       if (error == nil) {
				       // Success
				       ReviewParser *parser = [[ReviewParser alloc] initWithData:data];
				       [parser parseWithCompletion:completion failure:failure];
			       } else {
				       // Failure
				       failure(error);
			       }
		       }];
	[task resume];
	return task;
}

- (NSURLSessionDataTask *)loadCurrentUserReviewWithCompletion:(void (^)(Review *))completion
						      failure:(void (^)(NSError *))failure {
	// Mock response
	NSDictionary *reviewDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserReview"];
	if (reviewDictionary == nil) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			completion(nil);
		});
	}

	ReviewParser *parser = [[ReviewParser alloc] initWithData:nil];
	Review *review = [parser reviewFromDictionary:reviewDictionary];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		completion(review);
	});
	return nil;

	// Real response
	NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];

	NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];

	NSURL *URL =
	    [NSURL URLWithString:@"https://www.getyourguide.com/berlin-l17/"
				 @"tempelhof-2-hour-airport-history-tour-berlin-airlift-more-t23776/review.json"];
	NSDictionary *URLParams = @{
		@"userId" : @"CurrentUserId",
	};
	URL = nsurlByAppendingQueryParameters(URL, URLParams);
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
	request.HTTPMethod = @"GET";

	/* Start a new Task */
	NSURLSessionDataTask *task = [session
	    dataTaskWithRequest:request
	      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		      if (error == nil) {
			      // Success
			      NSUInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
			      if (statusCode == 200) {
				      NSDictionary *dataDictionary =
					  [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
				      ReviewParser *parser = [[ReviewParser alloc] initWithData:nil];
				      Review *review = [parser reviewFromDictionary:dataDictionary];
				      completion(review);
			      } else if (statusCode == 204) {// There is no Review yet
				      completion(nil);
			      } else {// Unknown status code
				      failure([NSError errorWithDomain:@"com.GYG.challenge" code:11 userInfo:nil]);
			      }
		      } else {
			      // Failure
			      failure(error);
		      }
	      }];
	[task resume];
	return task;
}

- (NSURLSessionDataTask *)createReview:(NSString *)path
				rating:(float)rating
				 title:(NSString *)title
			       message:(NSString *)message
			    completion:(void (^)(void))completion
			       failure:(void (^)(NSError *))failure {
	// Mock
	NSDictionary *serializedReview =
	    @{ @"rating" : [NSString stringWithFormat:@"%0.1f", rating],
	       @"title" : title,
	       @"message" : message };
	[[NSUserDefaults standardUserDefaults] setObject:serializedReview forKey:@"UserReview"];
    [[NSUserDefaults standardUserDefaults] synchronize];
	completion();
	return nil;

	// Real code
	NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];

	NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];

	NSString *urlString = [@"https://www.getyourguide.com" stringByAppendingPathComponent:path];
	urlString = [urlString stringByAppendingPathComponent:@"review"];
	NSURL *URL = [NSURL URLWithString:urlString];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
	request.HTTPMethod = @"POST";

	// Headers
	[request addValue:@"SomeToken" forHTTPHeaderField:@"X-Auth-Token"];
	[request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

	// JSON Body
	NSDictionary *bodyObject = @{ @"title" : @"Good", @"message" : @"Good", @"rating" : @"4.0" };
	request.HTTPBody = [NSJSONSerialization dataWithJSONObject:bodyObject options:kNilOptions error:NULL];

	/* Start a new Task */
	NSURLSessionDataTask *task =
	    [session dataTaskWithRequest:request
		       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			       if (error == nil) {
				       // Success
				       NSLog(@"URL Session Task Succeeded: HTTP %ld",
					     (long)((NSHTTPURLResponse *)response).statusCode);
			       } else {
				       // Failure
				       NSLog(@"URL Session Task Failed: %@", [error localizedDescription]);
			       }
		       }];
	[task resume];
	return task;
}

#pragma mark Helpers

static NSString *stringFromSortField(SortField sortField) {
	switch (sortField) {
	case SortFieldDateOfReview:
		return @"date_of_review";
	default:
		break;
	}
}

static NSString *stringFromSortDirection(SortDirection sortDirection) {
	switch (sortDirection) {
	case SortDirectionAscending:
		return @"ASC";
	case SortDirectionDescending:
		return @"DESC";
	default:
		break;
	}
}

static NSString *nsstringFromQueryParameters(NSDictionary *queryParameters) {
	NSMutableArray *parts = [NSMutableArray array];
	[queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
		NSString *part =
		    [NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEncodingWithAllowedCharacters:
								  [NSCharacterSet URLHostAllowedCharacterSet]],
					       [value stringByAddingPercentEncodingWithAllowedCharacters:
							  [NSCharacterSet URLHostAllowedCharacterSet]]];
		[parts addObject:part];
	}];
	return [parts componentsJoinedByString:@"&"];
}

static NSURL *nsurlByAppendingQueryParameters(NSURL *URL, NSDictionary *queryParameters) {
	NSString *URLString =
	    [NSString stringWithFormat:@"%@?%@", [URL absoluteString], nsstringFromQueryParameters(queryParameters)];
	return [NSURL URLWithString:URLString];
}

@end
