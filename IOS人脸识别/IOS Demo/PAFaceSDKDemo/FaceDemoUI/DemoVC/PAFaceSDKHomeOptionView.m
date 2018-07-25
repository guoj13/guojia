//
//  PAFaceSDKHomeOptionView.m
//  PAFaceSDKDemo
//
//  Created by 朱敏(EX-ZHUMIN004) on 2017/11/13.
//  Copyright © 2017年 pingan. All rights reserved.
//

#import "PAFaceSDKHomeOptionView.h"
#import "PAZCLDefineTool.h"

#define kItemWidth             (kScaleWidth(64.0f))
#define kItemHeight            (kScaleHeight(23.0f))

#define kButtonNormalColor_normal     (YT_ColorWithRGB(130, 151, 179, 1))
#define kButtonSelectColor_select     (YT_ColorWithRGB(81, 131, 221, 1))
#define kButtonSelectBackgroundColor  (YT_ColorWithRGB(81, 131, 221, 0.05))
#define kTitleFontColor        (YT_ColorWithRGB(105, 131, 165, 1))

#define kNormalButtonRadius    (3)

typedef enum {
    PAFaceOptionBtnTypeAction = 101,
    PAFaceOptionBtnTypeTurnOn,
    PAFaceOptionBtnTypeTurnOff,
    PAFaceOptionBtnTypeText,
    PAFaceOptionBtnTypeVoice,
    PAFaceOptionBtnTypeAnimation,
} PAFaceOptionBtnType;

@interface PAFaceSDKHomeOptionView ()
@property (nonatomic, readwrite, assign) PAFaceCheckActionType actionType;
@end

@implementation PAFaceSDKHomeOptionView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    CGFloat leftSpace = kScaleWidth(24.0f) ;
    CGFloat topSpace = kScaleHeight(30.0f);
    CGFloat itemHSpace = kScaleWidth(20.0f);
    CGFloat itemVSpace = kScaleHeight(15.0f);
    
    // 第一排
    UILabel *actionLabel = [self creatNormalLabelWithTitle:@"动作："];
    actionLabel.frame = CGRectMake(leftSpace, topSpace, kItemWidth, kItemHeight);
    [self addSubview:actionLabel];
    
    _actionSelectBtn = [self creatNormalButtonWithTitle:@"请选择模式" tag:PAFaceOptionBtnTypeAction];
    _actionSelectBtn.frame = CGRectMake(CGRectGetMaxX(actionLabel.frame) + itemHSpace, CGRectGetMinY(actionLabel.frame), kItemWidth, kItemHeight);
    [self addSubview:_actionSelectBtn];
    
    // 第二排
    UILabel *timerLabel = [self creatNormalLabelWithTitle:@"倒计时："];
    timerLabel.frame = CGRectMake(leftSpace, CGRectGetMaxY(actionLabel.frame) + itemVSpace, kItemWidth, kItemHeight);
    [self addSubview:timerLabel];
    
    _turnOnBtn = [self creatNormalButtonWithTitle:@"有" tag:PAFaceOptionBtnTypeTurnOn];
    _turnOnBtn.frame = CGRectMake(CGRectGetMaxX(timerLabel.frame) + itemHSpace, CGRectGetMinY(timerLabel.frame), kItemWidth, kItemHeight);
    [self addSubview:_turnOnBtn];
    
    _turnOfftn = [self creatNormalButtonWithTitle:@"无" tag:PAFaceOptionBtnTypeTurnOff];
    _turnOfftn.frame = CGRectMake(CGRectGetMaxX(_turnOnBtn.frame) + itemHSpace, CGRectGetMinY(timerLabel.frame), kItemWidth, kItemHeight);
    [self addSubview:_turnOfftn];
    
    // 第三排
    UILabel *tipsLabel = [self creatNormalLabelWithTitle:@"提示："];
    tipsLabel.frame = CGRectMake(leftSpace, CGRectGetMaxY(timerLabel.frame) + itemVSpace, kItemWidth, kItemHeight);
    [self addSubview:tipsLabel];
    
    _textBtn = [self creatSelectButtonWithTitle:@"文字" tag:PAFaceOptionBtnTypeText];
    _textBtn.frame = CGRectMake(CGRectGetMaxX(tipsLabel.frame) + itemHSpace, CGRectGetMinY(tipsLabel.frame), kItemWidth, kItemHeight);
    [self addSubview:_textBtn];
    
    _voiceBtn = [self creatSelectButtonWithTitle:@"语音" tag:PAFaceOptionBtnTypeVoice];
    _voiceBtn.frame = CGRectMake(CGRectGetMaxX(_textBtn.frame) + itemHSpace, CGRectGetMinY(tipsLabel.frame), kItemWidth, kItemHeight);
    [self addSubview:_voiceBtn];
    
    _animationBtn = [self creatSelectButtonWithTitle:@"动效" tag:PAFaceOptionBtnTypeAnimation];
    _animationBtn.frame = CGRectMake(CGRectGetMaxX(_voiceBtn.frame) + itemHSpace, CGRectGetMinY(tipsLabel.frame), kItemWidth, kItemHeight);
    [self addSubview:_animationBtn];
}

