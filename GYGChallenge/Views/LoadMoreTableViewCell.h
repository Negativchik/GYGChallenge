//
//  LoadMoreTableViewCell.h
//  GYGChallenge
//
//  Created by Michael Smirnov on 22.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadMoreTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *loadMoreLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
