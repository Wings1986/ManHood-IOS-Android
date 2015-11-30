//
//  ETShareViewController.m
//  Histo
//
//  Created by Viktor Gubriienko on 14.04.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "ETShareViewController.h"
#import "ETShareUtility.h"

@interface ETShareViewController ()

<
UITableViewDataSource,
UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end


@implementation ETShareViewController {
    NSMutableArray *_tableData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    UIImage *image = (IS_LONG_IPHONE)?[UIImage imageNamed:@"camera_guide_bg-568h.png"]:[UIImage imageNamed:@"camera_guide_bg.png"];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:image];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView setupFirstSeparatorOnHeaderView];

    _tableData = [NSMutableArray new];
    
    
    __weak typeof(self) weakSelf = self;
    [_tableData addObject:@{@"i": [UIImage imageNamed:@"twitter_icon.png"],
                            @"t": @"Twitter",
                            @"b": [^(){ [ETShareUtility shareTheAppViaTwitterOnViewController:weakSelf]; } copy]}];
    [_tableData addObject:@{@"i": [UIImage imageNamed:@"facebook_icon.png"],
                            @"t": @"Facebook",
                            @"b": [^(){ [ETShareUtility shareTheAppViaFacebookOnViewController:weakSelf]; } copy]}];
    [_tableData addObject:@{@"i": [UIImage imageNamed:@"mail_icon.png"],
                            @"t": @"Mail",
                            @"b": [^(){ [ETShareUtility shareTheAppViaEmailOnViewController:weakSelf]; } copy]}];
    [_tableData addObject:@{@"i": [UIImage imageNamed:@"message_icon.png"],
                            @"t": @"Message",
                            @"b": [^(){ [ETShareUtility shareTheAppViaMessageOnViewController:weakSelf]; } copy]}];
    
}

#pragma mark - TableView delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TellAFriendCell" forIndexPath:indexPath];
    
    NSDictionary *meta = _tableData[indexPath.item];
    cell.imageView.image = meta[@"i"];
    cell.textLabel.text = meta[@"t"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    void (^block)() = _tableData[indexPath.item][@"b"];
    block();
    
}

@end
