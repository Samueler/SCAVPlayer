//
//  SCAVViewController.m
//  SCAVPlayer
//
//  Created by samueler.chen@gmail.com on 05/14/2020.
//  Copyright (c) 2020 samueler.chen@gmail.com. All rights reserved.
//

#import "SCAVViewController.h"
#import "SCAVSinglePlayerVC.h"
#import "SCAVQueuePlayerVC.h"

@interface SCAVViewController ()

@end

@implementation SCAVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 150, 44)];
    btn.backgroundColor = [UIColor orangeColor];
    [btn setTitle:@"点我啊-single" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(100, 160, 150, 44)];
    btn1.backgroundColor = [UIColor orangeColor];
    [btn1 setTitle:@"点我啊-queue" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btn1Click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
}

- (void)btnClick {
    SCAVSinglePlayerVC *vc = [[SCAVSinglePlayerVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)btn1Click {
    SCAVQueuePlayerVC *vc = [[SCAVQueuePlayerVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
