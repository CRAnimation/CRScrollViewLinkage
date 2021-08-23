//
//  ViewController.m
//  CRScrollViewLinkage
//
//  Created by Bear on 2021/8/23.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.dataArray addObject:@"BearTestNestLinkageVC"];
    
    [self createUI];
}

- (void)createUI {
    [self.view addSubview:self.mainTableView];
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.insets(UIEdgeInsetsZero);
    }];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *name = self.dataArray[indexPath.row];
    Class cellClass = NSClassFromString(name);
    UIViewController *vc = (UIViewController *)[cellClass new];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Setter & Getter
- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [UITableView new];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
    }
    
    return _mainTableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    
    return _dataArray;
}

@end
