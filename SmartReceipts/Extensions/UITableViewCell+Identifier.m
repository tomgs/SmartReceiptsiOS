//
//  UITableViewCell+Identifier.m
//  SmartReceipts
//
//  Created by Jaanus Siim on 30/04/15.
//  Copyright (c) 2015 Will Baumann. All rights reserved.
//

#import "UITableViewCell+Identifier.h"

@implementation UITableViewCell (Identifier)

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self class]);
}

@end
