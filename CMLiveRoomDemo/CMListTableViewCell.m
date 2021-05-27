//
//  CMListTableViewCell.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/6.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMListTableViewCell.h"

@interface CMListTableViewCell ()
@property (weak, nonatomic) IBOutlet UIButton *join;

@end


@implementation CMListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.join.layer.masksToBounds = YES;
    self.join.layer.cornerRadius = 4;
    
    self.roomIdLab.font = [UIFont systemFontOfSize:18];
    self.roomIdLab.textColor = [UIColor darkGrayColor];
    
}
- (IBAction)lookButtonAction:(id)sender {
    [self.delegate didSelectedIndex:self.indexPath];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
