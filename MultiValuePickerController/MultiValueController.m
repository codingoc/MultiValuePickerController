//
//  MultiValueController.m
//  MultiValuePickerController
//
//  Created by cc on 16/3/17.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "MultiValueController.h"

static CGFloat screenW() {
    return [UIScreen mainScreen].bounds.size.width;
}
static CGFloat screenH() {
    return [UIScreen mainScreen].bounds.size.height;
}

@interface UIView (Frame)
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@end
@implementation UIView(Frame)
- (CGFloat)x{
    return self.frame.origin.x;
}
- (void)setX:(CGFloat)x {
    CGRect old = self.frame;
    self.frame = CGRectMake(x, old.origin.y, old.size.width, old.size.height);
}
- (CGFloat)y {
    return self.frame.origin.y;
}
- (void)setY:(CGFloat)y {
    CGRect old = self.frame;
    self.frame = CGRectMake(old.origin.x, y, old.size.width, old.size.height);
}
- (CGFloat)centerX {
    return self.x + self.width*0.5;
}
- (void)setCenterX:(CGFloat)centerX {
    self.frame = CGRectMake(centerX-0.5*self.width, self.y, self.width, self.height);
}
- (CGFloat)centerY {
    return self.y + self.height*0.5;
}
- (void)setCenterY:(CGFloat)centerY {
    self.frame = CGRectMake(self.x, centerY-0.5*self.height, self.width, self.height);
}
- (CGFloat)width {
    return self.frame.size.width;
}
- (void)setWidth:(CGFloat)width {
    CGRect old = self.frame;
    self.frame = CGRectMake(old.origin.x, old.origin.y, width, old.size.height);
}
- (CGFloat)height {
    return self.frame.size.height;
}
- (void)setHeight:(CGFloat)height {
    CGRect old = self.frame;
    self.frame = CGRectMake(old.origin.x, old.origin.y, old.size.width, height);
}

@end

@interface MultiValueController () <UITableViewDataSource, UITableViewDelegate> {
    NSBundle *_bundle;
    NSMutableArray *_menuItemViews; // <UILabel *>
    NSMutableArray *_pageViews;     // <UITableView *>
    NSMutableArray *_pageValues;    // <NSArray *>
}
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, retain) NSBundle *bundle;
@property (nonatomic, weak) UIScrollView *menuView; // 中间的菜单条
@property (nonatomic, weak) UIScrollView *pageContainerView; // 页面
@end

@implementation MultiValueController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _bundle = [NSBundle bundleForClass:[self class]];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    
    [self setUpTitleView];
    [self setUpHorizontalMenu];
    [self setUpPageContainerView];
}

- (void)setUpTitleView {
    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(0, 0.5*screenH(), screenW(), 0.5*screenH())];
    cv.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cv];
    self.containerView = cv;
    UIView *tv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cv.width, 44.0f)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = self.title;
    titleLabel.textColor = [UIColor grayColor];
    [tv addSubview:titleLabel];
    [titleLabel sizeToFit];
    titleLabel.centerX = tv.width*0.5;
    titleLabel.centerY = tv.height*0.5;
    //
    UIButton *dismissBtn = [[UIButton alloc] initWithFrame:CGRectMake(tv.width-44, 0, 44, 44)];
    [dismissBtn setImage:[UIImage imageNamed:@"close_64px" inBundle:self.bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [dismissBtn addTarget:self action:@selector(onColoseBtn:) forControlEvents:UIControlEventTouchUpInside];
    [tv addSubview:dismissBtn];
    [self.containerView addSubview:tv];
}

- (void)setUpHorizontalMenu {
    UIScrollView *menu = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, screenW(), 44)];
    [self.containerView addSubview:menu];
    self.menuView = menu;
}

- (void)setUpPageContainerView {
    UIScrollView *pageContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 88, screenW(), self.containerView.height-88)];
    pageContainer.pagingEnabled = YES;
    [self.containerView addSubview:pageContainer];
    self.pageContainerView = pageContainer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onColoseBtn: (UIButton *)sender {
    
}

- (void)addPageWithTitle:(NSString *)title list:(NSArray *)arr {
    // 现将数据插入pageValues
    if (!_pageValues) {
        _pageValues = [[NSMutableArray alloc] init];
    }
    [_pageValues addObject:arr];
    // 添加menuItem
    CGFloat offsetX = 0;
    if (_menuItemViews.count) {
        offsetX = ((UIView *)_menuItemViews.lastObject).x + ((UIView *)_menuItemViews.lastObject).width + self.menuItemSpaceX;
    }else {
        offsetX = self.menuItemSpaceX;
    }
    UILabel *menuItemView = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, 0, 44, 44)];
    menuItemView.text = title;
    [self.menuView addSubview:menuItemView];
    [menuItemView sizeToFit];
    if (!_menuItemViews) {
        _menuItemViews = [[NSMutableArray alloc] init];
    }
    [_menuItemViews addObject:menuItemView];
    // 计算menuView的contentsize
    self.menuView.contentSize = CGSizeMake(offsetX+menuItemView.width, 44);
    // 添加page
    offsetX = screenW() * _pageViews.count;
    UITableView *pageView = [[UITableView alloc] initWithFrame:CGRectMake(offsetX, 0, screenW(), self.pageContainerView.height) style:UITableViewStylePlain];
    pageView.dataSource = self;
    pageView.delegate = self;
    [self.pageContainerView addSubview:pageView];
    if (!_pageViews) {
        _pageViews = [[NSMutableArray alloc] init];
    }
    [_pageViews addObject:pageView];
    // 计算pageContainerView的contentsize
    self.pageContainerView.contentSize = CGSizeMake(_pageViews.count*screenW(), self.pageContainerView.height);
}

// MARK: TableView DataSource && Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger index = [_pageViews indexOfObject:tableView];
    NSArray *pageValue = _pageValues[index];
    return pageValue.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    NSUInteger index = [_pageViews indexOfObject:tableView];
    NSArray *pageValue = _pageValues[index];
    id <TextRepresentable> value = pageValue[indexPath.row];
    cell.textLabel.text = [value asText];
    return cell;
}

@end
