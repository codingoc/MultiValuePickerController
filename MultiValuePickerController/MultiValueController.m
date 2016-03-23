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

@implementation CCIndexPath
- (instancetype)initWithIndexPath:(NSIndexPath *)indexPath column:(NSInteger)column {
    if (self = [super init]) {
        _column = column;
        _indexPath = indexPath;
    }
    return self;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"path:%@ | column:%ld", _indexPath, _column];
}
- (BOOL)isEqual:(id)object {
    if (object) {
        CCIndexPath *path = (CCIndexPath *)object;
        return (path.column == self.column) && ![self.indexPath compare:path.indexPath];
    }
    return NO;
}
@end

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

@interface CheckMarkCell : UITableViewCell
@property (nonatomic, weak) UIImageView *checkMark;
@end
@implementation CheckMarkCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImage *checkImage = [UIImage imageNamed:@"check_mark_24px" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
        checkImage = [checkImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *check = [[UIImageView alloc] initWithImage:checkImage];
        check.frame = CGRectMake(0, 0, 17, 12);
        [self addSubview:check];
        check.hidden = YES;
        _checkMark = check;
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        NSDictionary *attributes = @{NSFontAttributeName: self.textLabel.font};
        CGSize size = [self.textLabel.text sizeWithAttributes:attributes];
        self.checkMark.x = self.textLabel.x + size.width + 10.0f;
        self.checkMark.centerY = 0.5*self.height;
        self.checkMark.tintColor = self.textLabel.highlightedTextColor;
        self.checkMark.hidden = NO;
    }else {
        self.checkMark.hidden = YES;
    }
}
@end

@interface MultiValueController () <UITableViewDataSource, UITableViewDelegate> {
    NSBundle *_bundle;
    NSMutableArray *_menuItemViews; // <UILabel *>
    NSMutableArray *_pageViews;     // <UITableView *>
    NSMutableArray *_selectedIndexPath; // <CCIndexPath *>
}
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, retain) NSBundle *bundle;
@property (nonatomic, weak) UIView *titleView;  // 标题
@property (nonatomic, weak) UIScrollView *menuView; // 中间的菜单条
@property (nonatomic, weak) UIScrollView *pageContainerView; // 页面
@property (nonatomic, weak) UIView *indicateLine;   // 菜单上的指示条
@property (nonatomic, readonly) NSInteger currentPageIndex; // 当前页面的索引
@property (nonatomic, weak) UIButton *lastSelectedMenuItem; // 上次选中的菜单
@property (nonatomic, strong) CCIndexPath *lastSelectedIndePath; // 上次选中的path
@end

@implementation MultiValueController

- (instancetype)init {
    if (self = [super init]) {
        [self setUpDefaults];
    }
    return self;
}

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
#endif

- (void)disMiss {
    [UIView animateWithDuration:0.25f animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.containerView.y += self.containerView.height;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:NULL];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.25f animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
        self.containerView.y -= self.containerView.height;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)tapOnView: (UITapGestureRecognizer *)tap {
    CGPoint location = [tap locationInView:self.view];
    if (!CGRectContainsPoint(self.containerView.frame, location)) {
        [self disMiss];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _bundle = [NSBundle bundleForClass:[self class]];
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self setUpTitleView];
    [self setUpHorizontalMenu];
    [self setUpPageContainerView];
    [self setUpRootView];
    self.containerView.y = self.view.height;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap setCancelsTouchesInView:NO];
    [tap addTarget:self action:@selector(tapOnView:)];
    [self.view addGestureRecognizer:tap];
//#ifdef DEBUG
#if 0
    self.titleView.backgroundColor = [UIColor redColor];
    self.menuView.backgroundColor = [UIColor greenColor];
    self.pageContainerView.backgroundColor = [UIColor purpleColor];
#endif
}

- (void)setUpDefaults {
    self.titleViewHeight = 34.0f;
    self.menuViewHeight = 29.0f;
    self.menuItemSpaceX = 24.0f;
    self.tintColor = [UIColor redColor];
    self.titleFont = [UIFont systemFontOfSize:17];
    self.textFont = [UIFont systemFontOfSize:15];
    self.tableViewCellHeight = 44.0f;
}

