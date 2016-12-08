//
//  CarouselSubview.h
//  YHImageCarousel
//
//  Created by zyh on 2016/12/8.
//  Copyright © 2016年 zyh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarouselSubview : UIView

/**
 *  容器视图
 */
@property (nonatomic, strong) UIView *containerView;

@end

// cell基类
@interface CarouselCell : UIView

@property (nonatomic, assign) NSUInteger showTime;

@end

// image的cell派生类
@interface CarouselCellImageView : CarouselCell

@property (nonatomic, strong) UIImageView *imageView;

@end
