//
//  ImageCarouselView.m
//  YHImageCarousel
//
//  Created by zyh on 2016/12/8.
//  Copyright © 2016年 zyh. All rights reserved.
//

#import "ImageCarouselView.h"

@interface ImageCarouselView ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, strong) NSMutableArray *containerViews;
@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) NSInteger pageCount;

@end

@implementation ImageCarouselView

#pragma mark - Override Methods

- (instancetype)initWithFrame:(CGRect)frame withDataSource:(id<ImageCarouselViewDataSource>)dataSource withDelegate:(id<ImageCarouselViewDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self)
    {
        _dataSource = dataSource;
        _delegate = delegate;
        [self initialize];
        [self setupUI];
        [self startScroll];
    }
    return self;
}

#pragma mark - Private Methods

- (void)initialize{
    self.clipsToBounds = YES;
    self.pageSize = self.bounds.size;
    _currentPageIndex = 0;
    self.containerViews = [NSMutableArray array];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    /*由于UIScrollView在滚动之后会调用自己的layoutSubviews以及父View的layoutSubviews
     这里为了避免scrollview滚动带来自己layoutSubviews的调用,所以给scrollView加了一层父View
     */
    UIView *superViewOfScrollView = [[UIView alloc] initWithFrame:self.bounds];
    [superViewOfScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [superViewOfScrollView setBackgroundColor:[UIColor clearColor]];
    [superViewOfScrollView addSubview:self.scrollView];
    [self addSubview:superViewOfScrollView];
}

- (void)setupUI {
    if (_dataSource && [_dataSource respondsToSelector:@selector(numberOfPagesInCarouselView:)]) {
        // 轮播图片总页数
        self.pageCount = [_dataSource numberOfPagesInCarouselView:self];
        // 如果总页数为0，return
        if (self.pageCount == 0) {
            return;
        }
    }
    
    [self stopScroll];
    
    // 重置pageWidth
    if (_delegate && [_delegate respondsToSelector:@selector(sizeForPageInCarouselView:)]) {
        _pageSize = [_delegate sizeForPageInCarouselView:self];
    }
    
    // 重置_scrollView的contentSize
    _scrollView.frame = CGRectMake((self.bounds.size.width - _pageSize.width) / 2, 0, _pageSize.width, _pageSize.height);
    _scrollView.contentSize = CGSizeMake(_pageSize.width * 5, _pageSize.height);
    
    // 创建5个CarouselSubview容器
    // 先清空再创建
    for (CarouselSubview *subview in _scrollView.subviews) {
        [subview removeFromSuperview];
    }
    [_containerViews removeAllObjects];
    for (NSInteger i = 0; i < 5; i++) {
        CarouselSubview *containerView = [[CarouselSubview alloc] initWithFrame:CGRectMake(i * _pageSize.width, 0, _pageSize.width, _pageSize.height)];
        [containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleCellTapAction:)]];
        containerView.tag = i + 10;
        [_containerViews addObject:containerView];
        [_scrollView addSubview:containerView];
        // 添加containerView中的子控件
        if ([self.dataSource respondsToSelector:@selector(carouselView:cellForPageAtIndex:)]) {
            CarouselCell *cell = [self.dataSource carouselView:self cellForPageAtIndex:(_pageCount + (_currentPageIndex + i - 2)) % _pageCount];
            cell.frame = containerView.bounds;
            [containerView.containerView addSubview:cell];
        }
    }
    // 滚动到中间的containerView
    _scrollView.contentOffset = CGPointMake(_pageSize.width * 2, 0);
}

//点击了cell
- (void)singleCellTapAction:(UIGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(carouselView:didSelectPageAtIndex:)]) {
        NSInteger tag = gesture.view.tag;
        if (tag - 10 - 2 < 0) {
            [self.delegate carouselView:self didSelectPageAtIndex:((_currentPageIndex - 1) + _pageCount) % _pageCount];
        } else if (tag - 10 - 2 > 0 ) {
            [self.delegate carouselView:self didSelectPageAtIndex:(_currentPageIndex + 1) % _pageCount];
        } else {
            [self.delegate carouselView:self didSelectPageAtIndex:_currentPageIndex];
        }
    }
}

- (void)startScroll {
    CarouselSubview *middleContainerView = _containerViews[2];
    for (CarouselCell *cell in middleContainerView.containerView.subviews) {
        [self startScrollWithShowTime:cell.showTime];
    }
}

- (void)startScrollWithShowTime:(NSUInteger)showTime {
    if (self.pageCount > 1 && self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:showTime target:self selector:@selector(autoNextPage) userInfo:nil repeats:YES];
    }
}

