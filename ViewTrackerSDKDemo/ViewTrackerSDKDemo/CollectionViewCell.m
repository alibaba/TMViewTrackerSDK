//
//  CollectionViewCell.m
//  ViewTrackerSDKDemo
//
//  Created by philip on 2017/4/10.
//  Copyright © 2017年 ViewTracker. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.contentView addSubview:_imageView];
    }
    
    return self;
}
@end