- (void)setUpTitleView {
    UIView *cv = [[UIView alloc] initWithFrame:CGRectMake(0, 0.5*screenH(), screenW(), 0.5*screenH())];
    cv.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cv];
    self.containerView = cv;
    UIView *tv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cv.width, self.titleViewHeight)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = self.titleFont;
    titleLabel.text = self.title;
    titleLabel.textColor = [UIColor grayColor];
    [tv addSubview:titleLabel];
    [titleLabel sizeToFit];
    titleLabel.centerX = tv.width*0.5;
    titleLabel.centerY = tv.height*0.5;
    //
    UIButton *dismissBtn = [[UIButton alloc] initWithFrame:CGRectMake(tv.width-34, 0, 20, 20)];
    dismissBtn.centerY = tv.height*0.5;
    [dismissBtn setImage:[UIImage imageNamed:@"close_64px" inBundle:self.bundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [dismissBtn addTarget:self action:@selector(onColoseBtn:) forControlEvents:UIControlEventTouchUpInside];
    [tv addSubview:dismissBtn];
    [self.containerView addSubview:tv];
    self.titleView = tv;
}

- (void)setUpHorizontalMenu {
    UIScrollView *menu = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.titleViewHeight, screenW(), self.menuViewHeight)];
    menu.showsHorizontalScrollIndicator = NO;
    menu.showsVerticalScrollIndicator = NO;
    UIView *ind = [[UIView alloc] initWithFrame:CGRectMake(0, self.menuViewHeight-2, 20, 2)];
    ind.backgroundColor = self.tintColor;
    [menu addSubview:ind];
    self.indicateLine = ind;
    [self.containerView addSubview:menu];
    self.menuView = menu;
}

- (void)setUpPageContainerView {
    UIScrollView *pageContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.titleViewHeight+self.menuViewHeight, screenW(), self.containerView.height-(self.titleViewHeight+self.menuViewHeight))];
    pageContainer.pagingEnabled = YES;
    pageContainer.delegate = self;
    [self.containerView addSubview:pageContainer];
    self.pageContainerView = pageContainer;
}

- (void)setUpRootView {
    // 默认启动时加载root页面
    [self addPageWithTitle:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onColoseBtn: (UIButton *)sender {
    [self disMiss];
}

- (void)addPageWithTitle:(NSString *)title {
    // 添加menuItem
    CGFloat offsetX = 0;
    if (_menuItemViews.count) {
        offsetX = ((UIView *)_menuItemViews.lastObject).x + ((UIView *)_menuItemViews.lastObject).width + self.menuItemSpaceX;
    }else {
        offsetX = self.menuItemSpaceX;
    }
    UIButton *menuItemView = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 0, 44, self.menuViewHeight)];
    menuItemView.titleLabel.font = self.textFont;
    [menuItemView setTitle:title forState:UIControlStateNormal];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(viewController:titleForColumn:)]) {
        NSString *t = [self.dataSource viewController:self titleForColumn:_menuItemViews.count];
        [menuItemView setTitle:t forState:UIControlStateNormal];
    }
    [menuItemView addTarget:self action:@selector(onMenuItemView:) forControlEvents:UIControlEventTouchUpInside];
    [menuItemView setTitleColor:self.tintColor forState:UIControlStateSelected];
    [menuItemView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.menuView addSubview:menuItemView];
    [menuItemView sizeToFit];
    [menuItemView.titleLabel sizeToFit];
    if (!_menuItemViews) {
        _menuItemViews = [[NSMutableArray alloc] init];
    }
    [_menuItemViews addObject:menuItemView];
    // 计算menuView的contentsize
    self.menuView.contentSize = CGSizeMake(offsetX+menuItemView.width+self.menuItemSpaceX, self.menuViewHeight);
    // 添加page
    offsetX = screenW() * _pageViews.count;
    UITableView *pageView = [[UITableView alloc] initWithFrame:CGRectMake(offsetX, 0, screenW(), self.pageContainerView.height) style:UITableViewStylePlain];
    if (!_pageViews) {
        _pageViews = [[NSMutableArray alloc] init];
    }
    [_pageViews addObject:pageView];
    pageView.dataSource = self;
    pageView.delegate = self;
    pageView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.pageContainerView addSubview:pageView];
    // 计算pageContainerView的contentsize
    self.pageContainerView.contentSize = CGSizeMake(_pageViews.count*screenW(), self.pageContainerView.height);
    // 选中当前添加的页面
    [self onMenuItemView:menuItemView];
}

