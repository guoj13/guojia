//
//  PAActionTipsView.m
//  PAFaceSDKDemo
//
//  Created by 朱敏(EX-ZHUMIN004) on 2017/11/10.
//  Copyright © 2017年 pingan. All rights reserved.
//

#import "PAActionTipsView.h"
#import "UIImageView+GIF.h"

#define kAnimationTime (15)
#define kTimerRepeat   (1)
#define kAnimationViewHeight (126.0f)
#define kAnimationViewWidth  (89.0f)
#define kStringWithInt(int)     ([NSString stringWithFormat:@"%d", (int)])

@interface PAActionTipsView () {
    BOOL    isAnimation;
    
    BOOL    showText_;
    BOOL    showTimer_;
    BOOL    showAnimation_;
    
    NSTimeInterval limitTime;
    
    VoidBlock outTimeBlock_;
}

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, weak) UILabel *timeRemindLabel;
@property (nonatomic, weak) UIImageView *animationImageView;

// 待显示内容
@property (nonatomic, copy) NSString *textString;
@property (nonatomic, copy) NSString *gifImageName;

@property (nonatomic, assign) int timeCount;
@end

@implementation PAActionTipsView
- (instancetype)initWithText:(BOOL)showText timer:(BOOL)showTimer animation:(BOOL)showAnimation {
    self = [super init];
    
    if (self) {
        limitTime = 0;
        _timeCount = 0;
        showText_ = showText;
        showTimer_ = showTimer;
        showAnimation_ = showAnimation;
    }
    return self;
}

- (void)willChangeAnimation:(OCFTFaceDetectActionType)state outTime:(CGFloat)time {
    switch (state) {
        case OCFT_COLLECTFACE:
            self.gifImageName = nil;
            break;
            
        case OCFT_EYEBLINK:
            _textString = @"请缓慢眨眼";
            self.gifImageName = @"eye";
            break;
            
        case OCFT_MOUTH:
            _textString = @"请缓慢张嘴";
            self.gifImageName = @"openMouse";
            break;
    }
    
    limitTime = time ? time : kAnimationTime;
}

- (void)setGifImageName:(NSString *)gifImageName {
    _gifImageName = gifImageName;
    
    if (!_gifImageName) {
        self.animationImageView.hidden = YES;
        return;
    }
    
    if (showAnimation_) {
        if ([self.animationImageView isAnimating]) {
            [self.animationImageView stopAnimating];
            self.animationImageView = nil;
        }
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"PAFaceSDKSource" ofType:@"bundle"];
        NSData *imageData = [NSData dataWithContentsOfFile:[[NSBundle bundleWithPath:bundlePath] pathForResource:_gifImageName ofType:@"gif"]];
        [self.animationImageView setAnimatedGIFWithData:imageData];
        [self.animationImageView setAnimationRepeatCount:NSIntegerMax];
        [self.animationImageView startAnimating];
        self.animationImageView.hidden = NO;
    }
}

- (void)startingRemindWithOutTimerBlock:(VoidBlock)outTimeBlock {
    // 显示文字
    if (showText_) {
        [self.textRemindLabel setText:_textString];
        self.textRemindLabel.hidden = NO;
    }
    
    outTimeBlock_ = outTimeBlock;
    
    // 开启定时器
    if (showTimer_) {
        _timeCount = limitTime + 1;
        [self refreshTimeLabel];
        [self.timer fire];
        self.timeRemindLabel.hidden = NO;
    }
}

- (void)stopRemind {
    self.hidden = YES;
    
    // 停止定时器
    [self.timer invalidate];
    _timer = nil;
    
    // 停止动画
    if (_animationImageView && [_animationImageView isAnimating]) {
        [_animationImageView stopAnimating];
    }
    
    _timeCount = 0;
}

- (void)timeChange {
    if (_timeCount <= 0) {
        [self animationOutTime];
        return;
    }
    
    _timeCount -= kTimerRepeat;
    [self refreshTimeLabel];
}

- (void)animationOutTime {
    // 停止提醒
    [self stopRemind];
    
    // 通知回调
    if (outTimeBlock_) {
        outTimeBlock_();
    }
}

- (void)refreshTimeLabel {
    [self.timeRemindLabel setText:kStringWithInt(_timeCount)];
}

- (void)layoutSubviews {
    if (showText_) {
        self.textRemindLabel.frame = CGRectMake(0, 0, kScreenWidth, kScaleWidth(22));
    }
    
    if (showTimer_) {
        CGFloat topy = _textRemindLabel ? CGRectGetMaxY(_textRemindLabel.frame) + kScaleWidth(28) : 0;
        self.timeRemindLabel.frame = CGRectMake(0, topy, kScreenWidth, kScaleWidth(28));
    }
    
    if (showAnimation_) {
        self.animationImageView.frame = CGRectMake((kScreenWidth - kAnimationViewWidth) / 2, self.bounds.size.height - kAnimationViewHeight, kAnimationViewWidth, kAnimationViewHeight);
    }
}

#pragma mark - 懒加载
- (UILabel *)textRemindLabel {
    if (!_textRemindLabel) {
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.font = [UIFont systemFontOfSize:kScaleWidth(22)];
        textLabel.textColor = UIColorFromRGB(0x6177DC);
        textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:textLabel];
        
        _textRemindLabel = textLabel;
    }
    return _textRemindLabel;
}

- (UILabel *)timeRemindLabel {
    if (!_timeRemindLabel) {
        UILabel *timerLabel = [[UILabel alloc] init];
        timerLabel.font = [UIFont systemFontOfSize:kScaleWidth(28)];
        timerLabel.textColor = UIColorFromRGB(0x6177DC);
        timerLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:timerLabel];
        _timeRemindLabel.hidden = YES;
        _timeRemindLabel = timerLabel;
    }
    return _timeRemindLabel;
}

- (UIImageView *)animationImageView {
    if (!_animationImageView) {
        UIImageView *aImageView = [[UIImageView alloc] init];
        [self addSubview:aImageView];
        
        _animationImageView = aImageView;
        _animationImageView.hidden = YES;
    }
    return _animationImageView;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:kTimerRepeat  target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    return _timer;
}

@end

