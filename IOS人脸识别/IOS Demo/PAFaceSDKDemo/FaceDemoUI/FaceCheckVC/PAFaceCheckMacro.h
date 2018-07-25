//
//  PAFaceCheckMacro.h
//  PAFaceSDKDemo
//
//  Created by 朱敏(EX-ZHUMIN004) on 2017/11/10.
//  Copyright © 2017年 pingan. All rights reserved.
//

#ifndef PAFaceCheckMacro_h
#define PAFaceCheckMacro_h

typedef  NS_ENUM(NSInteger, PAFaceCheckFailType) {
    
    PAFaceCheckFailTypeUnable = -1,    //用户权限未开
    PAFaceCheckFailTypeDisAttack = 1, //非连续性攻击，请重新检测
    PAFaceCheckFailTypeTimeout,       //动作超时，请重新检测
    PAFaceCheckFailTypeError,         //检测出错
    PAFaceCheckFailTypeClientCancel,  //取消检测
};


#endif /* PAFaceCheckMacro_h */
