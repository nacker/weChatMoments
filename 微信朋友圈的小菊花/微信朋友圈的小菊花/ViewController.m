//
//  ViewController.m
//  微信朋友圈的小菊花
//
//  Created by nacker on 15/12/29.
//  Copyright © 2015年 帶頭二哥. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Extention.h"

static CGFloat TABLEHEADERVIEHEIGHT = 300.0f;
static CGFloat REFLASHMAXCENTERY = 100.0f;
static CGFloat REFLSAHINITCENTERY = 40.0f;

//获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)


// APP_STATUSBAR_HEIGHT=SYS_STATUSBAR_HEIGHT+[HOTSPOT_STATUSBAR_HEIGHT]
#define APP_STATUSBAR_HEIGHT                (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame))
// 工具栏（UINavigationController.UIToolbar）高度
#define NAVIGATIONBAR_HEIGHT                44
// 实时系统状态栏高度+导航栏高度，如有热点栏，其高度包含在APP_STATUSBAR_HEIGHT中。
#define STATUS_AND_NAV_BAR_HEIGHT           (APP_STATUSBAR_HEIGHT+NAVIGATIONBAR_HEIGHT)

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    //是否正在刷新
    BOOL isRefreshing;
    //是否可以开始刷新
    BOOL startRefreshing;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *albumReflashImageView;
@property (nonatomic, strong) UIImageView *tableViewHeaderView;

@end

@implementation ViewController

- (UIImageView *)tableViewHeaderView{
    if (!_tableViewHeaderView) {
        _tableViewHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, TABLEHEADERVIEHEIGHT)];
        _tableViewHeaderView.contentMode = UIViewContentModeScaleAspectFill;
        _tableViewHeaderView.clipsToBounds = YES;
        _tableViewHeaderView.userInteractionEnabled = YES;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"coffe" ofType:@"jpg"];
        _tableViewHeaderView.image = [UIImage imageWithContentsOfFile:path];
    }
    return _tableViewHeaderView;
}

- (UIImageView *)albumReflashImageView{
    if (!_albumReflashImageView) {
        UIImage *relahsImage = [UIImage imageNamed:@"AlbumReflashIcon"];
        _albumReflashImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, REFLSAHINITCENTERY, relahsImage.size.width, relahsImage.size.height)];
        _albumReflashImageView.centerY = REFLSAHINITCENTERY;
        _albumReflashImageView.image = relahsImage;
    }
    return _albumReflashImageView;
}


- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.frame = self.view.bounds;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.sectionIndexColor = [UIColor grayColor];
        _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
        _tableView.tableHeaderView = self.tableViewHeaderView;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    startRefreshing = NO;
    isRefreshing = NO;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.albumReflashImageView];
}

#pragma mark - TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

static NSString * const CellIdentifier = @"cell";
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"index %li",indexPath.row];
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGPoint point = scrollView.contentOffset;
    
    if (point.y<0) {
        
        if (isRefreshing) {
            return;
        }
        
        CGFloat rate  = point.y/10;
        
        NSLog(@"%f",STATUS_AND_NAV_BAR_HEIGHT);
        CGFloat centerY = REFLSAHINITCENTERY+fabs(point.y) - STATUS_AND_NAV_BAR_HEIGHT;
        
        if (centerY>REFLASHMAXCENTERY) {
            
            self.albumReflashImageView.centerY = REFLASHMAXCENTERY;
            
            startRefreshing = YES;
        }else{
            self.albumReflashImageView.centerY = centerY;
            startRefreshing = NO;
        }
        //旋转刷新图标
        self.albumReflashImageView.transform = CGAffineTransformMakeRotation(rate);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (startRefreshing) {
        [self startRotate];
    }else{
        self.albumReflashImageView.centerY = REFLSAHINITCENTERY;
    }
}

-(void)startRotate{
    if (![self.albumReflashImageView.layer animationForKey:@"animation"]) {
        CABasicAnimation *animationImage = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animationImage.fromValue = [NSNumber numberWithFloat:0];
        animationImage.toValue = [NSNumber numberWithFloat:M_PI *2.0];
        animationImage.duration = 1;
        
        animationImage.repeatCount =HUGE_VALF;
        animationImage.fillMode = kCAFillModeForwards;
        [self.albumReflashImageView.layer addAnimation:animationImage forKey:@"animation"];
        
        [self performSelector:@selector(endRotate) withObject:nil afterDelay:2];
        
        isRefreshing = YES;
    }
}
-(void)endRotate{
    //上升隐藏
    [UIView animateWithDuration:0.2 animations:^{
        self.albumReflashImageView.centerY = REFLSAHINITCENTERY;
    } completion:^(BOOL finished) {
        startRefreshing = NO;
        isRefreshing = NO;
        [self.albumReflashImageView.layer removeAllAnimations];
    }];
    
    
}

@end
