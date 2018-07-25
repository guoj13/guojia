//
//  PACameraMaskingView.m
//  PAFaceSDKDemo
//
//  Created by 朱敏(EX-ZHUMIN004) on 2017/11/10.
//  Copyright © 2017年 pingan. All rights reserved.
//

#import "PACameraMaskingView.h"
#import "PAZCLDefineTool.h"

#define kCameraDrawWidth     kScaleWidth(220)
#define kMaskingTopSpace     kScaleHeight(95)
#define kMaskingHeight       kScaleHeight(286)

@implementation PACameraMaskingView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setNeedsDisplay];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGRect coverRect  = CGRectMake((kScreenWidth - kCameraDrawWidth) / 2 , kMaskingTopSpace, kCameraDrawWidth, kMaskingHeight);
    CGSize cornerRadii = CGSizeMake(kScaleWidth(110), kScaleWidth(110));
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:coverRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:cornerRadii];
    cornerPath.lineWidth = 10;
    cornerPath.lineCapStyle = kCGLineCapRound;
    cornerPath.lineJoinStyle = kCGLineJoinRound;
    UIColor *strokColor = UIColorFromRGB(0x6177DC);
    [strokColor setStroke];
    [cornerPath stroke];
    [cornerPath appendPath:[UIBezierPath bezierPathWithRect:rect]];
    cornerPath.usesEvenOddFillRule = YES;
    UIColor *fillColor = [UIColor whiteColor];
    [fillColor setFill];
    [cornerPath fill];
}

- (CGRect)getMaskingShowRect {
    return CGRectMake((kScreenWidth - kCameraDrawWidth) / 2 , kMaskingTopSpace, kCameraDrawWidth, kMaskingHeight);
}
@end
