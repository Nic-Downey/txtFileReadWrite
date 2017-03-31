//
//  TableViewCell.h
//  NT-文件读取解析写入
//
//  Created by Nic Tang on 2016/10/18.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Grade.h"

@interface TableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *termYearLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *attributeLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *countButton;
@property (weak, nonatomic) IBOutlet UILabel *nowTimeLabel;

@property (nonatomic,strong) Grade *grade;

@end
