//
//  Grade.h
//  NT-文件读取解析写入
//
//  Created by Nic Tang on 2016/10/18.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface Grade : NSObject
//学年
@property (nonatomic,copy) NSString *year;
//学期
@property (nonatomic,assign) NSInteger term;
//课程代码
@property (nonatomic,copy) NSString *courseCode;
//课程名称
@property (nonatomic,copy) NSString *courseName;
//课程属性
@property (nonatomic,copy) NSString *attribute;
//学分
@property (nonatomic,assign) CGFloat credit;
//成绩
@property (nonatomic,assign) NSInteger score;

//已读、未读标记
@property (nonatomic,assign,getter=isRead) BOOL read;

@end
