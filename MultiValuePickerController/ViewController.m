//
//  ViewController.m
//  MultiValuePickerController
//
//  Created by cc on 16/3/17.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "ViewController.h"
#import "MultiValueController.h"

@interface Person : NSObject <TextRepresentable>
@property (nonatomic, strong) NSString *name;
@end
@implementation Person
- (NSString *)asText {
    return self.name;
}
@end

@interface ViewController () <MultiValueControllerDelegate>
{
    NSArray *_dataList;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [[UIButton alloc] initWithFrame: CGRectMake(100, 100, 150, 88)];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitle:@"打开选择器" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(open:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    Person *p0 = [[Person alloc] init];
    p0.name = @"张";
    Person *p1 = [[Person alloc] init];
    p1.name = @"李";
    Person *p2 = [[Person alloc] init];
    p2.name = @"王";
    Person *p3 = [[Person alloc] init];
    p3.name = @"陈";
    Person *p4 = [[Person alloc] init];
    p4.name = @"刘";
    Person *p5 = [[Person alloc] init];
    p5.name = @"孙";
    Person *p6 = [[Person alloc] init];
    p6.name = @"韩";
    Person *p7 = [[Person alloc] init];
    p7.name = @"赵";
    
    _dataList = [[NSArray alloc] initWithObjects:p0, p1, p2, p3, p4, p5, p6, p7, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)open: (UIButton *)sender {

    MultiValueController *c = [[MultiValueController alloc] initWithRootColumnTitle:@"依天照海" dataList:_dataList];
    c.delegate = self;
    c.menuItemSpaceX = 24.0f;
    c.title = @"人物";
    
    c.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:c animated:YES completion:^{
    }];
}

- (void)viewController:(MultiValueController *)multiController didSelectItemAtIndexPath:(CCIndexPath *)indexPath {
    NSLog(@"%@", indexPath);
    [multiController addPageWithTitle:@"子" list:[_dataList subarrayWithRange:NSMakeRange(0, 5)]];
}

@end
