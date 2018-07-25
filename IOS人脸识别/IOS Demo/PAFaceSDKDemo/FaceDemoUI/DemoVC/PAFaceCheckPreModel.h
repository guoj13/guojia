//
//  PAFaceCheckPreModel.h
//  PAFaceSDKDemo
//
//  Created by 朱敏(EX-ZHUMIN004) on 2017/11/9.
//  Copyright © 2017年 pingan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    PAFaceCheckActionTypeFace = 200,
    PAFaceCheckActionTypeMouse = 201,
    PAFaceCheckActionTypeEyeLink = 202,
    PAFaceCheckActionTypeRandom = 203,
    PAFaceCheckActionTypeAllRandom = 204
} PAFaceCheckActionType;

@interface PAFaceCheckPreModel : NSObject
// actionType
@property (nonatomic, assign) PAFaceCheckActionType actionType;
// show timer
@property (nonatomic, assign) BOOL isShowTimer;
// option
@property (nonatomic, assign) BOOL isShowText;
@property (nonatomic, assign) BOOL isShowVoice;
@property (nonatomic, assign) BOOL isShowAnimation;

@end
