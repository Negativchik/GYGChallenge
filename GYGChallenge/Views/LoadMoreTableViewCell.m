//
//  LoadMoreTableViewCell.m
//  GYGChallenge
//
//  Created by Michael Smirnov on 22.05.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "LoadMoreTableViewCell.h"

@implementation LoadMoreTableViewCell

- (void)awakeFromNib {
	[super awakeFromNib];

	[self.activityIndicator addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
		      ofObject:(id)object
			change:(NSDictionary<NSString *, id> *)change
		       context:(void *)context {
	if (object == self.activityIndicator) {
		self.loadMoreLabel.hidden = !self.activityIndicator.hidden;
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end
