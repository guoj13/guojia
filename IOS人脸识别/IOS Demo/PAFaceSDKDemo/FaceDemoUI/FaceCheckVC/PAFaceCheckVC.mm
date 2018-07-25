//
//  PAFaceCheckVC.m
//  PAFaceSDKDemo
//
//  Created by 朱敏(EX-ZHUMIN004) on 2017/11/9.
//  Copyright © 2017年 pingan. All rights reserved.
//

#import "PAFaceCheckVC.h"
#import "PAFaceCheckPreModel.h"
#import "PAZCLDefineTool.h"
#import <OCFTFaceDetect/OCFTFaceDetector.h>
#import "PAActionTipsView.h"
#import "PACameraMaskingView.h"
#import "PAFaceCheckMacro.h"

#define kMenuHeight  (44.0f)
#define kActionTipsTopSpace (kScaleHeight(415))

#define kStateDictTitleKey @"dictTitleKey"
#define kStateDictColorKey @"dictColorKey"
#define kStateDictImageKey @"dictImageKey"
#define kStateDictBgColorKey @"dictBgColorKey"

@interface PAFaceCheckVC () <OCFTFaceDetectProtocol, AVSpeechSynthesizerDelegate, AVSpeechSynthesizerDelegate> {
    PAFaceCheckPreModel  *preModel;
    BOOL    isCheck_;
}

// 活体检测相关
// OCFTFaceDetector
@property (nonatomic, strong) OCFTFaceDetector *livenessDetector;
// 是否开启活体检测
@property (nonatomic, assign) BOOL starLiveness;
@property (nonatomic, assign) BOOL playVoice;

@property (nonatomic, strong) PAActionTipsView *actionTipsView;
@property (nonatomic, strong) PACameraMaskingView *cameraMasking;
@property (nonatomic, strong) UIButton *completeBtn;
@property (nonatomic, strong) CALayer *successImageLayer;

@property (nonatomic, copy) NSString *soundString;
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;     //Text转语音
@property (nonatomic, strong) AVSpeechUtterance *utterance;
@property (nonatomic, strong) AVSpeechSynthesisVoice *voiceType;

@property (nonatomic, strong) UIButton *resetButton;
@end

@implementation PAFaceCheckVC
- (instancetype)initFaceCheckWithModel:(PAFaceCheckPreModel *)model {
    self = [super init];
    
    if (self) {
        preModel = model;
        isCheck_ = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initMenuView];        //初始化顶部menu
    [self initAVSpeech];        //初始化语音
    [self createFacecheck];     //FaceCheck初始化
    
    [self setUpCameraLayer];    //加载图层预览
    
    
    _resetButton = [[UIButton alloc]init];
    [_resetButton setBackgroundColor:[UIColor blueColor]];
    _resetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_resetButton addTarget:self action:@selector(resetFaceCheck) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_resetButton];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_resetButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-10]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_resetButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:50]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_resetButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_resetButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:20]];
    
#ifdef DEBUG
    _resetButton.hidden = NO;
#else
    _resetButton.hidden = YES;
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification *)noti {
    [_livenessDetector destroySDK];
}

- (void)applicationDidBecomeActive:(NSNotification *)noti {
    [self resetFaceCheck];
}

- (void)setUpCameraLayer {
    CALayer *viewLayer = [self.view layer];
    CALayer *movieLayer = [self.livenessDetector videoPreview];
    movieLayer.frame = [self.cameraMasking getMaskingShowRect];
    [viewLayer insertSublayer:movieLayer below:self.cameraMasking.layer];
}

