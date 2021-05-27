//
//  CMUserListView.m
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/13.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMUserListView.h"
#import "CMUserListCell.h"

@interface CMUserListView ()<NSTableViewDelegate,NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic,strong)NSArray *dataSource;
@end

@implementation CMUserListView

@synthesize tag = _tag;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)awakeFromNib{
    self.wantsLayer = YES;
//    self.layer.backgroundColor = [NSColor clearColor].CGColor;
}
-(void)reloadView:(NSArray *)list{
    self.dataSource = list;
    [self.tableView reloadData];
}
- (IBAction)closeButtonClick:(id)sender {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = 0.4;
        self.animator.alphaValue = 0;
    } completionHandler:^{
        [self removeFromSuperview];
    }];
}

-(void)configure{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.target = self;
    self.tableView.action = @selector(clickedRowAction);
    [self.tableView registerNib:[[NSNib alloc]initWithNibNamed:@"CMUserListCell" bundle:[NSBundle mainBundle]] forIdentifier:@"CMUserListCell"];
}

-(void)clickedRowAction{
    NSInteger row = self.tableView.clickedRow;
    if (row != NSNotFound && row != -1) {
        NSString *userId = [NSString stringWithFormat:@"%@",self.dataSource[row]];
        [self.delegate didClickRow:userId];
    }
}


#pragma mark - NSTableViewDelegate NSTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.dataSource.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    CMUserListCell *cellView = [tableView makeViewWithIdentifier:@"CMUserListCell" owner:self];
    [cellView reloadView:[NSString stringWithFormat:@"%@",self.dataSource[row]]];
    return cellView;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 44;
}

-(CGFloat)tableView:(NSTableView *)tableView sizeToFitWidthOfColumn:(NSInteger)column{
    return 300;
}




@end
