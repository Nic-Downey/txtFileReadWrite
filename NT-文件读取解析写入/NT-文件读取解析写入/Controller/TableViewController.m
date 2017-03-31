//
//  TableViewController.h
//  NT-文件读取解析写入
//
//  Created by Nic Tang on 2016/11/27.
//  Copyright © 2016年 Nic. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"
#import "Grade.h"
#define MarkToNotRead @"标为未读"
#define MarkToRead @"标为已读"
#define KscreenWidth [UIScreen mainScreen].bounds.size.width
#define KscreenHeight [UIScreen mainScreen].bounds.size.height

@interface TableViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (nonatomic,strong) NSMutableArray *gradesArray;
@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,weak) UIButton *selButton;
@property (nonatomic,weak) UIBarButtonItem *cancelButton;
@property (nonatomic,weak) UIBarButtonItem *deleteButton;

@property (nonatomic,assign) NSInteger count;
@property (nonatomic,weak) UIButton *upButton;
@property (nonatomic,weak) UIButton *downButton;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"这是？Just guess";
    [self createUI];
    [self configureNavigationBarButtons];
    [self addOffsetButtons];
}
#pragma mark - 数组懒加载
- (NSMutableArray *)gradesArray
{
    if (!_gradesArray) {
        _gradesArray = [NSMutableArray arrayWithArray:[self dataArrayFromLocal]];
    }
    return _gradesArray;
}
#pragma mark - 加载本地数据
- (NSArray *)dataArrayFromLocal
{
    NSMutableArray *dataArray = [NSMutableArray array];
    NSString *path = [[NSBundle mainBundle]pathForResource:@"大学成绩单.txt" ofType:nil];
    NSString *fileString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSString *noNewLineString = [fileString stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];//去掉回车符
    NSArray *modelArray = [noNewLineString componentsSeparatedByString:@"\n"];
    for (NSString *subString in modelArray) {
        //去掉首尾空格
        NSString *sub = [subString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray *gradeArray = [sub componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //谓词逻辑，去掉字符串中间的多个空格
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self <> ''"];
        NSArray *gradeArr = [gradeArray filteredArrayUsingPredicate:predicate];
        Grade *grade = [[Grade alloc]init];
        for (int i = 0; i<gradeArr.count; i++) {
            if (i==0) {
                grade.year = [gradeArr firstObject];
            }else if (i==1){
                grade.term = [[gradeArr objectAtIndex:1] integerValue];
            }else if (i==2){
                grade.courseCode = [gradeArr objectAtIndex:2];
            }else if (i==3){
                grade.courseName = [gradeArr objectAtIndex:3];
            }else if (i==4){
                grade.attribute = [gradeArr objectAtIndex:4];
            }else if (i==5){
                grade.credit = [[gradeArr objectAtIndex:5] floatValue];
            }else if (i==gradeArr.count-1){
                grade.score = [[gradeArr lastObject] integerValue];
            }
        }
        [dataArray addObject:grade];
    }
    return dataArray;
}
#pragma mark - 创建tableView
- (void)createUI {
    _tableView = [[UITableView alloc]init];
    _tableView.frame = CGRectMake(0, 0, KscreenWidth, KscreenHeight);
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    //编辑模式下允许多选
    _tableView.allowsMultipleSelectionDuringEditing = YES;
}
#pragma mark - 配置导航条按钮
- (void)configureNavigationBarButtons
{
    //右上角:自定义按钮
    UIButton *selButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selButton setTitle:@"批量操作" forState:UIControlStateNormal];
    [selButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    CGRect textFrame = [selButton.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, 37) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19]} context:nil];
    CGFloat padding = 3;
    CGFloat buttonH = textFrame.size.height + 2.3*padding;
    CGFloat buttonW = textFrame.size.width + 2*padding;
    CGRect buttonFrame = CGRectMake(textFrame.origin.x, textFrame.origin.x, buttonW, buttonH);
    selButton.frame = buttonFrame;
    selButton.layer.borderColor = [UIColor redColor].CGColor;
    selButton.layer.borderWidth = 2;
    selButton.layer.cornerRadius = 5;
    [selButton addTarget:self action:@selector(multipleSelect:) forControlEvents:UIControlEventTouchUpInside];
    self.selButton = selButton;
    UIBarButtonItem *selBarButton = [[UIBarButtonItem alloc]initWithCustomView:self.selButton];
    self.navigationItem.rightBarButtonItem = selBarButton;
    
    //左上角：直接创建
    UIBarButtonItem *delete = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(multipleDelete:)];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    self.cancelButton = cancel;
    self.deleteButton = delete;
    
    delete.enabled = NO;
    cancel.enabled = NO;
    self.navigationItem.leftBarButtonItems = @[delete,cancel];
}
#pragma mark - 批量选择
- (void)multipleSelect:(UIButton *)item
{
    //开启编辑模式
    [self.tableView setEditing:YES animated:YES];
    self.deleteButton.title = @"删除";
    self.cancelButton.title = @"取消";
    
    if([item.currentTitle isEqualToString:@"批量操作"]){
        [item setTitle:@"全选" forState:UIControlStateNormal];
        [self.tableView setEditing:YES animated:YES];
    }else if ([item.currentTitle isEqualToString:@"全选"]){
        for (int i=0; i<self.gradesArray.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            //选中所有的行
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        [item setTitle:@"反选" forState:UIControlStateNormal];
        self.count = self.gradesArray.count;
        self.deleteButton.title = self.count?[NSString stringWithFormat:@"删除%ld",self.count]:@"删除";
    }else if ([item.currentTitle isEqualToString:@"反选"]){
        for (int i=0; i<self.gradesArray.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            //取消选中所有的行
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        [item setTitle:@"全选" forState:UIControlStateNormal];
        self.count = 0;
        self.deleteButton.title = @"删除";
    }else if ([item.currentTitle isEqualToString:@"复原"]){
        [item setTitle:@"批量操作" forState:UIControlStateNormal];
        self.count = 0;
        self.deleteButton.title = @"";
        self.cancelButton.title = @"";
        [self addOffsetButtons];
        if (self.gradesArray.count) {
            [self.gradesArray removeAllObjects];
        }else{
            [self.gradesArray addObjectsFromArray:[self dataArrayFromLocal]];
        }
        [self.tableView setEditing:NO];
        [self.tableView reloadData];
    }
    //设置左边可用与否
    self.deleteButton.enabled = self.tableView.indexPathsForSelectedRows.count;
    self.cancelButton.enabled = self.tableView.isEditing;
}
#pragma mark - 批量删除
- (void)multipleDelete:(UIBarButtonItem *)item
{
    NSMutableArray *tempDataArray = [NSMutableArray array];
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        //不能直接在此删除模型，因为一边遍历一边删除，数组中对象的索引会变化
        [tempDataArray addObject:self.gradesArray[indexPath.row]];
    }
    //删除模型
    [self.gradesArray removeObjectsInArray:tempDataArray];
    
    //刷新表格
    [self.tableView deleteRowsAtIndexPaths:self.tableView.indexPathsForSelectedRows withRowAnimation:UITableViewRowAnimationTop];
    //退出编辑模式
    [self.tableView setEditing:NO animated:YES];
    
    //如果没有数据，则隐藏
    if (!self.gradesArray.count) {
        [self.selButton setTitle:@"复原" forState:UIControlStateNormal];
        self.deleteButton.title = @"";
        self.cancelButton.title = @"";
        self.deleteButton.enabled = NO;
        self.cancelButton.enabled = NO;
        [self.upButton removeFromSuperview];
        [self.downButton removeFromSuperview];
        return;
    }
    //模型个数小于等于可见cell个数时，隐藏返回顶部、底部按钮
    if (self.gradesArray.count <= self.tableView.visibleCells.count) {
        self.downButton.hidden = YES;
        self.upButton.hidden = YES;
    }
    //修改右边文字
    [self.selButton setTitle:@"批量操作" forState:UIControlStateNormal];
    //设置左边可用与否
    self.count = 0;
    self.deleteButton.title = @"";
    self.cancelButton.title = @"";
    self.deleteButton.enabled = self.tableView.indexPathsForSelectedRows.count;
    self.cancelButton.enabled = NO;
}
#pragma mark - 取消，退出编辑模式
- (void)cancel:(UIBarButtonItem *)item
{
    [self.tableView setEditing:NO animated:YES];
    [self.selButton setTitle:@"批量操作" forState:UIControlStateNormal];
    self.deleteButton.title = @"";
    self.cancelButton.title = @"";
    self.deleteButton.enabled = NO;
    self.count = 0;
    item.enabled = NO;
}
#pragma mark - 添加返回顶部、底部按钮
- (void)addOffsetButtons
{
    CGRect downFrame = CGRectMake(16, 72, 32, 32);
    UIButton *downButton = [self buttonByFrame:downFrame imageName:@"down" selector:@selector(moveToBottom:)];
    self.downButton = downButton;
    [self.view addSubview:downButton];
    
    CGFloat upWH = 32;
    CGFloat upX = KscreenWidth - upWH - 16;
    CGFloat upY = KscreenHeight  - upWH - 88;
    CGRect upFrame = CGRectMake(upX, upY, upWH, upWH);
    UIButton * upButton= [self buttonByFrame:upFrame imageName:@"up" selector:@selector(moveToTop:)];
    self.upButton = upButton;
    [self.view addSubview:upButton];
}
#pragma mark - 配置button
- (UIButton *)buttonByFrame:(CGRect)frame imageName:(NSString *)imageName selector:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_highlighted",imageName]] forState:UIControlStateHighlighted];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}
#pragma mark - 返回顶部
- (void)moveToTop:(UIButton *)upButton
{
    if (self.gradesArray.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}
#pragma mark - 返回底部
- (void)moveToBottom:(UIButton *)downButton
{
    if (self.gradesArray.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.gradesArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}
#pragma mark - UITableView数据源方法：多少行cell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.gradesArray.count;
}
#pragma mark - UITableView数据源方法：每一行返回怎样的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"score"];
    if (cell==nil) {
        cell = [[TableViewCell alloc]init];
    }
    Grade *grade = self.gradesArray[indexPath.row];
    cell.grade = grade;
    [cell.countButton setTitle:[NSString stringWithFormat:@"%ld",indexPath.row+1] forState:UIControlStateNormal];
    
    return cell;
}
#pragma mark - UITableView代理方法：每一行cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}
#pragma mark - 编辑模式下，每一行返回怎样的操作：插入／删除／其他
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    Grade *grade = self.dataArray[indexPath.row];
//    return [grade.courseName isEqualToString:@"十二道锋味"]?UITableViewCellEditingStyleDelete:UITableViewCellEditingStyleInsert;
//}
#pragma mark - 实现此方法，系统默认左滑时就能出现删除按钮
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleInsert) {
        Grade *grade = [[Grade alloc]init];
        grade.term = 2;
        grade.year = @"2015-2016";
        grade.courseCode = @"9527";
        grade.courseName = @"十二道锋味";
        grade.attribute = @"综艺美食";
        grade.credit = 3;
        grade.score = 93;
        //往模型数组添加模型
        [self.gradesArray insertObject:grade atIndex:indexPath.row+1];
        //增加新的indexPath
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:0];
        //更新这一行
        [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
    }else if (editingStyle == UITableViewCellEditingStyleDelete){
        [self.gradesArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}
#pragma mark - 系统默认的左滑时出现按钮的文字
- (NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexpath
{
    return @"删除";
}
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return !tableView.editing;
//}
#pragma mark - UITableView代理方法：选中某一行调用方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath:%ld--%ld",indexPath.row,tableView.indexPathsForSelectedRows.count);
    
    if (tableView.editing) {
        self.count++;
        self.deleteButton.enabled = tableView.indexPathsForSelectedRows.count;
        self.deleteButton.title = self.count?[NSString stringWithFormat:@"删除%ld",self.count]:@"删除";
        if (self.count==self.gradesArray.count) {
            [self.selButton setTitle:@"反选" forState:UIControlStateNormal];
        }
    }else
    {
        if (self.gradesArray.count) {
            [self alertToShowScoreDetail:indexPath];
        }
    }
}
#pragma mark - UITableView代理方法：取消选中某一行调用方法
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        self.count--;
        self.deleteButton.enabled = tableView.indexPathsForSelectedRows.count;
        self.deleteButton.title = self.count?[NSString stringWithFormat:@"删除%ld",self.count]:@"删除";
    }
    NSLog(@"didDeselectRowAtIndexPath:%ld--%ld",indexPath.row,tableView.indexPathsForSelectedRows.count);
}
#pragma mark - 每一行左滑时显示什么样的按钮（单独实现此方法，左滑出现多个按钮）
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //删除
    UITableViewRowAction *deleAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self.gradesArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (!self.gradesArray.count) {
            [self.selButton setTitle:@"复原" forState:UIControlStateNormal];
            self.deleteButton.title = @"";
            self.cancelButton.title = @"";
            self.deleteButton.enabled = NO;
            self.cancelButton.enabled = NO;
            [self.upButton removeFromSuperview];
            [self.downButton removeFromSuperview];
        }
        //模型个数小于等于可见cell个数时，隐藏返回顶部、底部按钮
        if (self.gradesArray.count <= self.tableView.visibleCells.count) {
            self.downButton.hidden = YES;
            self.upButton.hidden = YES;
        }
    }];
    //标为已读／标为未读
    //    __weak TableViewController *weakSelf = self;
    TableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //取模型
    Grade *grade = self.gradesArray[indexPath.row];
    UITableViewRowAction *markAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:grade.isRead?MarkToRead:MarkToNotRead handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        grade.read = !grade.isRead;
        cell.grade = grade;
        
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
        tableView.editing = NO;
    }];
    markAction.backgroundColor = [UIColor orangeColor];
    //置顶
    UITableViewRowAction *toTopAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if (indexPath.row==0){
            tableView.editing = NO;
            return;
        }
        for (NSInteger i = indexPath.row; i > 0; i--) {
            [self.gradesArray exchangeObjectAtIndex:i withObjectAtIndex:i-1];
            NSIndexPath *tempIndex = [NSIndexPath indexPathForRow:i-1 inSection:indexPath.section];
            NSIndexPath *nowIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
            [tableView moveRowAtIndexPath:nowIndexPath toIndexPath:tempIndex];
        }
        tableView.editing = NO;
    }];
    //上移
    UITableViewRowAction *upAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"上移" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (indexPath.row==0){
            tableView.editing = NO;
            return;
        }
        [self.gradesArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:indexPath.row-1];
        NSIndexPath *upIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        [tableView moveRowAtIndexPath:indexPath toIndexPath:upIndexPath];
        tableView.editing = NO;
    }];
    upAction.backgroundColor = [UIColor blueColor];
    //下移
    UITableViewRowAction *downAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"下移" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        if (indexPath.row==self.gradesArray.count-1){
            tableView.editing = NO;
            return;
        }
        [self.gradesArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:indexPath.row+1];
        NSIndexPath *downIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        [tableView moveRowAtIndexPath:indexPath toIndexPath:downIndexPath];
        tableView.editing = NO;
    }];
    downAction.backgroundColor = [UIColor purpleColor];
    
    return @[deleAction,markAction,toTopAction,upAction,downAction];
}
- (void)buttonClick:(UIButton *)button
{
    NSLog(@"buttonClick:%@",button.titleLabel.text);
}
#pragma mark - 弹出视图显示成绩详情
- (void)alertToShowScoreDetail:(NSIndexPath *)indexPath
{
    Grade *grade = self.gradesArray[indexPath.row];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"成绩详情" message:@"修改or取消" preferredStyle:UIAlertControllerStyleAlert];
    
    [self addTextFieldWithString:grade.year forController:alert placeHolder:@"学年" keyboardType:UIKeyboardTypeDefault];
    [self addTextFieldWithString:[NSString stringWithFormat:@"%ld",grade.term] forController:alert placeHolder:@"学期" keyboardType:UIKeyboardTypeNumberPad];
    [self addTextFieldWithString:[NSString stringWithFormat:@"课程代码：%@",grade.courseCode] forController:alert placeHolder:@"课程代码" keyboardType:UIKeyboardTypeDefault];
    [self addTextFieldWithString:grade.courseName forController:alert placeHolder:@"课程名称" keyboardType:UIKeyboardTypeDefault];
    [self addTextFieldWithString:[NSString stringWithFormat:@"课程性质：%@",grade.attribute] forController:alert placeHolder:@"课程性质" keyboardType:UIKeyboardTypeDefault];
    [self addTextFieldWithString:[NSString stringWithFormat:@"课程学分：%.1f",grade.credit] forController:alert placeHolder:@"课程学分" keyboardType:UIKeyboardTypeDecimalPad];
    [self addTextFieldWithString:[NSString stringWithFormat:@"成绩：%ld",grade.score] forController:alert placeHolder:@"成绩" keyboardType:UIKeyboardTypeNumberPad];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"修改" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self updateGradeInfo:alert atIndexPath:indexPath];
    }];
    [alert addAction:cancel];
    [alert addAction:sure];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - 为UIAlertController添加文本框
