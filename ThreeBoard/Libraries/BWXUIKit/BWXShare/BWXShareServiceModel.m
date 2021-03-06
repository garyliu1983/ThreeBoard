//
//  BWXShareServiceModel.m
//  BWXUIKit
//
//  Created by easy on 12-10-24.
//  Copyright (c) 2012年 baidu. All rights reserved.
//

#import "BWXShareServiceModel.h"
#import "BWXUIKit.h"

//NSString * const BWXShareServiceTypeWeibo = @"BWXShareServiceTypeWeibo";
//NSString * const BWXShareServiceTypeQQWeibo = @"BWXShareServiceTypeQQWeibo";
//NSString * const BWXShareServiceTypeRenRen = @"BWXShareServiceTypeRenRen";

@interface BWXShareServiceModel () {
    UIImage *_icon;
    BWXShareType _serviceType;
}

@end

@implementation BWXShareServiceModel
@synthesize icon = _icon;
@synthesize serviceType = _serviceType;
- (void)dealloc {
    [_icon release],_icon = nil;
    [super dealloc];
}



+(id) modelForServiceType:(BWXShareType) serviceType {
    BWXShareServiceModel *model = nil;
    switch (serviceType) {
        case BWXShareTypeSinaWeibo:
            model = [[[BWXShareServiceModel alloc] init] autorelease];
            model->_icon = [BWXPNGImage(@"image-weibo",@"BWXShare.bundle") retain];
            model->_serviceType = BWXShareTypeSinaWeibo;
            break;
        case BWXShareTypeTencentWeibo:
            model = [[[BWXShareServiceModel alloc] init] autorelease];
            model->_icon = [BWXPNGImage(@"image-txweibo",@"BWXShare.bundle") retain];
            model->_serviceType = BWXShareTypeTencentWeibo;
            break;
        case BWXShareTypeRenren:
            model = [[[BWXShareServiceModel alloc] init] autorelease];
            model->_icon = [BWXPNGImage(@"image-renren",@"BWXShare.bundle") retain];
            model->_serviceType = serviceType;
            break;
        case BWXShareTypeQZone:
            model = [[[BWXShareServiceModel alloc] init] autorelease];
            model->_icon = [BWXPNGImage(@"image-qzone",@"BWXShare.bundle") retain];
            model->_serviceType = serviceType;
            break;
        case BWXShareTypeWeixinSession:
            model = [[[BWXShareServiceModel alloc] init] autorelease];
            model->_icon = [BWXPNGImage(@"image-weixin",@"BWXShare.bundle") retain];
            model->_serviceType = serviceType;
            break;
        case BWXShareTypeWeixinTimeline:
            model = [[[BWXShareServiceModel alloc] init] autorelease];
            model->_icon = [BWXPNGImage(@"image-weixin",@"BWXShare.bundle") retain];
            model->_serviceType = serviceType;
            break;
        default:
            break;
    }
    
    return model;
}

+ (BOOL)isAvailableForServiceType:(BWXShareType)serviceType {
    return  serviceType == BWXShareTypeSinaWeibo ||
            serviceType == BWXShareTypeTencentWeibo ||
            serviceType == BWXShareTypeRenren ||
            serviceType == BWXShareTypeQZone ||
            serviceType == BWXShareTypeWeixinSession ||
            serviceType == BWXShareTypeWeixinTimeline;
}

+(NSArray *) availableServiceTypes {
    return [NSArray arrayWithObjects:[NSNumber numberWithInt:BWXShareTypeSinaWeibo],
            [NSNumber numberWithInt:BWXShareTypeTencentWeibo],
             [NSNumber numberWithInt:BWXShareTypeRenren],
            [NSNumber numberWithInt:BWXShareTypeQZone],
            [NSNumber numberWithInt:BWXShareTypeWeixinSession],
            [NSNumber numberWithInt:BWXShareTypeWeixinTimeline],
            nil];
}



@end
