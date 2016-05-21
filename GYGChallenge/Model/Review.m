//
//  Review.m
//  GYGChallenge
//
//  Created by Michael Smirnov on 21.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "Review.h"

@implementation Review

- (NSUInteger)hash {
	return self.reviewID;
}

- (BOOL)isEqual:(id)object {
	if (![object isMemberOfClass:[Review class]]) {
		return NO;
	}
	if ([(Review *)object reviewID] == self.reviewID) {
		return YES;
	}
	return NO;
}

@end
