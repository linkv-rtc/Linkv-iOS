//
//  CMLiveSettingView.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/9.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMLiveSettingView.h"
#import "CMLiveSettingCell.h"
#import "CMSettingSliderCell.h"

@interface CMLiveSettingView ()<UITableViewDelegate,UITableViewDataSource,CMLiveSettingCellDelegate,UIGestureRecognizerDelegate,CMSettingSliderCellDelegate>
{
    UIVisualEffectView * effect;
}
@property (nonatomic,strong)UITableView *tableView;
@end


@implementation CMLiveSettingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
        self.tableView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
        self.backgroundColor = [UIColor clearColor];
        [self.tableView registerNib:[UINib nibWithNibName:@"CMLiveSettingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CMLiveSettingCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"CMSettingSliderCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CMSettingSliderCell"];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        effect = [[UIVisualEffectView alloc]initWithEffect:blur];
        effect.frame = self.tableView.frame;
        [self insertSubview:effect atIndex:0];
    }
    return self;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:self];
    CGRect topFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - self.tableView.frame.size.height);
    return CGRectContainsPoint(topFrame, point);
}

-(void)reloadData{
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.tableView.frame;
        frame.size.height = 54 * self.dataSource.count;
        NSArray *items = self.dataSource;
        if (items.count == 1) {
            frame.size.height = 250;
        }
        else if (frame.size.height > (self.frame.size.height / 2.0)) {
            frame.size.height = self.frame.size.height / 2.0;
        }
        frame.origin.y = self.frame.size.height - frame.size.height;
        self.tableView.frame = frame;
        effect.frame = frame;
    }];
    [self.tableView reloadData];
}

-(void)dismiss{
    
    CGRect frame = self.frame;
    frame.origin.y = self.frame.size.height;
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
    [self.delegate settingView:self dismiss:YES];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *item = self.dataSource[indexPath.row];
    if ([item[@"type"] integerValue] == CMCellTypeCustom) {
        CMSettingSliderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CMSettingSliderCell"];
        cell.item = item;
        cell.delegate = self;
        return cell;
    }
    else{
        CMLiveSettingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CMLiveSettingCell"];
        cell.item = self.dataSource[indexPath.row];
        cell.indexPath = indexPath;
        cell.delegate = self;
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *item = self.dataSource[indexPath.row];
    if ([item[@"type"] integerValue] == CMCellTypeCustom) {
        return 250;
    }
    return 54;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.frame.size.height/2, self.frame.size.width, self.frame.size.height/2) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *item = self.dataSource[indexPath.row];
    if ([item[@"type"] integerValue] != CMCellTypeCustom) {
        CMLiveSettingCell *cell = (CMLiveSettingCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (cell.actionSwitch.hidden) {
            [self didSelect:indexPath title:cell.titleLab.text isOn:cell.actionSwitch.isOn];
        }
    }
}

#pragma mark -CMLiveSettingCellDelegate
-(void)didSelect:(NSIndexPath *)indexPath title:(NSString *)title isOn:(BOOL)isOn{
    [self.delegate didSelect:indexPath title:title isOn:isOn];
}

#pragma mark -CMSettingSliderCellDelegate
-(void)didChangeAVConfig:(LVAVConfig *)config{
    [self.delegate didChangeAVConfig:config];
    [self dismiss];
}


@end
