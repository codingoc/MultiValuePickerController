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

@interface ViewController ()

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)open: (UIButton *)sender {
    MultiValueController *c = [[MultiValueController alloc] init];
    c.menuItemSpaceX = 8.0f;
    c.title = @"人物";
    
    Person *p0 = [[Person alloc] init];
    p0.name = @"张";
    Person *p1 = [[Person alloc] init];
    p1.name = @"李";
    Person *p2 = [[Person alloc] init];
    p2.name = @"王";
    
    c.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:c animated:YES completion:^{
        [c addPageWithTitle:@"依天照海" list:@[p0, p1, p2]];
    }];
}

@end
