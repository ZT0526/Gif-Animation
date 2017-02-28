//
//  ZTTestProxy.h
//  YYWebImageDemo
//
//  Created by ZT0526 on 2016/12/13.
//  Copyright © 2016年 ibireme. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZTTestProxy : NSProxy

@property(nonatomic,weak,readonly) id target;

- (instancetype)initWithTarget:(id)target;

@end
