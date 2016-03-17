//
//  MultiValueController.h
//  MultiValuePickerController
//
//  Created by cc on 16/3/17.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>

// 能够生成字符串字面量
@protocol TextRepresentable <NSObject>
- (NSString *)asText;
@end

@interface MultiValueController : UIViewController
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) CGFloat menuItemSpaceX; // 中间滚动条的x间隔
- (void)addPageWithTitle: (NSString *)title list: (NSArray *)arr; // arr的object必须继承TextRepresentable协议
@end
