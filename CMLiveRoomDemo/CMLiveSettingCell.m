//
//  CMLiveSettingCell.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/9.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMLiveSettingCell.h"

@interface CMLiveSettingCell ()

@end


@implementation CMLiveSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
}


-(void)setItem:(NSDictionary *)item{
    _item = item;
    self.actionSwitch.hidden = YES;
    self.titleLab.textAlignment = NSTextAlignmentLeft;
    self.actionSwitch.on = NO;
    if ([item[@"type"] integerValue] == CMCellTypeSwitch) {
        self.actionSwitch.hidden = NO;
        self.actionSwitch.on = [item[@"default"] integerValue];
    }
    else if ([item[@"textAlignment"] integerValue] == NSTextAlignmentCenter){
        self.titleLab.textAlignment = NSTextAlignmentCenter;
    }
    self.titleLab.text = item[@"title"];
}

- (IBAction)switchButtonClick:(id)sender {
    [self.delegate didSelect:self.indexPath title:self.titleLab.text isOn:self.actionSwitch.isOn];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
