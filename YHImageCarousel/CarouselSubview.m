//
//  CarouselSubview.m
//  YHImageCarousel
//
//  Created by zyh on 2016/12/8.
//  Copyright © 2016年 zyh. All rights reserved.
//

#import "CarouselSubview.h"

@implementation CarouselSubview

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.containerView];
    }
    return self;
}

- (UIView *)containerView {
    if (_containerView == nil) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(2, 0, self.bounds.size.width - 4, self.bounds.size.height)];
        _containerView.layer.cornerRadius = 5;
        _containerView.layer.masksToBounds = YES;
    }
    return _containerView;
}

@end

@implementation CarouselCell


@end


@implementation CarouselCellImageView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
    }
    return self;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    return _imageView;
}

@end