- (UILabel *)creatNormalLabelWithTitle:(NSString *)title {
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:kScaleWidth(15)];
    label.textColor = kTitleFontColor;
    label.textAlignment = NSTextAlignmentLeft;
    label.text = title;
    return label;
}

- (UIButton *)creatNormalButtonWithTitle:(NSString *)title tag:(int)tag {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = tag;
    btn.titleLabel.font = [UIFont systemFontOfSize:kScaleWidth(13)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:kButtonNormalColor_normal forState:UIControlStateNormal];
    [btn setTitleColor:kButtonSelectColor_select forState:UIControlStateSelected];
    btn.layer.cornerRadius = kNormalButtonRadius;
    [btn.layer setBorderColor:kButtonNormalColor_normal.CGColor];
    [btn.layer setBorderWidth:0.5f];
    [btn.layer setMasksToBounds:YES];
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (UIButton *)creatSelectButtonWithTitle:(NSString *)title tag:(int)tag {
    UIButton *btn = [self creatNormalButtonWithTitle:title tag:tag];
    [btn setBackgroundImage:kFaceImage(@"icon_uncheck") forState:UIControlStateNormal];
    [btn setBackgroundImage:kFaceImage(@"icon_check") forState:UIControlStateSelected];
    
    return btn;
}

#pragma mark - public
- (void)initSetting {
    for (UIButton *btn in self.subviews) {
        if (![btn isKindOfClass:[UIButton class]]) {
            continue;
        }
        
        [self setBtnSelect:btn];
    }
}

#pragma mark - event
- (void)clickBtn:(UIButton *)btn {
    int tag = (int)btn.tag;
    
    if (PAFaceOptionBtnTypeText == tag || PAFaceOptionBtnTypeVoice == tag || PAFaceOptionBtnTypeAnimation == tag) {
        btn.selected = !btn.selected;
        [self setBtnSelect:btn];
        return;
    }
    
    if (btn.selected) {
        return;
    }
    
    if (PAFaceOptionBtnTypeAction == tag) {
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"请选择检测模式" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        
        
        __weak typeof(self) weakSelf = self;
        UIAlertAction *face = [UIAlertAction actionWithTitle:@"无动作" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weakSelf.actionType = PAFaceCheckActionTypeFace;
        }];
        
        UIAlertAction *mo = [UIAlertAction actionWithTitle:@"张嘴" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weakSelf.actionType = PAFaceCheckActionTypeMouse;
        }];
        
        UIAlertAction *eye = [UIAlertAction actionWithTitle:@"眨眼" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weakSelf.actionType = PAFaceCheckActionTypeEyeLink;
        }];
        
        UIAlertAction *random = [UIAlertAction actionWithTitle:@"单一随机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weakSelf.actionType = PAFaceCheckActionTypeRandom;
        }];
        
        UIAlertAction *allRandom = [UIAlertAction actionWithTitle:@"全部随机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weakSelf.actionType = PAFaceCheckActionTypeAllRandom;
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertC addAction:face];
        [alertC addAction:mo];
        [alertC addAction:eye];
        [alertC addAction:random];
        [alertC addAction:allRandom];
        [alertC addAction:cancel];
        
        [self.superVC presentViewController:alertC animated:YES completion:nil];
        return;
    }
    
    switch (tag) {
        case PAFaceOptionBtnTypeTurnOn:
            _turnOnBtn.selected = YES;
            _turnOfftn.selected = NO;
            break;
            
        case PAFaceOptionBtnTypeTurnOff:
            _turnOfftn.selected = YES;
            _turnOnBtn.selected = NO;
            break;
    }
    
    [self setBtnSelect:_turnOnBtn];
    [self setBtnSelect:_turnOfftn];
}

- (void)setActionType:(PAFaceCheckActionType)actionType {
    _actionType = actionType;
    
    NSString *text;
    switch (_actionType) {
        case PAFaceCheckActionTypeFace:
            text = @"无动作";
            break;
            
        case PAFaceCheckActionTypeMouse:
            text = @"张嘴";
            break;
            
        case PAFaceCheckActionTypeEyeLink:
            text = @"眨眼";
            break;
            
        case PAFaceCheckActionTypeRandom:
            text = @"单一随机";
            break;
            
        case PAFaceCheckActionTypeAllRandom:
            text = @"全部随机";
            break;
    }
    
    [_actionSelectBtn setTitle:text forState:UIControlStateNormal];
}

- (void)setBtnSelect:(UIButton *)btn {
    int tag = (int)btn.tag;
    if (PAFaceOptionBtnTypeText == tag || PAFaceOptionBtnTypeVoice == tag || PAFaceOptionBtnTypeAnimation == tag) {
        return;
    }
    
    btn.selected ?  [btn setBackgroundColor:kButtonSelectBackgroundColor] : [btn setBackgroundColor:[UIColor whiteColor]];
}

@end

