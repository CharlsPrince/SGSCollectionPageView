//
//  SGSCollectionPageView.h
//  RTLibrary-ios
//
//  Created by Lee on 16/8/18.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGSCollectionPageSegmentStyle.h"

@class SGSCollectionPageView;
@class SGSCollectionPageSegmentView;
@class SGSCollectionPageContentView;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - SGSCollectionPageViewDelegate

/**
 *  集合页面视图代理
 */
@protocol SGSCollectionPageViewDelegate <NSObject>

@optional

/**
 *  集合页面视图滚动到指定页
 *
 *  @param view      集合页面视图
 *  @param pageIndex 页面滚动后的下标
 */
- (void)collectionPageView:(SGSCollectionPageView *)view didScrollToPage:(NSInteger)pageIndex;

@end



#pragma mark - SGSCollectionPageView

/**
 *  集合页面视图
 */
@interface SGSCollectionPageView : UIView

/// 代理
@property (nonatomic, weak) id<SGSCollectionPageViewDelegate> delegate;

/// 标题分段
@property (nonatomic, strong, readonly) SGSCollectionPageSegmentView *segment;

/// 内容视图
@property (nonatomic, strong, readonly) SGSCollectionPageContentView *contentView;

/// 是否允许滑动，默认为YES
@property (nonatomic, assign) BOOL scrollEnabled;

/// 是否隐藏标题分段，默认为NO
@property (nonatomic, assign) BOOL hideSegment;


/// 请使用指定初始化方法
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 *  指定初始化方法
 *
 *  @param frame    视图位置大小
 *  @param style    样式
 *  @param titles   标题
 *  @param childVCs 子控制器集
 *  @param parentVC 父控制器
 *
 *  @return SGSCollectionPageView，当标题个数与子控制器个数不相等时返回nil
 */
- (nullable instancetype)initWithFrame:(CGRect)frame
                                 style:(SGSCollectionPageSegmentStyle *)style
                                titles:(NSArray<NSString *> *)titles
                  childViewControllers:(NSArray<UIViewController *> *)childVCs
                  parentViewController:(UIViewController *)parentVC NS_DESIGNATED_INITIALIZER;

/**
 *  类初始化方法
 *
 *  @param frame    视图位置大小
 *  @param style    样式
 *  @param titles   标题
 *  @param childVCs 子控制器集
 *  @param parentVC 父控制器
 *
 *  @return SGSCollectionPageView，当标题个数与子控制器个数不相等时返回nil
 */
+ (nullable instancetype)pageViewWithFrame:(CGRect)frame
                                     style:(SGSCollectionPageSegmentStyle *)style
                                    titles:(NSArray<NSString *> *)titles
                      childViewControllers:(NSArray<UIViewController *> *)childVCs
                      parentViewController:(UIViewController *)parentVC;

/**
 *  滚动到指定页面
 *
 *  @param index    页面下标
 *  @param animated YES（有滚动动画），NO（没有滚动动画）
 */
- (void)scrollPageToIndex:(NSInteger)index animated:(BOOL)animated;


/**
 *  重新设置内容
 *
 *  @param titles   标题
 *  @param childVCs 子控制器集
 *  @param parentVC 父控制器
 */
- (void)resetWithTitles:(NSArray<NSString *> *)titles
   childViewControllers:(NSArray<UIViewController *> *)childVCs
   parentViewController:(UIViewController *)parentVC;


@end

NS_ASSUME_NONNULL_END
