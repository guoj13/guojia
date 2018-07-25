//
//  PAFaceCheckVC.h
//  PAFaceSDKDemo
//
//  Created by 朱敏(EX-ZHUMIN004) on 2017/11/9.
//  Copyright © 2017年 pingan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PAFaceCheckPreModel;

/*!
 *  活体检测视图控制器
 */
@interface PAFaceCheckVC : UIViewController
- (instancetype)initFaceCheckWithModel:(PAFaceCheckPreModel *)model;
@end