- (void)addTextFieldWithString:(NSString *)string forController:(UIAlertController *)alert placeHolder:(NSString *)placeHolder keyboardType:(UIKeyboardType)keyboardType
{
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = keyboardType;
        textField.text = string;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        NSAttributedString *attri = [[NSAttributedString alloc]initWithString:placeHolder attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
        [textField setAttributedPlaceholder:attri];
    }];
}
#pragma mark - 更新成绩信息
- (void)updateGradeInfo:(UIAlertController *)alert atIndexPath:(NSIndexPath *)indexPath
{
    for (NSString *text in [alert.textFields valueForKeyPath:@"text"]) {
        if (text.length==0) {
            
            UIAlertController *subAlert = [UIAlertController alertControllerWithTitle:@"修改成绩信息失败！" message:@"存在信息为空，请检查！" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [subAlert dismissViewControllerAnimated:YES completion:^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
            }];
            [subAlert addAction:action];
            [self presentViewController:subAlert animated:YES completion:nil];
            return;
        }
    }
    Grade *grade = self.gradesArray[indexPath.row];
    //学年
    grade.year = [alert.textFields firstObject].text;
    //学期
    grade.term = [[alert.textFields objectAtIndex:1].text integerValue];
    //课程代码
    NSString *codeText = [alert.textFields objectAtIndex:2].text;
    grade.courseCode = [self subStringOfString:codeText isContainFlag:@"："];
    //课程名称
    grade.courseName = [alert.textFields objectAtIndex:3].text;
    //课程性质
    NSString *attriText = [alert.textFields objectAtIndex:4].text;
    grade.attribute = [self subStringOfString:attriText isContainFlag:@"："];
    //学分
    NSString *creditText = [alert.textFields objectAtIndex:5].text;
    grade.credit = [[self subStringOfString:creditText isContainFlag:@"："] floatValue];
    //成绩
    NSString *scoreText = [alert.textFields lastObject].text;
    grade.score = [[self subStringOfString:scoreText isContainFlag:@"："] integerValue];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}
#pragma mark - 截取字符串
- (NSString *)subStringOfString:(NSString *)origin isContainFlag:(NSString *)flag
{
    if ([origin containsString:flag]) {
        NSRange range = [origin rangeOfString:flag];
        NSInteger index = range.location + range.length;
        NSString *sub = [origin substringFromIndex:index];
        return sub;
    }
    return origin;
}
@end
