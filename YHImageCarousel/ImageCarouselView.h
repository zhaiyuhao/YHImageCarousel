//
//  ImageCarouselView.h
//  YHImageCarousel
//
//  Created by zyh on 2016/12/8.
//  Copyright © 2016年 zyh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CarouselSubview.h"

@protocol ImageCarouselViewDataSource;
@protocol ImageCarouselViewDelegate;

@interface ImageCarouselView : UIView
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, assign) id <ImageCarouselViewDataSource> dataSource;
@property (nonatomic, assign) id <ImageCarouselViewDelegate>   delegate;

- (instancetype)initWithFrame:(CGRect)frame withDataSource:(id<ImageCarouselViewDataSource>)dataSource withDelegate:(id<ImageCarouselViewDelegate>)delegate;

/**
 *  刷新视图
 */
- (void)reloadData;

@end


@protocol  ImageCarouselViewDelegate <NSObject>

- (CGSize)sizeForPageInCarouselView:(ImageCarouselView *)carouselView;

@optional

- (void)carouselView:(ImageCarouselView *)carouselView didScrollToPage:(NSInteger)pageNumber;

- (void)carouselView:(ImageCarouselView *)carouselView didSelectPageAtIndex:(NSInteger)index;

@end


@protocol ImageCarouselViewDataSource <NSObject>

- (NSInteger)numberOfPagesInCarouselView:(ImageCarouselView *)carouselView;

- (CarouselCell *)carouselView:(ImageCarouselView *)carouselView cellForPageAtIndex:(NSUInteger)index;

@end