- (void)updatePageAtIndex: (NSInteger)index {
    if (index < _pageViews.count) {
        UIButton *menuItemView = _menuItemViews[index];
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(viewController:titleForColumn:)]) {
            NSString *title = [self.dataSource viewController:self titleForColumn:index];
            [menuItemView setTitle:title forState:UIControlStateNormal];
        }
        UITableView *pageView = _pageViews[index];
        [pageView reloadData];
    }
}

- (void)onMenuItemView: (UIButton *)sender {
    if (sender != self.lastSelectedMenuItem) {
        NSInteger index = [_menuItemViews indexOfObject:sender];
        [self.pageContainerView setContentOffset:CGPointMake(self.pageContainerView.width*index, 0) animated:YES];
        [UIView animateWithDuration:0.25f animations:^{
            self.indicateLine.width = sender.titleLabel.width;
            self.indicateLine.centerX = sender.centerX;
        }];
        self.lastSelectedMenuItem.selected = NO;
        self.lastSelectedMenuItem = sender;
        sender.selected = YES;
    }
}

- (NSInteger)currentPageIndex {
    return self.pageContainerView.contentOffset.x/self.pageContainerView.width;
}

- (void)deletePageFromIndex: (NSInteger)index {
    if (index < _pageViews.count) {
        for (NSInteger i = _pageViews.count-1; i >= index ; i--) {
            UIButton *btn = _menuItemViews[i];
            UITableView *table = _pageViews[i];
            [btn removeFromSuperview];
            [table removeFromSuperview];
            // 计算contentsize
            self.menuView.contentSize = CGSizeMake(btn.x-self.menuItemSpaceX, self.menuViewHeight);
            self.pageContainerView.contentSize = CGSizeMake(table.x, self.pageContainerView.height);
        }
        [_menuItemViews removeObjectsInRange:NSMakeRange(index, _pageViews.count-index)];
        [_pageViews removeObjectsInRange:NSMakeRange(index, _pageViews.count-index)];
        // 删除选中的indexPath
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"SELF.column < %ld", index];
        [_selectedIndexPath filterUsingPredicate:pre];
    }
}

- (void)done {
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewControllerDidFinishSelect:)]) {
        [self.delegate viewControllerDidFinishSelect:self];
    }
    [self disMiss];
}

- (NSArray *)selectedIndexPath {
    return _selectedIndexPath;
}

// MARK: TableView DataSource && Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger index = [_pageViews indexOfObject:tableView];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(viewController:numberOfItemsAtColumn:)]) {
        return [self.dataSource viewController:self numberOfItemsAtColumn:index];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[CheckMarkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.textLabel.font = self.textFont;
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = selectionColor;
        cell.textLabel.highlightedTextColor = self.tintColor;
    }
    NSUInteger index = [_pageViews indexOfObject:tableView];
    CCIndexPath *path = [[CCIndexPath alloc] initWithIndexPath:indexPath column:index];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(viewController:titleForIndexPath:)]) {
        cell.textLabel.text = [self.dataSource viewController:self titleForIndexPath:path];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.tableViewCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger column = [_pageViews indexOfObject:tableView];
    CCIndexPath *path = [[CCIndexPath alloc] initWithIndexPath:indexPath column:column];
    BOOL hintAdd = NO;
    if (!_selectedIndexPath) {
        _selectedIndexPath = [[NSMutableArray alloc] init];
    }
    if ([_selectedIndexPath containsObject:path]) {
        if (column < _pageViews.count - 1) {
            [self onMenuItemView:_menuItemViews[column+1]];
        }else {
            hintAdd = YES;
        }
    }else {
        // 删除此页面后(不包含此)的页面
        [self deletePageFromIndex:column+1];
        hintAdd = YES;
    }
    if (![_selectedIndexPath containsObject:path]) {[_selectedIndexPath addObject:path];}
    self.lastSelectedIndePath = path;
    if (self.delegate && [self.delegate respondsToSelector:@selector(viewController:didSelectItemAtIndexPath:hintAddPage:)]) {
        [self.delegate viewController:self didSelectItemAtIndexPath:path hintAddPage:hintAdd];
    }
}

// MARK: UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.pageContainerView) {
        [self onMenuItemView:_menuItemViews[self.currentPageIndex]];
    }
}

@end
