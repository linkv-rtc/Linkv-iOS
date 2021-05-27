//
//  CMTableCellView.m
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/10.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMTableCellView.h"
#import "SYFlatButton.h"

@interface CMTableCellView ()
@property (weak) IBOutlet SYFlatButton *joinButton;

@end


@implementation CMTableCellView
- (IBAction)joinButtonClick:(id)sender {
    
    [self.delegate didSelectRow:self.row];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
