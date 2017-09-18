//
//  ViewController.m
//  ViewTrackerSDKDemo
//
//  Created by philip on 2017/4/10.
//  Copyright © 2017年 ViewTracker. All rights reserved.
//

#import "ViewController.h"
#import "SubViewController.h"

#import <TMViewTrackerSDK/TMViewTrackerSDK.h>
#import "CycleScrollView.h"

@interface ViewController () <CycleScrollViewDelegate>

@property (nonatomic, strong) CycleScrollView *banner;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *button1;
@property (nonatomic, strong) UIButton *button2;
@property (nonatomic, strong) UIButton *button3;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Tab1";
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    CGFloat w = self.view.bounds.size.width;
    
    _banner = [CycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, w, 300) shouldInfiniteLoop:YES imageNamesGroup:self.imageNames];
    _banner.delegate = self;
    [self.view addSubview:_banner];
    _banner.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 300, w, [UIScreen mainScreen].bounds.size.height - 300.f -44.f)];
    self.scrollView.contentSize = CGSizeMake(w, 400.f);
    [self.view addSubview:_scrollView];
    
    _button1 = [[UIButton alloc] initWithFrame:CGRectMake(50, 10, 200, 50)];
    [_button1 setTintColor:[UIColor blueColor]];
    [_button1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_button1 setTitle:@"pushToSubVC1" forState:UIControlStateNormal];
    [_button1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _button1.controlName = @"pushToSubVC1";
    _button1.commitType = ECommitTypeClick;
    [_scrollView addSubview:_button1];
    
    _button2 = [[UIButton alloc] initWithFrame:CGRectMake(50, 70, 200, 50)];
    [_button2 setTintColor:[UIColor blueColor]];
    [_button2 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_button2 setTitle:@"presentSubVC2" forState:UIControlStateNormal];
    [_button2 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _button2.controlName = @"presentSubVC2";
    _button2.commitType = ECommitTypeClick;
    [_scrollView addSubview:_button2];
    
    _button3 = [[UIButton alloc] initWithFrame:CGRectMake(50, 140, 200, 50)];
    [_button3 setTintColor:[UIColor blueColor]];
    [_button3 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_button3 setTitle:@"showAlertView" forState:UIControlStateNormal];
    [_button3 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    _button3.controlName = @"showAlertView";
    _button3.commitType = ECommitTypeExposure;
    [_scrollView addSubview:_button3];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [TMViewTrackerManager setCurrentPageName:self.title];
}

- (void)buttonClicked:(id)sender
{
    UIViewController *vc = nil;
    if ([sender isEqual:_button1]){
        vc = [SubViewController new];
        vc.title = @"pushedSubViewController";
        [self.navigationController pushViewController:vc animated:NO];
    }else if ([sender isEqual:_button2])
    {
        vc = [SubViewController new];
        vc.title = @"presentedSubViewController";
        [self presentViewController:vc animated:YES completion:^{
            NSLog(@"ViewController : present SubViewController complete");
        }];
    }else if ([sender isEqual:_button3])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"Alert"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [alert dismissViewControllerAnimated:YES completion:^{
                                                        
                                                    }];
                                                }]];
        
        [self presentViewController:alert animated:YES completion:^{}];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray*)imageNames{
    return @[@"h1.jpg", @"h2.jpg", @"h3.jpg", @"h4.jpg"];
}
#pragma mark - delegate
- (void)cycleScrollView:(CycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    SubViewController *subVC = [[SubViewController alloc] init];
    subVC.title = [NSString stringWithFormat:@"SubVC_For_Banner-%ld", index];
    NSInteger itemIndex = index % [self imageNames].count;
    subVC.imagePath = [self imageNames][itemIndex];
    [self.navigationController pushViewController:subVC animated:YES];
}
@end
