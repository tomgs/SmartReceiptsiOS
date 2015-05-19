//
//  ReportCSVGenerator.m
//  SmartReceipts
//
//  Created by Jaanus Siim on 25/04/15.
//  Copyright (c) 2015 Will Baumann. All rights reserved.
//

#import "ReportCSVGenerator.h"
#import "WBDB.h"

@implementation ReportCSVGenerator

- (NSArray *)receiptColumns {
    return [[WBDB csvColumns] selectAll];
}

@end