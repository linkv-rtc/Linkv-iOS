//
//  CMMacStatisticsView.m
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/13.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMMacStatisticsView.h"
#import "CMMacStatisticsCellView.h"
#import "CMMacStatisticsHeaderView.h"

@interface CMMacStatisticsView ()<NSTableViewDelegate,NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataSource;
@end

@implementation CMMacStatisticsView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)configure{
    NSNib *cell = [[NSNib alloc]initWithNibNamed:@"CMMacStatisticsCellView" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:cell forIdentifier:@"CMMacStatisticsCellView"];
    
    NSNib *header = [[NSNib alloc]initWithNibNamed:@"CMMacStatisticsHeaderView" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:header forIdentifier:@"CMMacStatisticsHeaderView"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    
    self.dataSource = [[NSMutableArray alloc]init];
    [self.dataSource addObject:@{@"item":[LVVideoStatistic new],@"userId":@""}];
    [self.tableView reloadData];
}

-(void)reloadView:(LVVideoStatistic *)videoStatistic userId:(NSString *)userId{
    __block NSInteger index = NSNotFound;
    [self.dataSource enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([item[@"userId"] isEqualToString:userId]) {
            *stop = YES;
            index = idx;
        }
    }];
    
    if (index != NSNotFound && index != -1) {
        NSMutableDictionary *item = self.dataSource[index];
        item[@"item"] = videoStatistic;
        [self.dataSource replaceObjectAtIndex:index withObject:item];
        [self.tableView reloadData];
    }
    else{
        NSMutableDictionary *item = [@{@"userId":userId,@"item":videoStatistic} mutableCopy];
        [self.dataSource addObject:item];
        [self.tableView reloadData];
    }
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


#pragma mark NSTableViewDelegate NSTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.dataSource.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (row == 0) {
        CMMacStatisticsHeaderView *cell = [tableView makeViewWithIdentifier:@"CMMacStatisticsHeaderView" owner:self];
        return cell;
    }
    
    CMMacStatisticsCellView *cell = [tableView makeViewWithIdentifier:@"CMMacStatisticsCellView" owner:self];
    NSDictionary *item = self.dataSource[row];
    LVVideoStatistic *statistic = item[@"item"];
    NSString *userId = item[@"userId"];
    [cell reloadView:statistic userId:userId];
    return cell;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 24;
}

-(CGFloat)tableView:(NSTableView *)tableView sizeToFitWidthOfColumn:(NSInteger)column{
    return 300;
}


@end
