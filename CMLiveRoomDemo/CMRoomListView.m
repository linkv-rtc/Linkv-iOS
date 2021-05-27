//
//  CMRoomListView.m
//  CMRTCDemo
//
//  Created by jfdreamyang on 2019/12/5.
//  Copyright © 2019 jfdreamyang. All rights reserved.
//

#import "CMRoomListView.h"
#import "CMListTableViewCell.h"
#import "RTCNetworkManager.h"

@interface CMRoomListView()<UITableViewDelegate,UITableViewDataSource,CMListTableViewCellDelegate>
@property (nonatomic,strong)NSArray *dataSource;
@property (nonatomic,strong)UITableView *tableView;
@end


@implementation CMRoomListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tableView];
        [self.tableView registerNib:[UINib nibWithNibName:@"CMListTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CMListTableViewCell"];
        
    }
    return self;
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.tableView.frame = self.bounds;
    [self.tableView reloadData];
    self.tableView.allowsSelection = NO;
}

-(void)didSelectedIndex:(NSIndexPath *)indexPath{
    [self.delegate didSelectIndexPath:indexPath];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CMListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CMListTableViewCell"];
    cell.roomIdLab.text = [NSString stringWithFormat:@"%@",self.dataSource[indexPath.row]];
    cell.delegate = self;
    cell.indexPath = indexPath;
    return cell;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    [backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 69;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}


-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

-(void)reloadData:(NSArray *)dataSource{
    NSMutableArray *roomList = NSMutableArray.new;
    if (kEnableAutoTest) {
        self.dataSource = dataSource.copy;
        [self.tableView reloadData];
        return;
    }
    for (id _roomId in dataSource) {
        NSString *roomId = [NSString stringWithFormat:@"%@",_roomId];
        if ([roomId hasPrefix:@"A"] || [roomId hasPrefix:@"M"] || [roomId hasPrefix:@"L"]) {
            [roomList addObject:roomId];
        }
    }
    self.dataSource = roomList.copy;
    [self.tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.delegate didSelectIndexPath:indexPath];
}


@end
