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

- (void)load:(NSUInteger)count
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

	NSURLSessionDataTask *task =
	    [session dataTaskWithRequest:request
		       completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
			       if (error == nil) {
				       ReviewParser *parser = [[ReviewParser alloc] initWithData:data];
				       [parser parseWithCompletion:completion failure:failure];
			       } else {
				       failure(error);
			       }
		       }];
	[task resume];
}

- (void)loadCurrentUserReviewWithCompletion:(void (^)(Review *))completion failure:(void (^)(NSError *))failure {
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

	NSURLSessionDataTask *task = [session
	    dataTaskWithRequest:request
	      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
		      if (error == nil) {
			      NSUInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
			      if (statusCode == 200) {
				      NSDictionary *dataDictionary =
					  [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
				      ReviewParser *parser = [[ReviewParser alloc] initWithData:data];
				      Review *review = [parser reviewFromDictionary:dataDictionary];
				      completion(review);
			      } else if (statusCode == 204) {// There is no Review yet
				      completion(nil);
			      } else {// Unknown status code
				      failure([NSError errorWithDomain:@"com.GYG.challenge" code:11 userInfo:nil]);
			      }
		      } else {
			      failure(error);
		      }
	      }];
	[task resume];
}

- (void)createReview:(NSString *)path
	      rating:(float)rating
	       title:(NSString *)title
	     message:(NSString *)message
	  completion:(void (^)(NSArray<Review *> *, NSUInteger))completion
	     failure:(void (^)(NSError *))failure {
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
