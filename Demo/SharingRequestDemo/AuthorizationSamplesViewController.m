//
//  AuthorizationViewController.m
//  SharingRequestDemo
//
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "AuthorizationSamplesViewController.h"
#import "DoubanAuthViewController.h"
#import "SinaweiboAuthViewController.h"
#import "RenrenAuthViewController.h"
#import "TencentAuthViewController.h"
#import "AppGlobal.h"
#import "DOUVenderAPIRequestManager.h"
#import "DemoUtil.h"

typedef enum {
  kRowTypeDouban = 0,
  kRowTypeSinaWeibo = 1,
  kRowTypeRenren = 2,
  kRowTypeTencentWeibo = 3,
} RowType;

@interface AuthorizationSamplesViewController ()

@property (nonatomic, strong) NSArray *arr;

@property (nonatomic, strong) NSArray *cellsArr;

@property (nonatomic, strong) UITableViewCell *doubanCell;
@property (nonatomic, strong) UITableViewCell *sinaWeiboCell;
@property (nonatomic, strong) UITableViewCell *tencentWeiboCell;
@property (nonatomic, strong) UITableViewCell *renrenCell;

@property (nonatomic, strong) UISwitch *doubanCellSwitch;
@property (nonatomic, strong) UISwitch *sinaWeiboCellSwitch;
@property (nonatomic, strong) UISwitch *tencentWeiboCellSwitch;
@property (nonatomic, strong) UISwitch *renrenCellSwitch;

@property (nonatomic, strong) DOUVenderAPIRequestManager *requestManager;

@end

@implementation AuthorizationSamplesViewController


- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.doubanCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
  self.doubanCell.tag = kDOUOAuth2VenderDouban;
  self.doubanCellSwitch = [[UISwitch alloc] init];
  self.doubanCell.accessoryView = self.doubanCellSwitch;
  [self.doubanCellSwitch addTarget:self
                               action:@selector(sendMesageEnabled:)
                     forControlEvents:UIControlEventValueChanged];
  
  self.sinaWeiboCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
  self.sinaWeiboCell.tag = kDOUOAuth2VenderSinaWeibo;
  self.sinaWeiboCellSwitch = [[UISwitch alloc] init];
  self.sinaWeiboCell.accessoryView = self.sinaWeiboCellSwitch;
  [self.sinaWeiboCellSwitch addTarget:self
                               action:@selector(sendMesageEnabled:)
                     forControlEvents:UIControlEventValueChanged];
  
  self.renrenCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
  self.renrenCell.tag = kDOUOAuth2VenderRenren;
  self.renrenCellSwitch = [[UISwitch alloc] init];
  self.renrenCell.accessoryView = self.renrenCellSwitch;
  [self.renrenCellSwitch addTarget:self
                            action:@selector(sendMesageEnabled:)
                  forControlEvents:UIControlEventValueChanged];
  
  self.tencentWeiboCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
  self.tencentWeiboCell.tag = kDOUOAuth2VenderTencentWeibo;
  self.tencentWeiboCellSwitch = [[UISwitch alloc] init];
  self.tencentWeiboCell.accessoryView = self.tencentWeiboCellSwitch;
  [self.tencentWeiboCellSwitch addTarget:self
                                  action:@selector(sendMesageEnabled:)
                        forControlEvents:UIControlEventValueChanged];
  
  self.cellsArr = @[self.doubanCell, self.sinaWeiboCell, self.renrenCell, self.tencentWeiboCell, ];
  self.arr = [NSArray arrayWithObjects:@"Douban", @"SinaWeibo", @"Renren", @"Tencent", nil];
  
  for (NSInteger i = 0; i < self.arr.count; ++i) {
    UITableViewCell *cell = [self.cellsArr objectAtIndex:i];
    cell.textLabel.text = [self.arr objectAtIndex:i];
  }
}

- (void)sendMesageEnabled:(UISwitch *)sender
{
  if (self.doubanCellSwitch == sender) {
    DOUOAuth2Credential *credentail = [[AppGlobal sharedInstance] credentialByVenderType:kDOUOAuth2VenderDouban];
    if (credentail == nil) {
      sender.on = NO;
      [self authDouban];
    }
  }
  else if (self.sinaWeiboCellSwitch == sender) {
    DOUOAuth2Credential *credentail = [[AppGlobal sharedInstance] credentialByVenderType:kDOUOAuth2VenderSinaWeibo];
    if (credentail == nil) {
      sender.on = NO;
      [self authSinaWeibo];
    }
  } else if (self.renrenCellSwitch == sender) {
    DOUOAuth2Credential *credentail = [[AppGlobal sharedInstance] credentialByVenderType:kDOUOAuth2VenderRenren];
    if (credentail == nil) {
      sender.on = NO;
      [self authRenren];
    }
  } else if (self.tencentWeiboCellSwitch == sender) {
    DOUOAuth2Credential *credentail = [[AppGlobal sharedInstance] credentialByVenderType:kDOUOAuth2VenderTencentWeibo];
    if (credentail == nil) {
      sender.on = NO;
      [self authTencentWeibo];
    }
  }
}

- (NSArray *)credentailsOfEnabled
{
  NSMutableArray *enabledArr = [NSMutableArray arrayWithCapacity:4];
  DOUOAuth2Credential *credential = nil;
  credential = [[AppGlobal sharedInstance] credentialByVenderType:kDOUOAuth2VenderDouban];
  if (self.doubanCellSwitch.on && credential) {
    [enabledArr addObject:credential];
  }
  
  credential = [[AppGlobal sharedInstance] credentialByVenderType:kDOUOAuth2VenderSinaWeibo];
  if (self.sinaWeiboCellSwitch.on && credential) {
    [enabledArr addObject:credential];
  }
  
  credential = [[AppGlobal sharedInstance] credentialByVenderType:kDOUOAuth2VenderRenren];
  if (self.renrenCellSwitch.on && credential) {
    [enabledArr addObject:credential];
  }
  
  credential = [[AppGlobal sharedInstance] credentialByVenderType:kDOUOAuth2VenderTencentWeibo];
  if (self.tencentWeiboCellSwitch.on && credential) {
    [enabledArr addObject:credential];
  }
  return enabledArr;
}

