//
//  PAActionTipsView.h
//  PAFaceSDKDemo
//
//  Created by 朱敏(EX-ZHUMIN004) on 2017/11/10.
//  Copyright © 2017年 pingan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OCFTFaceDetect/OCFTFaceDetector.h>
#import "PAZCLDefineTool.h"

@interface PAActionTipsView : UIView
@property (nonatomic, weak) UILabel *textRemindLabel;

// 初始化方法，是否显示文本，倒计时，动效提醒
- (instancetype)initWithText:(BOOL)showText
                       timer:(BOOL)showTimer
                   animation:(BOOL)showAnimation;

// 设置tips的类型，outTime默认为15，不设置传0
- (void)willChangeAnimation:(OCFTFaceDetectActionType)state outTime:(CGFloat)time;

// 开始提醒，当超时时，会自动停止并调用block
- (void)startingRemindWithOutTimerBlock:(VoidBlock)outTimeBlock;

// 手动结束提醒
- (void)stopRemind;
@end

