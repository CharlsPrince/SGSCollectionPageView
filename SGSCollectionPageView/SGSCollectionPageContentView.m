//
//  SGSCollectionPageContentView.m
//  RTLibrary-ios
//
//  Created by Lee on 16/8/18.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "SGSCollectionPageContentView.h"

static NSString *const kCellId = @"SGSCollectionPageContentViewCell";

static void const *kCollectionViewFrameDidChange = &kCollectionViewFrameDidChange;


@interface PageView : UICollectionView
@end

@implementation PageView

//- (void)willChangeValueForKey:(NSString *)key {
//    NSLog(@"即将改变");
//}

//- (void)didChangeValueForKey:(NSString *)key {
//    NSLog(@"已经改变");
//}
@end


@interface SGSCollectionPageContentView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UIViewController *parentVC;
@property (nonatomic, strong) NSArray *childVCs;
@property (nonatomic, strong) PageView *collectionView;
@property (nonatomic, assign) CGFloat beginDragOffsetX;

@end



@implementation SGSCollectionPageContentView

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame
         childViewControllers:(NSArray<UIViewController *> *)childVCs
         parentViewController:(UIViewController *)parentVC
{
    self = [super initWithFrame:frame];
    if (self) {
        _childVCs = childVCs;
        _parentVC = parentVC;
        _scrollEnabled = YES;
        _beginDragOffsetX = 0.0;
        
        // 将子控制器添加到父控制器中
        for (UIViewController *vc in _childVCs) {
            [_parentVC addChildViewController:vc];
            [vc didMoveToParentViewController:_parentVC];
        }
        
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)dealloc {
    if (_collectionView != nil) {
        [_collectionView removeObserver:self forKeyPath:@"frame"];
    }
}


#pragma mark - Public Methods

// 滚动到指定页面
- (void)scrollPageToIndex:(NSInteger)index animated:(BOOL)animated {
    if (index < _childVCs.count) {
        CGFloat x = (CGFloat)index * self.collectionView.bounds.size.width;
        CGPoint offset = CGPointMake(x, 0);
        
        [self setContentOffset:offset animated:animated];
    }
}

// 设置内容视图的偏移量
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated {
    [self.collectionView setContentOffset:offset animated:animated];
    
    if (!animated) {
        [self scrollViewDidEndDecelerating:self.collectionView];
    }
}

// 重新设置视图控制器集
- (void)resetChildViewControllers:(NSArray<UIViewController *> *)childVCs parentViewController:(UIViewController *)parentVC {
    for (UIViewController *vc in _childVCs) {
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }
    
    _childVCs = childVCs;
    _parentVC = parentVC;
    
    for (UIViewController *vc in _childVCs) {
        [_parentVC addChildViewController:vc];
        [vc didMoveToParentViewController:_parentVC];
    }
    
    [self.collectionView reloadData];
}


#pragma mark - Private Helper

// 当collectionView的位置大小改变时，同时改变内容的大小
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if (context != kCollectionViewFrameDidChange) return;
    
    CGRect frame = [change[NSKeyValueChangeNewKey] CGRectValue];
    ((UICollectionViewFlowLayout *)_collectionView.collectionViewLayout).itemSize = frame.size;
}



#pragma mark - UICollectionViewDataSource

// numberOfItems
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _childVCs.count;
}

// cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    
    for (UIView *sv in cell.contentView.subviews) {
        [sv removeFromSuperview];
    }
    
    UIViewController *vc = _childVCs[indexPath.item];
    vc.view.frame = cell.contentView.bounds;
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [cell.contentView addSubview:vc.view];
    
    return cell;
}


#pragma mark - UICollectionViewDelegate

// 滑动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    
    CGFloat temp = offsetX / self.bounds.size.width;
    CGFloat progress = temp - floor(temp);
    
    NSInteger oldIdx = 0;
    NSInteger newIdx = 0;
    
    if ((offsetX - _beginDragOffsetX) >= 0) {
        // 滚动开始和滚动完成的时候不要继续
        if (progress == 0) return;

        oldIdx = (NSInteger)floor(offsetX / self.bounds.size.width);
        newIdx = oldIdx + 1;
        
        // 防止越界
        if (newIdx >= _childVCs.count) return;
        
    } else {
        // 手指右滑，滑块左移
        newIdx = (NSInteger)floor(offsetX / self.bounds.size.width);
        oldIdx = newIdx + 1;
        
        // 防止越界
        if (oldIdx >= _childVCs.count) return;
        
        progress = 1.0 - progress;
    }
    
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(collectionPageContentView:scrollFrom:to:progress:)]) {
        [self.delegate collectionPageContentView:self scrollFrom:oldIdx to:newIdx progress:progress];
    }
}

// 开始拖拽
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _beginDragOffsetX = scrollView.contentOffset.x;
    
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(collectionPageContentViewWillBeginDragging:)]) {
        [self.delegate collectionPageContentViewWillBeginDragging:self];
    }
}

// 手动滑动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = (NSInteger)floor(scrollView.contentOffset.x / scrollView.bounds.size.width);
    
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(collectionPageContentView:didScrollToPage:)]) {
        [self.delegate collectionPageContentView:self didScrollToPage:index];
    }
}

// 动画滑动结束
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSInteger index = (NSInteger)floor(scrollView.contentOffset.x / scrollView.bounds.size.width);
    
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(collectionPageContentView:didScrollToPage:)]) {
        [self.delegate collectionPageContentView:self didScrollToPage:index];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout *)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return collectionView.bounds.size;
//}

#pragma mark - getter & setter 

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
}

- (PageView *)collectionView {
    if (_collectionView == nil) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0.0;
        layout.minimumInteritemSpacing = 0.0;
        layout.itemSize = self.bounds.size;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsZero;
        
        PageView *coll = [[PageView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        coll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        coll.backgroundColor = [UIColor whiteColor];
        
        coll.scrollEnabled = self.scrollEnabled;
        coll.bounces = NO;
        coll.pagingEnabled = YES;
        coll.showsHorizontalScrollIndicator = NO;
        
        coll.dataSource = self;
        coll.delegate = self;
        [coll registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellId];
        
        
        _collectionView = coll;
        
        [_collectionView addObserver:self forKeyPath:@"frame"
                             options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                             context:&kCollectionViewFrameDidChange];
    }
    return _collectionView;
}

@end