- (void)initMenuView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initMaskingView];
    
    // 设置头部菜单
    UIView *menuView = [[UIView alloc] init];
    menuView.translatesAutoresizingMaskIntoConstraints = NO;
    menuView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:menuView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:menuView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:menuView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:menuView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:20]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:menuView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant:kMenuHeight]];
    
    // 设置返回按钮
    UIImage *butImage = kFaceImage(@"Face_backBut");
    UIButton *backButton = [[UIButton alloc]init];
    [backButton setBackgroundColor:[UIColor clearColor]];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [backButton setImage:butImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToAppAnimatedWhenClickBlack:) forControlEvents:UIControlEventTouchDown];
    [menuView addSubview:backButton];
    
    [menuView addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:menuView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [menuView addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:menuView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [menuView addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:menuView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [backButton addConstraint:[NSLayoutConstraint constraintWithItem:backButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:backButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [self initActionTipsView];
}

- (void)initMaskingView {
    _cameraMasking = [[PACameraMaskingView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_cameraMasking];
}

- (void)initActionTipsView {
    _actionTipsView = [[PAActionTipsView alloc] initWithText:preModel.isShowText
                                                       timer:preModel.isShowTimer
                                                   animation:preModel.isShowAnimation];
    _actionTipsView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_actionTipsView];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_actionTipsView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_actionTipsView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:kActionTipsTopSpace]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_actionTipsView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_actionTipsView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    YTLog(@"----PAFACECHECKVC----dealloc-----");
}

- (void)resetFaceCheck {
    if (isCheck_) {
        return;
    }
    
    if (_completeBtn) {
        _completeBtn.hidden = YES;
    }
    
    [self.livenessDetector resetWithDetectType:(OCFTFaceDetectActionType)preModel.actionType];
}

#pragma mark - voice
// 初始化语音播放器
- (void)initAVSpeech {
    if (!preModel.isShowVoice) {
        return;
    }
    self.synthesizer = [[AVSpeechSynthesizer alloc] init];
    self.synthesizer.delegate = self;
}

/**
 *  停止播放
 */
- (void)voicePlayerStop{
    _playVoice = NO;
    
    if (self.synthesizer.speaking) {
        
        [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        
    }
}

- (void)playVoiceWithType:(OCFTFaceDetectActionType)types {
    
    switch(types){
        case OCFT_COLLECTFACE:
        {
            //soundStr = @"2_eye";
            _soundString = @"请正对摄像头";
            break;
        }
        case OCFT_MOUTH:
        {
            //soundStr = @"5_openMouth";
            _soundString = @"请缓慢张嘴";
            break;
        }
        case OCFT_EYEBLINK:
        {
            //soundStr = @"4_headshake";
            _soundString = @"请缓慢眨眼";
            break;
        }
        default:
        {
            return;
            break;
        }
    }
    
    [self playVoiceWithString:_soundString];
}

- (void)playVoiceWithString:(NSString *)string {
    [self voicePlayerStop];
    [self textToAudioWithStirng:string];
}

/**
 *  Text转语音
 */
-(void)textToAudioWithStirng:(NSString*)textString{
    self.utterance = [AVSpeechUtterance speechUtteranceWithString:textString];
    //设置语速快慢
    self.utterance.rate = 0.4;
    //语音合成器会生成音频
    [self.synthesizer speakUtterance:self.utterance];
    
    _playVoice = YES;
}

#pragma mark - AVSpeechSynthesizerDelegate
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {
    _playVoice = NO;
}

#pragma mark --------------- 以下为宿主APP需要关注的代码 ---------------
#pragma mark ---- FaceCheck初始化
- (void)createFacecheck{
    
    self.livenessDetector = [OCFTFaceDetector getDetectorWithDetectType:(OCFTFaceDetectActionType)preModel.actionType delegate:self];
    NSString *version = [[OCFTFaceDetector getSDKInfo] version];
    NSLog(@"%------@", version);
}

#pragma mark - OCFTFaceDetectProtocol
// 【必要实现】检测成功回调
-(void)onDetectionSuccess:(OCFTFaceDetectionFrame *)faceInfo {
    [self successWithInfo:(OCFTFaceDetectionFrame *)faceInfo];
}

// 【必要实现】检测失败回调
-(void)onDetectionFailed:(OCFTFaceDetectFailedType)failedType {
    [self checkFail:[self errorType:failedType]];
}

// 【必要实现】辅助提示信息接口，主要包装一些附加功能（比如光线过亮／暗的提示），以便增强活体检测的质量
-(void)onSuggestingOptimization:(OCFTFaceDetectOptimizationType)type {
    [self setUpStateLabelWithOption:type];
}

// 【必要实现】提示用户做活体动作（目前支持动嘴、摇头、或随机取其一，options字段目前送入nil，该字段作为后续的拓展字段）
-(void)onDetectionChangeAnimation:(OCFTFaceDetectActionType)type options:(NSDictionary*)options {
    // 如有倒计时设置，应在开始检测时，启动倒计时
    [self starAnimation:type];
    
}

// 【可选实现】表示已经开始活体检测info为预留字段，目前为nil
-(void)onStartDetection:(NSDictionary *)info {
    // 开始执行显示
    [self starAnimation:OCFT_COLLECTFACE];
}

#pragma mark --------------- 以上为宿主APP需要关注的代码 ---------------
- (void)setUpStateLabelWithOption:(OCFTFaceDetectOptimizationType)type {
    
    NSString *stringText;
    switch (type) {
        case OCFT_DETECT_STAYSTILL:
            stringText = @"请保持相对静止";
            
            break;
            
        case OCFT_DETECT_ERROR_CLOSE:
            stringText = @"请稍微退后";
            
            break;
            
        case OCFT_DETECT_ERROR_BRIGHT:
            stringText = @"环境光线太强";
            break;
            
        case OCFT_DETECT_ERROR_DARK:
            stringText = @"环境光线太暗";
            break;
            
        case OCFT_NO_FACE:
            stringText = @"请正对摄像头";
            break;
            
        case OCFT_DETECT_ERROR_FUZZY:
            stringText = @"图片过于模糊";
            break;
            
        case OCFT_DETECT_MULTIFACE:
            stringText = @"采集框存在多人";
            break;
            
        case OCFT_DETECT_NORMAL:
            stringText = @"检测中";
            break;
            
        case OCFT_DETECT_ERROR_MO:
            stringText = @"不能张着嘴";
            break;
            
        case OCFT_DETECT_ERROR_EYE:
            stringText = @"眼睛不能闭着";
            break;
            
        case OCFT_DETECT_ERROR_YL:
            stringText = @"角度过于偏左";
            break;
            
        case OCFT_DETECT_ERROR_YR:
            stringText = @"角度过于偏右";
            break;
            
        case OCFT_DETECT_ERROR_PU:
            stringText = @"角度过于仰头";
            break;
            
        case OCFT_DETECT_ERROR_PD:
            stringText = @"角度过于低头";
            break;
            
        case OCFT_DETECT_REFLECTIVE:
            stringText = @"反光严重";
            break;
    }
    
    if (preModel.isShowText) {
        self.actionTipsView.textRemindLabel.text = stringText;
    }
    
    if (preModel.isShowVoice && !_playVoice) {
        [self playVoiceWithString:stringText];
    }
    
#ifdef DEBUG
    NSLog(@"tips : %@", stringText);
#endif
}

// 开始动画
- (void)starAnimation:(OCFTFaceDetectActionType)type {
    _starLiveness = YES;
    
    // 切换提醒内容
    [self.actionTipsView willChangeAnimation:type outTime:0];
    [self playRemind];
    
    // 切换语音
    if (preModel.isShowVoice) {
        [self playVoiceWithType:type];
    }
}

// 启动提醒界面
- (void)playRemind {
    __weak typeof(self) weakSelf = self;
    [self.actionTipsView startingRemindWithOutTimerBlock:^{
        MAIN_ACTION((^{
            [weakSelf.livenessDetector destroySDK];
            [weakSelf checkFail:PAFaceCheckFailTypeTimeout];
        }));
    }];
}

// 关闭动画
- (void)stopAnimations{
    _starLiveness = NO;
    
    // 关闭动画
    [self.actionTipsView stopRemind];
    
    // 关闭语音
    [self voicePlayerStop];
}

#pragma mark - 返回按钮触发事件
- (void)backToAppAnimatedWhenClickBlack:(UIButton*)blackB{
    [self checkFail:PAFaceCheckFailTypeClientCancel];
    [self dismissViewControllerAnimated:YES completion:nil];
    
     _synthesizer = nil;
    
    _utterance = nil;
    _voiceType = nil;
    
    // 销毁SDK
    [_livenessDetector destroySDK];
    _livenessDetector = nil;
    
#ifdef DEBUG
    NSLog(@"destroySDK");
#endif
}

#pragma mark - 成功处理
- (void)successWithInfo:(OCFTFaceDetectionFrame *)info {
    // 停止动画
    [self stopAnimations];
    
    // 处理结果
    [self doSuccessWithInfo:info];
}

- (void)doSuccessWithInfo:(OCFTFaceDetectionFrame *)info {
    isCheck_ = YES;
    
    // 显示图片
    CGRect rect = [self.cameraMasking getMaskingShowRect];
    self.successImageLayer.frame = rect;
    self.successImageLayer.contents = info.faceImage.targetFaceImage;
    [self.view.layer insertSublayer:self.successImageLayer below:self.cameraMasking.layer                                                                                                                                                                                                          ];
    
    // 存储图片到系统相册
    if (info.faceImage) {
        UIImageWriteToSavedPhotosAlbum(info.faceImage.targetImage, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
        UIImageWriteToSavedPhotosAlbum(info.faceImage.targetFaceImage, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    }
    if (info.eyeImage) {
        UIImageWriteToSavedPhotosAlbum(info.eyeImage.targetImage, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    }
    if (info.moImage) {
        UIImageWriteToSavedPhotosAlbum(info.moImage.targetImage, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    }
    
    
    // 显示成功button
    [self showCompleteBtnWithDict:@{kStateDictTitleKey : @"检测成功",
                                    kStateDictColorKey : UIColorFromRGB(0x6177DC),
                                    kStateDictBgColorKey : YT_ColorWithRGB(97, 119, 200, 0.15),
                                    kStateDictImageKey : kFaceImage(@"success_icon"),
                                    }];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

#pragma mark ---  失败处理
- (PAFaceCheckFailType)errorType:(OCFTFaceDetectFailedType)ocftFailType {
    PAFaceCheckFailType failType;
    switch (ocftFailType) {
        case OCFT_CAMERA_AUTH_FAIL:
            failType = PAFaceCheckFailTypeUnable;
            break;
            
        case OCFT_DISCONTINUIIY_ATTACK:
            failType = PAFaceCheckFailTypeDisAttack;
            break;
            
        case OCFT_SDK_ERROR:
            failType = PAFaceCheckFailTypeError;
            break;
    }
    
    return failType;
}

- (void)checkFail:(PAFaceCheckFailType)failType{
    isCheck_ = YES;
    
    [self stopAnimations];
    
    NSDictionary *stateDict = [self getButtonStateWithFailType:failType];
    if (!stateDict) {
        return ;
    }
    
    [self showCompleteBtnWithDict:stateDict];
}

- (NSDictionary *)getButtonStateWithFailType:(PAFaceCheckFailType)failType {
    NSString *title;
    UIColor *color;
    UIImage *image;
    UIColor *bgColor;
    
    switch (failType) {
        case PAFaceCheckFailTypeClientCancel:
            return nil;
            break;
            
        case PAFaceCheckFailTypeUnable:
            title = @"未开启照相机权限";
            color = UIColorFromRGB(0xFF756C);
            image = kFaceImage(@"fail_icon");
            bgColor = YT_ColorWithRGB(255, 151, 144, 0.15);
            break;
            
        case PAFaceCheckFailTypeTimeout:
            title = @"检测超时";
            color = UIColorFromRGB(0xFFB842);
            image = kFaceImage(@"processing_icon");
            bgColor = YT_ColorWithRGB(255, 207, 129, 0.15);
            break;
            
        case PAFaceCheckFailTypeDisAttack:
            title = @"检测失败";
            color = UIColorFromRGB(0xFF756C);
            image = kFaceImage(@"fail_icon");
            bgColor = YT_ColorWithRGB(255, 151, 144, 0.15);
            break;
            
        case PAFaceCheckFailTypeError:
            title = @"检测失败";
            color = UIColorFromRGB(0xFFB842);
            image = kFaceImage(@"fail_icon");
            bgColor = YT_ColorWithRGB(255, 207, 129, 0.15);
            break;
    }
    
    return @{kStateDictTitleKey : title,
             kStateDictColorKey : color,
             kStateDictImageKey : image,
             kStateDictBgColorKey : bgColor,
             };
}

#pragma mark - 结果BUTTON显示
- (void)showCompleteBtnWithDict:(NSDictionary *)stateDict {
    if (!_completeBtn || _completeBtn.hidden) {
        _completeBtn.hidden = NO;
        [self.completeBtn setTitle:stateDict[kStateDictTitleKey] forState:UIControlStateNormal];
        [self.completeBtn setTitleColor:stateDict[kStateDictColorKey] forState:UIControlStateNormal];
        [self.completeBtn setBackgroundColor:stateDict[kStateDictBgColorKey]];
        [self.completeBtn setImage:stateDict[kStateDictImageKey] forState:UIControlStateNormal];
    }
    
    // 播放结果语音
    [self playVoiceWithString:stateDict[kStateDictTitleKey]];
}

#pragma mark - 懒加载
- (UIButton *)completeBtn {
    if (!_completeBtn) {
        CGFloat btnWitdh = kScaleWidth(290);
        CGFloat btnHeight = kScaleHeight(60);
        CGFloat btnTop =kScaleHeight(431);
        
        _completeBtn.titleLabel.font = [UIFont systemFontOfSize:22];
        _completeBtn.userInteractionEnabled = NO;
        _completeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _completeBtn.layer.cornerRadius = 6;
        [_completeBtn.layer setMasksToBounds:YES];
        _completeBtn.frame = CGRectMake((kScreenWidth - btnWitdh) / 2, btnTop, btnWitdh, btnHeight);
        [self.view addSubview:_completeBtn];
    }
    
    return _completeBtn;
}

- (CALayer *)successImageLayer {
    if (!_successImageLayer) {
        _successImageLayer = [CALayer layer];
    }
    return _successImageLayer;
}
@end

