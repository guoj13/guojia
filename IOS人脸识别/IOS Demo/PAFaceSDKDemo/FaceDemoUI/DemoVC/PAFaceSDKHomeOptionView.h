//
//  PAFaceSDKHomeOptionView.h
//  PAFaceSDKDemo
//
//  Created by 朱敏(EX-ZHUMIN004) on 2017/11/13.
//  Copyright © 2017年 pingan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAFaceCheckPreModel.h"

@interface PAFaceSDKHomeOptionView : UIView
// action
@property (nonatomic, strong) UIButton *actionSelectBtn;

// time
@property (nonatomic, strong) UIButton *turnOnBtn;
@property (nonatomic, strong) UIButton *turnOfftn;

// tips
@property (nonatomic, strong) UIButton *textBtn;
@property (nonatomic, strong) UIButton *voiceBtn;
@property (nonatomic, strong) UIButton *animationBtn;

@property (readonly) PAFaceCheckActionType actionType;
@property (nonatomic, weak) UIViewController *superVC;
// 在外部设置select时，调用setting刷新btn样式
- (void)initSetting;
@end