- (void)authDouban
{
  DoubanAuthViewController *vc = [[DoubanAuthViewController alloc] init];
  [self.navigationController pushViewController:vc animated:YES];
  [vc setOAuth2DidSucceed:^(DOUOAuth2Credential *credential) {
    [AppGlobal sharedInstance].douban = credential;
    [self.tableView reloadData];
    self.doubanCellSwitch.on = YES;
  } didFail:^{
    
  }];
}

- (void)authSinaWeibo
{
  SinaweiboAuthViewController *vc = [[SinaweiboAuthViewController alloc] init];
  [self.navigationController pushViewController:vc animated:YES];
  [vc setOAuth2DidSucceed:^(DOUOAuth2Credential *credential) {
    [AppGlobal sharedInstance].sinaWeibo = credential;
    [self.tableView reloadData];
    self.sinaWeiboCellSwitch.on = YES;
  } didFail:^{
  }];
}

- (void)authTencentWeibo
{
  TencentAuthViewController *vc = [[TencentAuthViewController alloc] init];
  [self.navigationController pushViewController:vc animated:YES];
  [vc setOAuth2DidSucceed:^(DOUOAuth2Credential *credential) {
    [AppGlobal sharedInstance].tencentWeibo = credential;
    [self.tableView reloadData];
    self.tencentWeiboCellSwitch.on = YES;
  } didFail:^{
  }];
}

- (void)authRenren
{
  RenrenAuthViewController *vc = [[RenrenAuthViewController alloc] init];
  [self.navigationController pushViewController:vc animated:YES];
  [vc setOAuth2DidSucceed:^(DOUOAuth2Credential *credential) {
    [AppGlobal sharedInstance].renren = credential;
    [self.tableView reloadData];
    self.renrenCellSwitch.on = YES;
  } didFail:^{
  }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == 0) {
    return [self.arr count];
  } else if (section == 1) {
    return 3;
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  
  if (indexPath.section == 0) {
    UITableViewCell *cell = [self.cellsArr objectAtIndex:indexPath.row];
    DOUOAuth2Credential *credentail = [[AppGlobal sharedInstance] credentialByVenderType:cell.tag];
    cell.detailTextLabel.text = credentail ? @"已认证" : @"未认证";
    return cell;
  } else {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row == 0) {
      cell.textLabel.text = @"send message";
    } else if (indexPath.row == 1) {
      cell.textLabel.text = @"send message and image url";
    } else if (indexPath.row == 2) {
      cell.textLabel.text = @"send message and image data";
    }
    return cell;
  }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (indexPath.section == 0) {
    if (kRowTypeDouban == indexPath.row) {
      [self authDouban];
    } else if (kRowTypeSinaWeibo == indexPath.row) {
      [self authSinaWeibo];
    } else if (kRowTypeRenren == indexPath.row) {
      [self authRenren];
    } else if (kRowTypeTencentWeibo == indexPath.row) {
      [self authTencentWeibo];
    }
  } else if (indexPath.section == 1) {
    NSArray *enabledArr = [self credentailsOfEnabled];
    if (enabledArr == nil || [enabledArr count] < 1) {
      return;
    }
    self.requestManager = [[DOUVenderAPIRequestManager alloc] initWithBlocksForDidFinishBlock:^(NSInteger toalCount, NSInteger succeedCount, NSArray *credentialsForFailures) {
      [self showAlertViewWithText:@"Finished!"];
    } didSendOneBlock:^(DOUVenderAPIResponse *resp) {
      [self showAlertViewWithText:@"succeed to send one"];
    } didFailOneBlock:^(NSError *error, DOUOAuth2VenderType venderType) {
      [self showAlertViewWithText:[NSString stringWithFormat:@"error %@, vender type : %d", error, venderType]];
    }];
    
    
    DOUVenderAPIRequestOptions *renrenOptions = [DOUVenderAPIRequestOptions renrenOptionsWithStatusLink:@"http://9.douban.com"
                                                                                                  title:@"分享图片"
                                                                                            description:@"分享图片测试"];
    
    if (0 == indexPath.row) {
      [self.requestManager sendStatus:[NSString stringWithFormat:@"%@ Test$$$", [NSDate date]]
                      withCredentials:enabledArr
                         extraOptions:renrenOptions];
    } else if (1 == indexPath.row) {
      [self.requestManager sendStatus:[NSString stringWithFormat:@"%@ Test$$$", [NSDate date]]
                         withImageUrl:@"http://img1.douban.com/mpic/s8966851.jpg"
                      withCredentials:enabledArr
                         extraOptions:renrenOptions];
    } else if (2 == indexPath.row) {
      [self.requestManager sendStatus:[NSString stringWithFormat:@"%@ Test$$$", [NSDate date]]
                            withImage:[DemoUtil imageWithColor:[UIColor blackColor]]
                      withCredentials:enabledArr
                         extraOptions:renrenOptions];
    }
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 55.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
  if (section == 0) {
    label.text = @"第三方认证";
  } else if (section == 1) {
    label.text = @"测试";
  }
  label.backgroundColor = [UIColor grayColor];
  return label;
}

- (void)showAlertViewWithText:(NSString *)text
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:text message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
  [alert show];
}

@end
