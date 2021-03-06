//
//  BWXShareActionController.m
//  BWXUIKit
//
//  Created by easy on 12-10-19.
//  Copyright (c) 2012年 baidu. All rights reserved.
//

#import "BWXShareActionSheet.h"
#import "UITableView+BWXShare.h"
#import "BWXShareBaseService.h"
#import "BWXShareViewController.h"
#import "BWXShareServiceModel.h"
#import "BWXShareCenter.h"

#import "BWXUIKit.h"



@class BWXShareActionViewController;

@interface BWXShareActionSheet () <UITableViewDataSource,UITableViewDelegate>{
    UIWindow *_window;      //retain
    
    UIControl *_maskControl;    //noretain
    UITableView *_tableView;    //noretain

    NSString *_cancelTitle;
    
    
    NSArray *_serviceModels;
    NSArray *_services;
        
    CGFloat _numberOfCells;
    CGFloat _tableViewHeight;
    CGFloat _heightOfRow;
    
    NSTimeInterval _showAnimtedInterval;
    NSTimeInterval _hideAnimtedInterval;
    
    UIColor *_maskColor;
    UIColor *_baseColor;
    
    id<BWXShareActionSheetDelegate> _delegate;
}



@property (nonatomic,copy) NSString *cancelTitle;
@property (nonatomic, retain) UIColor *maskColor;
@property (assign,readonly,getter=isShow) BOOL show;

@end

@implementation BWXShareActionSheet

@synthesize cancelTitle = _cancelTitle;
@synthesize maskColor = _maskColor;
@synthesize delegate = _delegate;
- (void)dealloc {
    
    _delegate = nil;
    [_maskColor release],_maskColor = nil;
    [_baseColor release],_baseColor = nil;
    [_window release],_window = nil;
    [_cancelTitle release],_cancelTitle = nil;
    [_serviceModels release],_serviceModels = nil;
    [_services release],_services = nil;
    [super dealloc];
}

-(id)init {
    return [self initWithServiceTypes:[BWXShareServiceModel availableServiceTypes]];
}

-(id) initWithServiceTypes:(NSArray *) serviceTypes {
    self = [super init];
    if (self) {
        NSMutableArray *availableServiceModels = [NSMutableArray array];
        NSMutableArray *services = [NSMutableArray array];
        for (NSNumber *serviceType in serviceTypes) {
            id model = [BWXShareServiceModel modelForServiceType:[serviceType intValue]];
            BWXShareBaseService *service = [BWXShareBaseServiceFactory makeShareServiceByType:[serviceType intValue]];
            if (model && service) {
                [availableServiceModels addObject:model];
                [services addObject:service];
            }
        }
        
        if ([availableServiceModels count] > 0) {
            _serviceModels = [availableServiceModels retain];
            _services = [services retain];
            _numberOfCells = [_serviceModels count] + 1;
            _heightOfRow = 45;
            _tableViewHeight = _heightOfRow * _numberOfCells;
            
            _showAnimtedInterval = 0.2f;
            _hideAnimtedInterval = 0.2f;
            
            _maskColor = [[UIColor alloc] initWithWhite:0 alpha:0.6f];
            _baseColor = [[UIColor alloc] initWithWhite:0 alpha:0];
            
            _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            _window.windowLevel = UIWindowLevelAlert;
            _window.backgroundColor = [UIColor clearColor];
        
            
            _maskControl = [[[UIControl alloc] initWithFrame:_window.bounds] autorelease];
            [_maskControl addTarget:self action:@selector(maskControlPressed:) forControlEvents:UIControlEventTouchDown];
            _maskControl.backgroundColor = _baseColor;
            [_window addSubview:_maskControl];
            
            _tableView = [[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain] autorelease];
            _tableView.scrollEnabled = NO;
            _tableView.delegate = self;
            _tableView.dataSource = self;
            [_window addSubview:_tableView];
        } else {
            [self release],self = nil;
        }
    }
    return self;
}


-(void)show {
    [self retain];
    _window.hidden = NO;
    
    _tableView.frame =CGRectMake(0, CGRectGetMaxY(_window.frame), CGRectGetWidth(_window.frame), _tableViewHeight);
    [UIView animateWithDuration:_showAnimtedInterval animations:^{
        _maskControl.backgroundColor = _maskColor;
        _tableView.frame =CGRectMake(0, CGRectGetMaxY(_window.frame) - _tableViewHeight, CGRectGetWidth(_window.frame), _tableViewHeight);
    }];
}

- (void) didCancel {
    if ([_delegate respondsToSelector:@selector(shareActionSheetCancelled:)]) {
        [_delegate shareActionSheetCancelled:self];
    }
}

- (void)dismiss {
    [UIView animateWithDuration:_hideAnimtedInterval animations:^{
        _maskControl.backgroundColor = _baseColor;
        _tableView.frame =CGRectMake(0, CGRectGetMaxY(_window.frame), CGRectGetWidth(_window.frame), _tableViewHeight);
    } completion:^(BOOL finished) {
        _window.hidden = YES;
        [self autorelease];
    }];
}


-(void) maskControlPressed:(id) sender {
    [self didCancel];
    [self dismiss];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *c = nil;
    NSUInteger numberOfRow = [tableView numberOfRowsInSection:[indexPath section]];
    NSUInteger row = [indexPath row];
    if (row == numberOfRow - 1) {   //cancel
        c = [tableView dequeueReusableCellWithIdentifier:@"cancel"];
        if (!c) {
            c = [[[BWXShareCancelCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cancel"] autorelease];
        }
        BWXShareCancelCell *cell = (BWXShareCancelCell *)c;
        cell.cancel = _cancelTitle;
    } else {
        c = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!c) {
            c = [[[BWXShareServiceBindingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        }
        BWXShareServiceBindingCell *cell = (BWXShareServiceBindingCell *)c;
        BWXShareServiceModel *model = [_serviceModels objectAtIndex:row];
        
        BWXShareBaseService *service = [_services objectAtIndex:row];
        cell.serviceName = service.typeName;
        
        cell.serviceImage = model.icon;
        cell.serviceBinding = [service isLoggedIn];
    }
    
    
    c.backgroundColor = [UIColor whiteColor];
    
    UIImageView *backgroundView = [[[UIImageView alloc] init] autorelease];
    UIImageView *selectedBackgroundView = [[[UIImageView alloc] init] autorelease];
    
    
    c.backgroundView = backgroundView;
    c.selectedBackgroundView = selectedBackgroundView;
    
    if (row == numberOfRow - 1) {
        backgroundView.image = BWXPNGImage(@"image-cell-cancel", @"BWXShare.bundle");
        selectedBackgroundView.image = BWXPNGImage(@"image-cell-cancel-selected", @"BWXShare.bundle");
    } else {
        
        backgroundView.backgroundColor = [UIColor whiteColor];
        selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(CGFloat)0xed/255 green:(CGFloat)0xef/255 blue:(CGFloat)0xf2/255 alpha:1];
    }
    
    return c;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _numberOfCells;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger numberOfRow = [tableView numberOfRowsInSection:[indexPath section]];
    NSUInteger row = [indexPath row];
    if (row == numberOfRow - 1) {
        [self didCancel];
        [self dismiss];
        return;
    }

    BWXShareBaseService *service = [_services objectAtIndex:row];
    
    if ([_delegate respondsToSelector:@selector(shareActionSheet:didSelectShareService:)]) {
        [_delegate shareActionSheet:self didSelectShareService:service];
    }

    [self dismiss];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _heightOfRow;
}

@end

