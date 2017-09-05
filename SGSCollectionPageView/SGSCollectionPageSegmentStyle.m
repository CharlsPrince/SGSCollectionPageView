//
//  SGSCollectionPageSegmentStyle.m
//  RTLibrary-ios
//
//  Created by Lee on 16/8/18.
//  Copyright © 2016年 zlycare. All rights reserved.
//

#import "SGSCollectionPageSegmentStyle.h"

@implementation SGSCollectionPageSegmentStyle

- (instancetype)init {
    self = [super init];
    if (self) {
        _segmentHeight                    = 44.0;
        _segmentBackgroundColor           = [UIColor whiteColor];
        _colorGradient                    = YES;
        _normalTitleColor                 = [UIColor grayColor];
        _selectedTitleColor               = [UIColor redColor];
        _titleFont                        = [UIFont systemFontOfSize:17.0];
        _titleMargin                      = 10.0;
        _showSeparator                    = NO;
        _separatorColor                   = [UIColor lightGrayColor];
        _divideWhenSegmentSizeGreatTitles = YES;
        _cursorType                       = SGSCollectionPageSegmentCursorLine;
        _cursorHeight                     = 2.0;
        _cursorCornerRadius               = -1.0;
        _cursorColor                      = [UIColor redColor];
    }
    return self;
}

@end
