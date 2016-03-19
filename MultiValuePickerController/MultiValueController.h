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

@interface CCIndexPath : NSObject
@property (nonatomic, readonly) NSIndexPath *indexPath;
@property (nonatomic, readonly) NSInteger column;
- (instancetype)initWithIndexPath: (NSIndexPath *)indexPath column: (NSInteger)column;
@end

@class MultiValueController;
@protocol MultiValueControllerDelegate <NSObject>
// 选中indexPath之后的回调, hintAdd暗示可能需要添加页面
- (void)viewController: (MultiValueController *)multiController didSelectItemAtIndexPath: (CCIndexPath *)indexPath hintAddPage: (BOOL)hintAdd;
@end
@protocol MultiValueControllerDataSource <NSObject>
- (NSInteger)viewController: (MultiValueController *)multiController numberOfItemsAtColumn: (NSInteger)column;
- (NSString *)viewController: (MultiValueController *)multiController titleForColumn: (NSInteger)column;
- (NSString *)viewController: (MultiValueController *)multiController titleForIndexPath: (CCIndexPath *)indexPath;
@end

@interface MultiValueController : UIViewController
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, assign) CGFloat menuItemSpaceX;   // 中间滚动条的x间隔
@property (nonatomic, assign) CGFloat titleViewHeight;  // 标题高度
@property (nonatomic, assign) CGFloat menuViewHeight;   // 中间的菜单栏高度
@property (nonatomic, strong) UIFont  *titleFont;       // 标题的字体
@property (nonatomic, strong) UIFont  *textFont;        // 其他文本的字体
@property (nonatomic, assign) CGFloat tableViewCellHeight; //cell的高度
@property (nonatomic, assign) BOOL allowMultiSelect;    // 是否允许多选, default = NO
@property (nonatomic, weak) id <MultiValueControllerDelegate> delegate;
@property (nonatomic, weak) id <MultiValueControllerDataSource> dataSource;
// 在最后添加一个页面
- (void)addPageWithTitle: (NSString *)title; // 如果title为nil则调用dataSource的viewController:titleForColumn:
@end
