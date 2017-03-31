//
//  TableViewCell.m
//  NT-文件读取解析写入
//
//  Created by Nic Tang on 2016/11/27.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "TableViewCell.h"

@interface TableViewCell ()
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,weak) UIButton *accessoryButton;
@end

@implementation TableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    self.selectionStyle = UITableViewCellSelectionStyleBlue;
//    self.selectionStyle = UITableViewCellSelectionStyleGray;
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
//    self.selectionStyle = UITableViewCellSelectionStyleDefault;
}

//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        
//    }
//    return self;
//}
- (instancetype)init
{
    self = [[[NSBundle mainBundle]loadNibNamed:@"TableViewCell" owner:nil options:nil]lastObject];
    
    return self;
}

- (void)addButton
{
    CGRect frame = CGRectMake(0, 0, 50, 50);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    
    [button setTitle:@"1" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
    button.layer.cornerRadius = 25;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.accessoryButton = button;
    
    self.accessoryView = self.accessoryButton;
}
/*
 * 设置子控件的frame
 */
 - (void)buttonClick:(UIButton *)button
{
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
- (void)setGrade:(Grade *)grade
{
    _grade = grade;
    //学年-学期
    NSString *termYear = [NSString stringWithFormat:@"%@学年第 %ld 学期",grade.year,grade.term];
    //一个字符串添加两处属性，颜色不同
    NSMutableAttributedString *attribute = [self setAttributeWithString:termYear InRange:NSMakeRange(0, grade.year.length) dict:@{NSForegroundColorAttributeName:[UIColor redColor]}];
    //需要用可变属性字符串，才能设置多处样式不同
    NSRange range = [termYear rangeOfString:[NSString stringWithFormat:@"%ld",grade.term] options:NSBackwardsSearch];
    [attribute addAttributes:@{NSForegroundColorAttributeName:[UIColor greenColor]} range:range];
    [self.termYearLabel setAttributedText:attribute];
    
    //课程代码
    NSString *codeStr = [NSString stringWithFormat:@"课程代码：%@",grade.courseCode];
    NSRange codeRange = [codeStr rangeOfString:grade.courseCode options:NSBackwardsSearch];
    [self.codeLabel setAttributedText:[self setAttributeWithString:codeStr InRange:codeRange dict:@{NSUnderlineStyleAttributeName:@(1),NSUnderlineColorAttributeName:[UIColor redColor]}]];
    //课程性质
    NSShadow *shadow = [[NSShadow alloc]init];
    shadow.shadowColor = [UIColor yellowColor];
    shadow.shadowOffset = CGSizeMake(10, 10);
    shadow.shadowBlurRadius = 5;
    [self.nameLabel setAttributedText:[self setAttributeWithString:grade.courseName InRange:NSMakeRange(0, grade.courseName.length) dict:@{NSShadowAttributeName:shadow}]];
    self.attributeLabel.text = [NSString stringWithFormat:@"课程性质：%@",grade.attribute];
    //学分
    NSString *creditText = [NSString stringWithFormat:@"学分：%.1f",grade.credit];
    NSRange creditRange = [creditText rangeOfString:[NSString stringWithFormat:@"%.1f",grade.credit] options:NSBackwardsSearch];
    [self.creditLabel setAttributedText:[self setAttributeWithString:creditText InRange:creditRange dict:@{NSBackgroundColorAttributeName:[UIColor magentaColor],NSFontAttributeName:[UIFont systemFontOfSize:19]}]];
    //分数
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld",grade.score];
    
    //计数器
    self.countButton.layer.cornerRadius = 15;
    self.countButton.layer.borderWidth = 1;
    self.countButton.layer.borderColor = [UIColor purpleColor].CGColor;
    
    self.accessoryButton.hidden = !grade.isRead;
    if (!grade.isRead) {
        [self.accessoryButton removeFromSuperview];
        self.accessoryView = nil;
    }else
    {
        [self addButton];
    }
    
//    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
//    //UITableView滑动时，添加以下代码则定时器照常工作，否则暂停
//    [[NSRunLoop currentRunLoop]addTimer:_timer forMode:NSRunLoopCommonModes];
}
- (void)updateTime
{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *dateString = [format stringFromDate:date];
    self.nowTimeLabel.text = dateString;
    self.nowTimeLabel.layer.borderWidth = 2;
    self.nowTimeLabel.layer.borderColor = [UIColor blueColor].CGColor;
    self.nowTimeLabel.layer.cornerRadius = 6;
}

- (NSMutableAttributedString *)setAttributeWithString:(NSString *)string InRange:(NSRange)range dict:(NSDictionary *)dict
{
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc]initWithString:string];
    [attri addAttributes:dict range:range];
    return attri;
}
@end
