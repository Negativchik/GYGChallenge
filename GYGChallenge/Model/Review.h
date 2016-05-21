//
//  Review.h
//  GYGChallenge
//
//  Created by Michael Smirnov on 21.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Review : NSObject

@property (nonatomic) NSUInteger reviewID;
@property (nonatomic) float rating;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *author;
@property (nonatomic) BOOL foregroundLanguage;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDictionary *dateUnformatted;
@property (nonatomic, strong) NSString *languageCode;
@property (nonatomic, strong) NSString *travelerType;

@end
