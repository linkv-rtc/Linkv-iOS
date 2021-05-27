//
//  CMStatisticsVIew.m
//  LinkV
//
//  Created by jfdreamyang on 2020/3/27.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMStatisticsView.h"
#import "Masonry.h"
#import "CMStatisticsViewCell.h"
#import "CMStatisticsHeaderCell.h"

@interface CMStatisticsView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataSource;
@end


@implementation CMStatisticsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.tableView.separatorColor = [UIColor lightGrayColor];
        [self.tableView registerNib:[UINib nibWithNibName:@"CMStatisticsViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CMStatisticsViewCell"];
        [self.tableView registerNib:[UINib nibWithNibName:@"CMStatisticsHeaderCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CMStatisticsHeaderCell"];
        self.dataSource = [[NSMutableArray alloc]init];
        [self.dataSource addObject:@{@"item":[LVVideoStatistic new],@"userId":@""}];
    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        CMStatisticsHeaderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CMStatisticsHeaderCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    CMStatisticsViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CMStatisticsViewCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *item = self.dataSource[indexPath.row];
    LVVideoStatistic *statistic = item[@"item"];
    NSString *userId = item[@"userId"];
    [cell reloadView:statistic userId:userId];
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 34;
}

-(void)reloadView:(LVVideoStatistic *)videoStatistic userId:(NSString *)userId{
    
    __block NSInteger index = NSNotFound;
    [self.dataSource enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([item[@"userId"] isEqualToString:userId]) {
            *stop = YES;
            index = idx;
        }
    }];
    
    if (index != NSNotFound) {
        NSMutableDictionary *item = self.dataSource[index];
        item[@"item"] = videoStatistic;
        [self.dataSource replaceObjectAtIndex:index withObject:item];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    else{
        NSMutableDictionary *item = [@{@"userId":userId,@"item":videoStatistic} mutableCopy];
        [self.dataSource addObject:item];
        [self.tableView reloadData];
    }
    
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

-(void)remove:(NSString *)userId{
    for (NSInteger i=0; i<self.dataSource.count; i++) {
        NSDictionary *item = self.dataSource[i];
        if ([item[@"userId"] isEqualToString:userId]) {
            [self.dataSource removeObjectAtIndex:i];
            [self.tableView reloadData];
            break;;
        }
    }
}


@end
