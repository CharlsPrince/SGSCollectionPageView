//
//  SGSCollectionPageContentView.h
//  RTLibrary-ios
//
//  Created by Lee on 16/8/18.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGSCollectionPageContentView;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - SGSCollectionPageContentViewDelegate

/**
 *  集合页面内容视图代理
 */
@protocol SGSCollectionPageContentViewDelegate <NSObject>

@optional

/**
 *  集合内容视图已滚动到指定页
 *
 *  @param view      集合内容视图
 *  @param pageIndex 指定页
 */
- (void)collectionPageContentView:(SGSCollectionPageContentView *)view didScrollToPage:(NSInteger)pageIndex;

/**
 *  集合内容视图拖动的进度
 *
 *  @param view     集合内容视图
 *  @param oldIndex 拖动之前的下标
 *  @param newIndex 拖动的新下标
 *  @param progress 拖动的进度
 */
- (void)collectionPageContentView:(SGSCollectionPageContentView *)view scrollFrom:(NSInteger)oldIndex to:(NSInteger)newIndex progress:(CGFloat)progress;

/**
 *  集合内容视图开始拖动
 *
 *  @param view 集合内容视图
 */
- (void)collectionPageContentViewWillBeginDragging:(SGSCollectionPageContentView *)view;

@end






#pragma mark - SGSCollectionPageContentView

/**
 *  集合页面内容视图
 */
@interface SGSCollectionPageContentView : UIView

/// 代理
@property (nonatomic, weak) id<SGSCollectionPageContentViewDelegate> delegate;

/// 能否滚动视图
@property (nonatomic, assign) BOOL scrollEnabled;

/// 请使用指定初始化方法
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 *  指定初始化方法
 *
 *  @param frame  视图位置大小
 *  @param child  子视图控制器
 *  @param parent 父视图控制器
 *
 *  @return SGSCollectionPageContentView
 */
- (instancetype)initWithFrame:(CGRect)frame
         childViewControllers:(NSArray<UIViewController *> *)childVCs
         parentViewController:(UIViewController *)parentVC NS_DESIGNATED_INITIALIZER;


/**
 *  滚动到指定页面
 *
 *  @param index    指定页面下标
 *  @param animated YES（有滚动动画），NO（没有滚动动画）
 */
- (void)scrollPageToIndex:(NSInteger)index animated:(BOOL)animated;


/**
 *  设置内容视图的偏移量
 *
 *  @param offset   偏移量
 *  @param animated YES（有滚动动画），NO（没有滚动动画）
 */
- (void)setContentOffset:(CGPoint)offset animated:(BOOL)animated;


/**
 *  重新设置视图控制器集
 *
 *  @param child  子控制器组
 *  @param parent 父控制器
 */
- (void)resetChildViewControllers:(NSArray<UIViewController *> *)childVCs parentViewController:(UIViewController *)parentVC;

@end

NS_ASSUME_NONNULL_END