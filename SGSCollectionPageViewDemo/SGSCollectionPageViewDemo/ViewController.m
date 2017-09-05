//
//  ViewController.m
//  SGSCollectionPageViewDemo
//
//  Created by Lee on 16/8/31.
//  Copyright © 2016年 arKenLee. All rights reserved.
//

#import "ViewController.h"
#import "SGSCollectionPageView.h"

#define kLazy(object, assignment...) ((object) = (object) ?: (assignment))

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *cellTitles;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *vcs;
@end


@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"集合页面视图";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource       = self;
    tableView.delegate         = self;
    
    [self.view addSubview:tableView];
}

#pragma mark - Private

// 不使用游标集合视图
- (void)pushNoneStylePageView {
    SGSCollectionPageSegmentStyle *style = [SGSCollectionPageSegmentStyle new];
    style.cursorType = SGSCollectionPageSegmentCursorNone;
    
    [self pushPageViewControllerWithStyle:style title:@"不使用游标"];
}

// 滚动条样式集合视图
- (void)pushLineStylePageView {
    SGSCollectionPageSegmentStyle *style = [SGSCollectionPageSegmentStyle new];
    
    [self pushPageViewControllerWithStyle:style title:@"滚动条样式"];
}

// 外边框样式集合视图
- (void)pushBorderStylePageView {
    SGSCollectionPageSegmentStyle *style = [SGSCollectionPageSegmentStyle new];
    style.cursorType = SGSCollectionPageSegmentCursorBorder;
    
    [self pushPageViewControllerWithStyle:style title:@"外边框样式"];
}

// 掩膜样式集合视图
- (void)pushMaskStylePageView {
    SGSCollectionPageSegmentStyle *style = [SGSCollectionPageSegmentStyle new];
    style.cursorType = SGSCollectionPageSegmentCursorMask;
    style.selectedTitleColor = [UIColor whiteColor];
    
    [self pushPageViewControllerWithStyle:style title:@"掩膜样式"];
}

// 显示分隔线
- (void)pushSeperatorStylePageView {
    SGSCollectionPageSegmentStyle *style = [SGSCollectionPageSegmentStyle new];
    style.showSeparator = YES; // 显示分隔线
    
    [self pushPageViewControllerWithStyle:style title:@"滚动条样式"];
}

// 平均宽度样式
- (void)pushAvaPageView {
    SGSCollectionPageSegmentStyle *style = [SGSCollectionPageSegmentStyle new];
    style.showSeparator = YES;
    
    UIViewController *vc = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    vc.navigationItem.title = @"平均宽度";
    vc.edgesForExtendedLayout = UIRectEdgeNone;
    vc.automaticallyAdjustsScrollViewInsets = NO;
    vc.view.backgroundColor = [UIColor whiteColor];
    
    NSRange range = {0, 4};
    NSArray *subVCs = [self.vcs subarrayWithRange:range];
    NSArray *subTitles = @[@"Life", @"我的关注", @"粉丝", @"最新评论"];
    
    SGSCollectionPageView *pageView = [SGSCollectionPageView pageViewWithFrame:self.view.bounds style:style titles:subTitles childViewControllers:subVCs parentViewController:vc];
    
    [vc.view addSubview:pageView];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushPageViewControllerWithStyle:(SGSCollectionPageSegmentStyle *)style title:(NSString *)title {
    
    UIViewController *vc = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    vc.navigationItem.title = title;
    vc.edgesForExtendedLayout = UIRectEdgeNone;
    vc.automaticallyAdjustsScrollViewInsets = NO;
    
    SGSCollectionPageView *pageView = [SGSCollectionPageView pageViewWithFrame:self.view.bounds style:style titles:self.titles childViewControllers:self.vcs parentViewController:vc];

    [vc.view addSubview:pageView];
    
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = self.cellTitles[indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            [self pushNoneStylePageView];
            break;
        case 1:
            [self pushLineStylePageView];
            break;
        case 2:
            [self pushBorderStylePageView];
            break;
        case 3:
            [self pushMaskStylePageView];
            break;
        case 4:
            [self pushSeperatorStylePageView];
            break;
        case 5:
            [self pushAvaPageView];
            break;
            
        default:
            break;
    }
}

#pragma mark - getter & setter

// 懒加载cell标题
- (NSArray *)cellTitles {
    return kLazy(_cellTitles, @[@"不使用游标", @"滚动条样式", @"外边框样式", @"掩膜样式", @"带有分隔线", @"平均标题宽度"]);
}

// 懒加载标题
- (NSArray *)titles {
    return kLazy(_titles, @[@"今日头条", @"精选", @"财经频道", @"科技", @"政治", @"军事", @"娱乐八卦", @"体育", @"时尚"]);
}

// 懒加载子控制器
- (NSArray *)vcs {
    return kLazy(_vcs, {
        NSMutableArray *arr = [NSMutableArray array];
        
        NSArray *colors = @[[UIColor orangeColor], [UIColor greenColor], [UIColor blueColor]];
        
        [self.titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIViewController *vc = [[UIViewController alloc] initWithNibName:nil bundle:nil];
            vc.title = obj;
            idx = (idx < 3) ? idx : (idx % 3);
            vc.view.backgroundColor = colors[idx];
            
            [arr addObject:vc];
        }];
        arr.copy;
    });
}

@end
