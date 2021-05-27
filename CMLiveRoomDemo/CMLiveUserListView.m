//
//  CMLiveUserListView.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/16.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMLiveUserListView.h"
#import "Masonry.h"
#import "RTCNetworkManager.h"


@interface CMLiveUserListView ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSArray *dataSource;
@end

@implementation CMLiveUserListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.centerY.equalTo(self);
            make.height.equalTo(@(200*16.0/9));
        }];
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effect = [[UIVisualEffectView alloc]initWithEffect:blur];
        [self insertSubview:effect atIndex:0];
        
        [effect mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.tableView);
        }];
        
        [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"UITableViewCell"];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:self];
    CGRect topFrame = CGRectMake(0, 0, self.frame.size.width, self.tableView.frame.origin.y);
    CGRect bottomFrame = CGRectMake(0, CGRectGetMaxY(self.tableView.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(self.tableView.frame));
    return CGRectContainsPoint(topFrame, point) || CGRectContainsPoint(bottomFrame, point);
}
-(void)dismiss{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)reloadData:(NSArray *)userIdList{
    self.dataSource = [userIdList copy];
    [self.tableView reloadData];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    NSString *userId = self.dataSource[indexPath.row];
    NSString *me = NSLocalizedString(@"Live Role Me", nil);
    NSString *host = NSLocalizedString(@"Live Role Host", nil);
    if ([userId isEqualToString:[RTCNetworkManager sharedManager].userId]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@--%@",userId,me];
    }
    else if ([userId hasPrefix:@"H"]){
        cell.textLabel.text = [NSString stringWithFormat:@"%@--%@",userId,host];
    }
    else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@",userId];
    }
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *userId = [NSString stringWithFormat:@"%@",self.dataSource[indexPath.row]];
    [self.delegate listView:self didSelected:userId];
    [self dismiss];
}

@end
