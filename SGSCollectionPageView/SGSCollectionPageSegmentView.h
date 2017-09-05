//
//  SGSCollectionPageSegmentView.h
//  RTLibrary-ios
//
//  Created by Lee on 16/8/18.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SGSCollectionPageSegmentView;
@class SGSCollectionPageSegmentStyle;

NS_ASSUME_NONNULL_BEGIN

/**
 *  集合页面标签视图代理
 */
@protocol SGSCollectionPageSegmentViewDelegate <NSObject>

@optional

/**
 *  点击标签
 *
 *  @param view       集合页面标签视图
 *  @param titleLabel 点击的标题标签
 *  @param index      标签下标
 */
- (void)collectionPageSegmentView:(SGSCollectionPageSegmentView *)view didSelectedTitle:(UILabel *)titleLabel index:(NSInteger)index;

@end



/**
 *  集合页面标签视图
 */
@interface SGSCollectionPageSegmentView : UIView


/// 代理
@property (nonatomic, weak) id<SGSCollectionPageSegmentViewDelegate> delegate;

/// 样式
@property (nonatomic, strong) SGSCollectionPageSegmentStyle *style;

/// 标题数组
@property (nonatomic, strong) NSArray<NSString *> *titles;

/// 标题是否可选
@property (nonatomic, assign) BOOL titleSelectable;

/// 背景图片
@property (nonatomic, strong) UIImage *backgroundImage;



/**
 *  指定初始化方法
 *
 *  @param frame  视图大小
 *  @param style  样式
 *  @param titles 标题
 *
 *  @return 集合页面标签视图
 */

- (instancetype)initWithFrame:(CGRect)frame
                        style:(SGSCollectionPageSegmentStyle *)style
                       titles:(NSArray<NSString *> *)titles NS_DESIGNATED_INITIALIZER;

/**
 *  根据标题和样式计算合适的大小
 *
 *  @param titles 标题
 *  @param style  样式
 *
 *  @return 标签合适的大小
 */
+ (CGSize)fitSizeWithTitles:(NSArray<NSString *> *)titles
                       style:(SGSCollectionPageSegmentStyle *)style;

/**
 *  根据下标选择标题
 *
 *  @param index    标签下标
 *  @param animated YES（有滚动动画），NO（没有滚动动画）
 */
- (void)selectTitleWithIndex:(NSInteger)index
                    animated:(BOOL)animated;

/**
 *  调整标题位置
 *
 *  @param index    标题位置下标
 *  @param animated YES（有滚动动画），NO（没有滚动动画）
 */
- (void)adjustTitleOffsetToCurrentIndex:(NSInteger)index
                               animated:(BOOL)animated;

/**
 *  根据进度调整标签
 *
 *  @param progress 进度（0.0~1.0）
 *  @param oldIndex 旧下标
 *  @param newIndex 新下标
 */
- (void)adjustUIWithProgress:(CGFloat)progress
                    oldIndex:(NSInteger)oldIndex
                    newIndex:(NSInteger)newIndex;

@end

NS_ASSUME_NONNULL_END
