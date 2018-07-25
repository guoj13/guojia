//
//  OCFTFaceDetector.h
//  OCFTFaceDetect
//
//  Created by PA on 2017/9/27.
//  Copyright © 2017年 Shanghai OneConnect Technology CO,LTD. All Rights Reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/*!
 * 检测失败类型
 */
typedef enum OCFTFaceDetectFailedType {
    
    OCFT_DISCONTINUIIY_ATTACK = 301,    //非连续性攻击（可理解为用户晃动过大）
    OCFT_CAMERA_AUTH_FAIL,              //相机权限获取失败
    OCFT_SDK_ERROR                      //SDK异常
    
} OCFTFaceDetectFailedType;


/**
 * 检测过程中的提示
 */
typedef enum OCFTFaceDetectOptimizationType {
    
    OCFT_DETECT_NORMAL = 101,                     // 正常
    OCFT_DETECT_STAYSTILL,                        // 请保持相对静止
    
    OCFT_DETECT_ERROR_DARK,                       // 过于灰暗
    OCFT_DETECT_ERROR_BRIGHT,                     // 过于明亮
    OCFT_DETECT_ERROR_CLOSE,                      // 过于靠近
    OCFT_DETECT_ERROR_FUZZY,                      // 过于模糊
    
    OCFT_DETECT_ERROR_MO,                         // 正脸不合格,正脸不能张着嘴
    OCFT_DETECT_ERROR_EYE,                        // 正脸不合格,眼睛不能闭着
    OCFT_DETECT_ERROR_YL,                         // 正脸不合格,角度过于偏左
    OCFT_DETECT_ERROR_YR,                         // 正脸不合格,角度过于偏右
    OCFT_DETECT_ERROR_PU,                         // 正脸不合格,角度过于仰头
    OCFT_DETECT_ERROR_PD,                         // 正脸不合格,角度过于低头
    OCFT_DETECT_MULTIFACE,                        // 多人存在
    OCFT_DETECT_REFLECTIVE,                       // 反光严重
    
    OCFT_NO_FACE,                                 // 没有人脸
    
} OCFTFaceDetectOptimizationType;

/*!
 * 检测动作类型
 */
typedef enum OCFTFaceDetectActionType {
    
    OCFT_COLLECTFACE = 200,                   //采集正脸
    OCFT_MOUTH = 201,                         //张嘴提示
    OCFT_EYEBLINK =  202,                     //眨眼
    OCFT_RANDOM =  203,                       //单一随机
    OCFT_ALLRANDOM = 204                      //全部随机
    
}OCFTFaceDetectActionType;

@interface OCFTFaceImageInfo : NSObject
@property (readonly) UIImage *targetImage;            /** 检测目标图片 */
@property (readonly) UIImage *targetFaceImage;        /** 检测目标人脸区域图片 */
@property (readonly) int result;                      /** 检脸结果 */
@property (readonly) int faceNum;                     /** 人脸个数 */
@property (readonly) CGRect face_rect;                /** 人脸位置 */
@property (readonly) CGFloat confidence;              /** 图片综合质量 */
@property (readonly) float pitch;                     /** 上下角度 */
@property (readonly) float yaw;                       /** 左右角度 */
@property (readonly) int roll;                        /** 旋转角度 */
@property (readonly) int brightness;                  /** 亮度值 */
@property (readonly) int fuzz;                        /** 模糊值 */
@property (readonly) float mouth_open_value;          /** 张嘴程度 */
@property (readonly) float eye_blink_value_left;      /** 眨眼程度 */
@property (readonly) float eye_blink_value_right;     /** 眨眼程度 */
@end

@interface OCFTFaceDetectionFrame : NSObject
@property (readonly) OCFTFaceImageInfo *faceImage;  /** 正脸图片 */
// 动作图片
@property (readonly) OCFTFaceImageInfo *moImage;      /** 张嘴图片 */
@property (readonly) OCFTFaceImageInfo *eyeImage;     /** 眨眼图片 */

@end

@interface OCFTSDKInfo : NSObject
@property (readonly) NSString *version;                  /** SDK版本号 **/
@end

@protocol OCFTFaceDetectProtocol <NSObject>
@required
-(void)onDetectionFailed:(OCFTFaceDetectFailedType)failedType;//识别失败回调
@required
-(void)onSuggestingOptimization:(OCFTFaceDetectOptimizationType)type;//辅助提示信息接口，主要包装一些附加功能（比如光线过亮／暗的提示），以便增强活体检测的质量
@required
-(void)onDetectionChangeAnimation:(OCFTFaceDetectActionType)type options:(NSDictionary*)options;//提示用户做活体动作（目前支持动嘴、摇头、或随机取其一，options字段目前送入nil，该字段作为后续的拓展字段）
@required
-(void)onDetectionSuccess:(OCFTFaceDetectionFrame *)faceInfo;
@optional
-(void)onStartDetection:(NSDictionary *)info;//表示已经开始活体检测info为预留字段，目前为nil

@end

@interface OCFTFaceDetector : NSObject
+ (instancetype)getDetectorWithDetectType:(OCFTFaceDetectActionType)detectType delegate:(id<OCFTFaceDetectProtocol>)delegate;//初始化SDK方法
+ (OCFTSDKInfo *)getSDKInfo;//获取sdk信息
- (AVCaptureVideoPreviewLayer *)videoPreview;//获取视频展示界面
- (void)resetWithDetectType:(OCFTFaceDetectActionType)detectType;//重置SDK状态
- (void)destroySDK; // 销毁相关信息，防止内存泄漏。
@end
