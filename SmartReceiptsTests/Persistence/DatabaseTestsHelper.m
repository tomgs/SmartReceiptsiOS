//
//  DatabaseTestsHelper.m
//  SmartReceipts
//
//  Created by Jaanus Siim on 02/05/15.
//  Copyright (c) 2015 Will Baumann. All rights reserved.
//

#import "DatabaseTestsHelper.h"
#import "WBTrip.h"
#import "Distance.h"
#import "WBPrice.h"
#import "Database+Distances.h"
#import "Database+Trips.h"
#import "WBReceipt.h"
#import "DatabaseTableNames.h"
#import "Database+Receipts.h"
#import "NSString+Validation.h"
#import "PaymentMethod.h"
#import "Database+PaymentMethods.h"
#import "Database+Functions.h"
#import "DatabaseQueryBuilder.h"
#import "WBCurrency.h"

@interface Distance (TestExpose)

- (id)initWithTrip:(WBTrip *)trip distance:(NSDecimalNumber *)distance rate:(WBPrice *)rate location:(NSString *)location date:(NSDate *)date timeZone:(NSTimeZone *)timeZone comment:(NSString *)comment;

@end

@implementation DatabaseTestsHelper

- (WBTrip *)createTestTrip {
    return [self insertTrip:@{}];
}

- (WBTrip *)insertTrip:(NSDictionary *)modifiedParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[TripsTable.COLUMN_NAME] = [NSString stringWithFormat:@"TestTrip - %f", [NSDate timeIntervalSinceReferenceDate]];
    params[TripsTable.COLUMN_FROM] = [NSDate date];
    params[TripsTable.COLUMN_TO] = [NSDate date];
    params[TripsTable.COLUMN_DEFAULT_CURRENCY] = @"USD";
    [params addEntriesFromDictionary:modifiedParams];

    WBTrip *trip = [[WBTrip alloc] init];
    [trip setName:params[TripsTable.COLUMN_NAME]];
    [trip setStartDate:params[TripsTable.COLUMN_FROM]];
    [trip setEndDate:params[TripsTable.COLUMN_TO]];
    [trip setDefaultCurrency:[WBCurrency currencyForCode:params[TripsTable.COLUMN_DEFAULT_CURRENCY]]];
    [trip setComment:params[TripsTable.COLUMN_COMMENT]];
    [trip setCostCenter:params[TripsTable.COLUMN_COST_CENTER]];

    [self saveTrip:trip];
    return trip;
}

- (void)insertPaymentMethod:(NSString *)name {
    name = [name hasValue] ? name : [NSString stringWithFormat:@"TestMethod - %f", [NSDate timeIntervalSinceReferenceDate]];
    PaymentMethod *method = [[PaymentMethod alloc] init];
    [method setMethod:name];
    [self savePaymentMethod:method];
}

- (void)insertDistance:(NSDictionary *)modifiedParams {
    NSMutableDictionary *defaultParams = [NSMutableDictionary dictionary];
    defaultParams[DistanceTable.COLUMN_LOCATION] = @"Test location";
    defaultParams[DistanceTable.COLUMN_PARENT] = [self createTestTrip];
    defaultParams[DistanceTable.COLUMN_DATE] = [NSDate date];
    defaultParams[DistanceTable.COLUMN_DISTANCE] = [NSDecimalNumber decimalNumberWithString:@"10"];
    defaultParams[DistanceTable.COLUMN_RATE] = [NSDecimalNumber decimalNumberWithString:@"12"];
    defaultParams[DistanceTable.COLUMN_RATE_CURRENCY] = @"USD";

    [defaultParams addEntriesFromDictionary:modifiedParams];

    NSDictionary *params = [NSDictionary dictionaryWithDictionary:defaultParams];

    Distance *distance = [[Distance alloc] initWithTrip:params[DistanceTable.COLUMN_PARENT]
                                               distance:params[DistanceTable.COLUMN_DISTANCE]
                                                   rate:[WBPrice priceWithAmount:params[DistanceTable.COLUMN_RATE] currencyCode:params[DistanceTable.COLUMN_RATE_CURRENCY]]
                                               location:params[DistanceTable.COLUMN_LOCATION]
                                                   date:params[DistanceTable.COLUMN_DATE]
                                               timeZone:[NSTimeZone defaultTimeZone]
                                                comment:@"Comment"];
    [self saveDistance:distance];
}

- (void)insertReceipt:(NSDictionary *)modifiedParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[ReceiptsTable.COLUMN_NAME] = [NSString stringWithFormat:@"TestReceipt - %f", [NSDate timeIntervalSinceReferenceDate]];
    params[ReceiptsTable.COLUMN_PARENT] = [self createTestTrip];
    params[ReceiptsTable.COLUMN_PRICE] = [NSDecimalNumber decimalNumberWithString:@"20"];
    params[ReceiptsTable.COLUMN_ISO4217] = @"USD";
    params[ReceiptsTable.COLUMN_EXPENSEABLE] = @(YES);

    [params addEntriesFromDictionary:modifiedParams];

    WBReceipt *receipt = [[WBReceipt alloc] initWithId:NSNotFound
                                                  name:params[ReceiptsTable.COLUMN_NAME]
                                              category:@""
                                         imageFileName:@""
                                                dateMs:0
                                          timeZoneName:[NSTimeZone localTimeZone].name
                                               comment:@""
                                                 price:[WBPrice priceWithAmount:params[ReceiptsTable.COLUMN_PRICE] currencyCode:params[ReceiptsTable.COLUMN_ISO4217]]
                                                   tax:[WBPrice zeroPriceWithCurrencyCode:@"USD"]
                                          isExpensable:[params[ReceiptsTable.COLUMN_EXPENSEABLE] boolValue]
                                            isFullPage:0
                                        extraEditText1:@""
                                        extraEditText2:@""
                                        extraEditText3:@""];
    [receipt setTrip:params[ReceiptsTable.COLUMN_PARENT]];
    [receipt setPaymentMethod:params[ReceiptsTable.COLUMN_PAYMENT_METHOD_ID]];
    [self saveReceipt:receipt];
}

- (WBReceipt *)receiptWithName:(NSString *)receiptName {
    DatabaseQueryBuilder *selectAll = [DatabaseQueryBuilder selectAllStatementForTable:ReceiptsTable.TABLE_NAME];
    [selectAll where:ReceiptsTable.COLUMN_NAME value:receiptName];
    WBReceipt *receipt = (WBReceipt *)[self executeFetchFor:[WBReceipt class] withQuery:selectAll];
    [receipt setTrip:[self tripWithName:receipt.tripName]];
    [receipt setPaymentMethod:[self paymentMethodById:receipt.paymentMethodId]];
    return receipt;
}

@end
