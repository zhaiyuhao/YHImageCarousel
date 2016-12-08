//
//  CarouselCellInfo.h
//  YHImageCarousel
//
//  Created by zyh on 2016/12/8.
//  Copyright © 2016年 zyh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarouselCellInfo : NSObject

@property (nonatomic, assign) NSUInteger showTime;

@property (nonatomic, strong) NSString *imageName;

+ (instancetype)cellInfoWithDict:(NSDictionary *)dict;

@end