- (void)stopScroll {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - 自动轮播

- (void)autoNextPage {
    [self.scrollView setContentOffset:CGPointMake(3 * self.pageSize.width, 0) animated:YES];
}

#pragma mark - ImageCarouselView API

- (void)reloadData {
    [self setupUI];
}

#pragma mark - hitTest

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        CGPoint newPoint = [_scrollView convertPoint:point fromView:self];
        for (CarouselSubview *subView in _scrollView.subviews) {
            if (CGRectContainsPoint(subView.frame, newPoint)) {
                CGPoint newSubViewPoint = [subView convertPoint:point fromView:self];
                return [subView hitTest:newSubViewPoint withEvent:event];
            }
        }
    }
    return nil;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.scrollView) {
        if (self.pageCount == 0) {
            return;
        }
        
        // 向手指向右滑动一个单位,需要删除最后的一个cell，前面添加一个cell
        if (_scrollView.contentOffset.x <= _pageSize.width) {
            [self stopScroll];
            // 删除第最后一个cell
            [(CarouselSubview *)_containerViews.lastObject removeFromSuperview];
            [_containerViews removeLastObject];
            // 将剩下的cell都向右移动一个cell宽度的位置
            for (NSInteger i = 0; i < _containerViews.count; i++) {
                CarouselSubview *containerView = _containerViews[i];
                containerView.frame = CGRectMake((i + 1) * _pageSize.width, 0, _pageSize.width, _pageSize.height);
                containerView.tag = i + 1 + 10;
            }
            // 创建一个新的cell放在最前面
            CarouselSubview *containerView = [[CarouselSubview alloc] initWithFrame:CGRectMake(0 * _pageSize.width, 0, _pageSize.width, _pageSize.height)];
            [containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleCellTapAction:)]];
            containerView.tag = 0 + 10;
            [_containerViews insertObject:containerView atIndex:0];
            [_scrollView addSubview:containerView];
            // 这里使用 _currentPageIndex - 1 - 2 是因为 此时 _currentPageIndex 还未更新为最新的，_currentPageIndex - 1 为最新的位置，之前的第二个位置添加
            CarouselCell *cell = [self.dataSource carouselView:self cellForPageAtIndex:(_pageCount + (_currentPageIndex - 1 - 2)) % _pageCount];
            cell.frame = containerView.bounds;
            [containerView.containerView addSubview:cell];
            // 重新至中
            _scrollView.contentOffset = CGPointMake(_pageSize.width * 2, 0);
            if ([_delegate respondsToSelector:@selector(carouselView:didScrollToPage:)]) {
                _currentPageIndex = ((_currentPageIndex - 1) + _pageCount) % _pageCount;
                [_delegate carouselView:self didScrollToPage:_currentPageIndex];
            }
            [self startScroll];
        }
        
        // 手指向左滑动一个单位，需要删除最前面的一个cell，最后添加一个cell
        if (_scrollView.contentOffset.x >= _pageSize.width * 3) {
            [self stopScroll];
            // 删除第一个cell
            [(CarouselSubview *)_containerViews[0] removeFromSuperview];
            [_containerViews removeObjectAtIndex:0];
            // 将剩下的cell都向左移动一个cell宽度的位置
            for (NSInteger i = 0; i < _containerViews.count; i++) {
                CarouselSubview *containerView = _containerViews[i];
                containerView.frame = CGRectMake(i * _pageSize.width, 0, _pageSize.width, _pageSize.height);
                containerView.tag = i + 10;
            }
            // 创建一个新的cell放在最后面
            CarouselSubview *containerView = [[CarouselSubview alloc] initWithFrame:CGRectMake(4 * _pageSize.width, 0, _pageSize.width, _pageSize.height)];
            [containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleCellTapAction:)]];
            containerView.tag = 4 + 10;
            [_containerViews addObject:containerView];
            [_scrollView addSubview:containerView];
            // 这里使用 _currentPageIndex + 1 + 2 是因为 此时 _currentPageIndex 还未更新为最新的，_currentPageIndex + 1 为最新的位置，之后的第二个位置添加
            CarouselCell *cell = [self.dataSource carouselView:self cellForPageAtIndex:(_currentPageIndex + 1 + 2) % _pageCount];
            cell.frame = containerView.bounds;
            [containerView.containerView addSubview:cell];
            // 重新至中
            _scrollView.contentOffset = CGPointMake(_pageSize.width * 2, 0);
            if ([_delegate respondsToSelector:@selector(carouselView:didScrollToPage:)]) {
                _currentPageIndex = (_currentPageIndex + 1) % _pageCount;
                [_delegate carouselView:self didScrollToPage:_currentPageIndex];
            }
            [self startScroll];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        [self stopScroll];
    }
}

@end


