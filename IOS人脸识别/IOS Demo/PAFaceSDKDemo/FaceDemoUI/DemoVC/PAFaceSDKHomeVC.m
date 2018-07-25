//
//  PAFaceSDKHomeVC.m
//  PAFaceSDKDemo
//
//  Created by 朱敏(EX-ZHUMIN004) on 2017/11/9.
//  Copyright © 2017年 pingan. All rights reserved.
//

#import "PAFaceSDKHomeVC.h"
#import "PAZCLDefineTool.h"
#import "PAFaceCheckPreModel.h"
#import "SVProgressHUD.h"
#import "PAFaceCheckVC.h"
#import "PAFaceSDKHomeOptionView.h"
#import <sys/utsname.h>

#define kTOPBGHeight           (kScaleWidth(409.0f))
#define kStartBtnHeight        (kScaleHeight(48.0f))
#define kStartBtnWidth         (kScaleWidth(240.0f))
#define kStartBtnToBottomSpace (kScaleHeight(32.0f))

#define kTitleFontColor        (YT_ColorWithRGB(105, 131, 165, 1))
#define kStartButtonRadius     (8)

@interface PAFaceSDKHomeVC ()
// views
// bottom btn
@property (nonatomic, strong) UIButton *startBtn;
@property (nonatomic, strong) PAFaceSDKHomeOptionView *optionView;
@end

@implementation PAFaceSDKHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpUI];
    [self initData];
}

- (void)initData {
    // UI setting
    _optionView.superVC = self;
    _optionView.turnOnBtn.selected = YES;
    _optionView.textBtn.selected = YES;
    _optionView.voiceBtn.selected = YES;
    _optionView.animationBtn.selected = YES;
    
    [_optionView initSetting];
}

- (void)setUpUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    // set topBg
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:kFaceImage(@"banner")];
    CGFloat height = kTOPBGHeight;
    
    // 适配5，5c，5s背景图高度
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"iPhone5,1"] || [platform isEqualToString:@"iPhone5,2"] || [platform isEqualToString:@"iPhone5,3"] || [platform isEqualToString:@"iPhone5,4"] || [platform isEqualToString:@"iPhone6,1"] || [platform isEqualToString:@"iPhone6,2"]) {
        height = kScaleHeight(409.0f);
    }
    bgImageView.frame = CGRectMake(0, 0, kScreenWidth, height);
    [self.view addSubview:bgImageView];
 
    // set optionView
    _optionView = [[PAFaceSDKHomeOptionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bgImageView.frame), kScreenWidth, kScreenHeight - kStartBtnHeight - kTOPBGHeight - kStartBtnToBottomSpace)];
    _optionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_optionView];
    
    // set bottom btn
    _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _startBtn.frame = CGRectMake((kScreenWidth - kStartBtnWidth) / 2, kScreenHeight - kStartBtnHeight - kStartBtnToBottomSpace, kStartBtnWidth, kStartBtnHeight);
    [_startBtn addTarget:self action:@selector(preCheck) forControlEvents:UIControlEventTouchUpInside];
    _startBtn.titleLabel.font = kTitleFontSize;
    [_startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_startBtn setTitle:@"开始检测" forState:UIControlStateNormal];
    
    // 设置btn渐变色
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xFF6F97E0).CGColor,(__bridge id)UIColorFromRGB(0xFF907BDC).CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    gradientLayer.frame = CGRectMake(0, 0, CGRectGetWidth(_startBtn.frame), CGRectGetHeight(_startBtn.frame));
    [_startBtn.layer insertSublayer:gradientLayer below:_startBtn.titleLabel.layer];
    
    [_startBtn.layer setCornerRadius:kStartButtonRadius];
    [_startBtn.layer setMasksToBounds:YES];
    [self.view addSubview:_startBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - event
- (void)preCheck {
    if (!_optionView.actionType) {
        [SVProgressHUD showErrorWithStatus:@"请至少选择一种检测方式!" duration:0.5f];
        return;
    }
    
    if (!_optionView.textBtn.selected && !_optionView.voiceBtn.selected && !_optionView.animationBtn.selected) {
        [SVProgressHUD showErrorWithStatus:@"请至少选择一种提醒方式!" duration:0.5f];
        return;
    }
    
    PAFaceCheckPreModel *model = [[PAFaceCheckPreModel alloc] init];
    model.actionType = _optionView.actionType;
    model.isShowTimer = _optionView.turnOnBtn.selected;
    model.isShowText = _optionView.textBtn.selected;
    model.isShowVoice = _optionView.voiceBtn.selected;
    model.isShowAnimation = _optionView.animationBtn.selected;
    
    [self startCheckWithModel:model];
}

- (void)startCheckWithModel:(PAFaceCheckPreModel *)model {
    PAFaceCheckVC *vc = [[PAFaceCheckVC alloc] initFaceCheckWithModel:model];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
