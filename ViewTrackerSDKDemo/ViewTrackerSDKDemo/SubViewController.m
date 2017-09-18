//
//  SubViewController.m
//  ViewTrackerSDKDemo
//
//  Created by philip on 2017/4/10.
//  Copyright © 2017年 ViewTracker. All rights reserved.
//

#import "SubViewController.h"

#import <TMViewTrackerSDK/TMViewTrackerSDK.h>

@interface SubViewController ()
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation SubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!self.title)
        self.title = @"SubViewController";
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    _button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 200, 50)];
    [_button setTintColor:[UIColor blueColor]];
    [_button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *btnTitle = nil;
    if ([self isPushed]) {
        btnTitle = @"popViewController";
    }else{
        btnTitle = @"dismissViewController";
    }
    
    [_button setTitle:btnTitle forState:UIControlStateNormal];
    _button.controlName = btnTitle;
    
    [self.view addSubview:_button];
    
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 150, self.view.bounds.size.width, 300)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imageView];
    
    _imageView.controlName = _imagePath;
    [self setImagePath:_imagePath];
    
}

- (void)setImagePath:(NSString *)imagePath
{
    _imagePath = imagePath;
    if (imagePath.length) {
        UIImage *image = [UIImage imageNamed:imagePath];
        if (!image) {
            image = [UIImage imageWithContentsOfFile:imagePath];
        }
        
        _imageView.image = image;
        _imageView.controlName = _imagePath;
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [TMViewTrackerManager setCurrentPageName:self.title];
}

- (void)buttonClicked:(id)sender
{
    if ([sender isEqual:_button]) {
        if ([self isPushed]) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:^{
                
                NSLog(@"SubViewController : dismiss SubViewController complete");
            }];
        }
    }
}

- (BOOL)isPushed
{
    NSArray *viewcontrollers=self.navigationController.viewControllers;
    if (viewcontrollers.count>1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count-1]==self) {
            //push方式
            return YES;
        }
    }
    
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
