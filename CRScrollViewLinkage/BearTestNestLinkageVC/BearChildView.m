//
//  BearChildView.m
//  InterLock
//
//  Created by apple on 2021/3/10.
//

#import "BearChildView.h"
#import <Masonry/Masonry.h>

@interface BearChildView() <UITableViewDelegate, UITableViewDataSource>

@end

@implementation BearChildView

+ (CGFloat)viewHeight {
    return 700;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
        
        self.myTableView = [BearChildTableView new];
        self.myTableView.delegate = self;
        self.myTableView.dataSource = self;
        [self addSubview:self.myTableView];
        [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"1";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"cell-%ld", (long)indexPath.row];
    
    return cell;
}

@end
