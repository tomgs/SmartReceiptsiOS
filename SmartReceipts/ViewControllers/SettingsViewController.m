//
//  SettingsViewController.m
//  SmartReceipts
//
//  Created on 13/03/14.
//  Copyright (c) 2014 Will Baumann. All rights reserved.
//

#import "SettingsViewController.h"
#import "WBCurrency.h"
#import "WBColumnsViewController.h"

#import "WBPreferences.h"
#import "WBDateFormatter.h"

#import "WBBackupHelper.h"

#import "HUD.h"
#import "WBCustomization.h"
#import "SettingsTopTitledTextEntryCell.h"
#import "UIView+LoadHelpers.h"
#import "UITableViewCell+Identifier.h"
#import "InputCellsSection.h"
#import "InlinedPickerCell.h"
#import "PickerCell.h"
#import "SettingsSegmentControlCell.h"
#import "SwitchControlCell.h"
#import "SettingsButtonCell.h"
#import "UIAlertView+Blocks.h"
#import "NSDecimalNumber+WBNumberParse.h"
#import "Pickable.h"
#import "StringPickableWrapper.h"

// for refreshing while backup
static SettingsViewController *visibleInstance = nil;

static NSString *const PushManageCategoriesSegueIdentifier = @"PushManageCategoriesSegueIdentifier";
static NSString *const PushConfigurePDFColumnsSegueIdentifier = @"ConfigurePDF";
static NSString *const PushConfigureCSVColumnsSegueIdentifier = @"ConfigureCSV";
static NSString *const PushPaymentMethodsControllerSegueIdentifier = @"PushPaymentMethodsControllerSegueIdentifier";

@interface SettingsViewController () <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *cameraValues;

@property (nonatomic, strong) SettingsTopTitledTextEntryCell *emailCell;
@property (nonatomic, strong) SettingsTopTitledTextEntryCell *defaultTripLengthCell;
@property (nonatomic, strong) SettingsTopTitledTextEntryCell *minReportablePriceCell;
@property (nonatomic, strong) SettingsTopTitledTextEntryCell *userIdCell;
@property (nonatomic, strong) PickerCell *defaultCurrencyCell;
@property (nonatomic, strong) InlinedPickerCell *defaultCurrencyPickerCell;
@property (nonatomic, strong) SettingsSegmentControlCell *dateSeparatorCell;
@property (nonatomic, strong) SwitchControlCell *costCenterCell;
@property (nonatomic, strong) SettingsSegmentControlCell *cameraSettingsCell;
@property (nonatomic, strong) SwitchControlCell *predictReceiptCategoriesCell;
@property (nonatomic, strong) SwitchControlCell *includeTaxFieldCell;
@property (nonatomic, strong) SwitchControlCell *matchNameToCategoriesCell;
@property (nonatomic, strong) SwitchControlCell *matchCommentsToCategoriesCell;
@property (nonatomic, strong) SwitchControlCell *onlyReportExpenseableCell;
@property (nonatomic, strong) SwitchControlCell *enableAutocompleteSuggestionsCell;
@property (nonatomic, strong) SwitchControlCell *defaultReceiptDateToReportStartCell;
@property (nonatomic, strong) SwitchControlCell *usePaymentMethodsCell;
@property (nonatomic, strong) SettingsButtonCell *customizePaymentMethodsCell;

@property (nonatomic, strong) SettingsButtonCell *manageCategoriesCell;

@property (nonatomic, strong) SwitchControlCell *includeCSVHeadersCell;
@property (nonatomic, strong) SettingsButtonCell *configureCSVColumnsCell;

@property (nonatomic, strong) SettingsButtonCell *configurePDFColumnsCell;

@property (nonatomic, strong) SwitchControlCell *addDistancePriceToReportCell;
@property (nonatomic, strong) SettingsTopTitledTextEntryCell *gasRateCell;
@property (nonatomic, strong) SwitchControlCell *includeDistanceTableCell;
@property (nonatomic, strong) SwitchControlCell *reportOnDailyDistanceCell;

@property (nonatomic, strong) SettingsButtonCell *backupCell;

@end

@implementation SettingsViewController

+ (SettingsViewController *) visibleInstance {
    return visibleInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [WBCustomization customizeOnViewDidLoad:self];

    [self setContainNextEditSearchInsideSection:YES];
    
    self.navigationItem.title = NSLocalizedString(@"Settings", nil);

    [self.tableView registerNib:[SettingsTopTitledTextEntryCell viewNib] forCellReuseIdentifier:[SettingsTopTitledTextEntryCell cellIdentifier]];
    [self.tableView registerNib:[PickerCell viewNib] forCellReuseIdentifier:[PickerCell cellIdentifier]];
    [self.tableView registerNib:[InlinedPickerCell viewNib] forCellReuseIdentifier:[InlinedPickerCell cellIdentifier]];
    [self.tableView registerNib:[SettingsSegmentControlCell viewNib] forCellReuseIdentifier:[SettingsSegmentControlCell cellIdentifier]];
    [self.tableView registerNib:[SwitchControlCell viewNib] forCellReuseIdentifier:[SwitchControlCell cellIdentifier]];
    [self.tableView registerNib:[SettingsButtonCell viewNib] forCellReuseIdentifier:[SettingsButtonCell cellIdentifier]];


    self.emailCell = [self.tableView dequeueReusableCellWithIdentifier:[SettingsTopTitledTextEntryCell cellIdentifier]];
    [self.emailCell setTitle:NSLocalizedString(@"Default Email Recipient", nil)];
    [self.emailCell activateEmailMode];

    self.defaultTripLengthCell = [self.tableView dequeueReusableCellWithIdentifier:[SettingsTopTitledTextEntryCell cellIdentifier]];
    [self.defaultTripLengthCell setTitle:NSLocalizedString(@"Default Trip Length (Days)", nil)];
    [self.defaultTripLengthCell activateNumberEntryMode];

    self.minReportablePriceCell = [self.tableView dequeueReusableCellWithIdentifier:[SettingsTopTitledTextEntryCell cellIdentifier]];
    [self.minReportablePriceCell setTitle:NSLocalizedString(@"Min. Receipt Price to Report", nil)];
    [self.minReportablePriceCell activateDecimalEntryMode];

    self.userIdCell = [self.tableView dequeueReusableCellWithIdentifier:[SettingsTopTitledTextEntryCell cellIdentifier]];
    [self.userIdCell setTitle:NSLocalizedString(@"User ID", nil)];

    self.defaultCurrencyCell = [self.tableView dequeueReusableCellWithIdentifier:[PickerCell cellIdentifier]];
    [self.defaultCurrencyCell setTitle:NSLocalizedString(@"Default Currency", nil)];


    __weak SettingsViewController *weakSelf = self;

    self.defaultCurrencyPickerCell = [self.tableView dequeueReusableCellWithIdentifier:[InlinedPickerCell cellIdentifier]];
    [self.defaultCurrencyPickerCell setAllValues:[WBCurrency allCurrencyCodes]];
    [self.defaultCurrencyPickerCell setValueChangeHandler:^(id<Pickable> selected) {
        [weakSelf.defaultCurrencyCell setValue:selected.presentedValue];
    }];

    self.dateSeparatorCell = [self.tableView dequeueReusableCellWithIdentifier:[SettingsSegmentControlCell cellIdentifier]];
    [self.dateSeparatorCell setTitle:NSLocalizedString(@"Date Separator", nil)];

    self.costCenterCell = [self.tableView dequeueReusableCellWithIdentifier:[SwitchControlCell cellIdentifier]];
    [self.costCenterCell setTitle:NSLocalizedString(@"Track Const Center", nil)];

    self.cameraSettingsCell = [self.tableView dequeueReusableCellWithIdentifier:[SettingsSegmentControlCell cellIdentifier]];
    [self.cameraSettingsCell setTitle:NSLocalizedString(@"Max. Camera Height / Width", nil)];

    self.predictReceiptCategoriesCell = [self.tableView dequeueReusableCellWithIdentifier:[SwitchControlCell cellIdentifier]];
    [self.predictReceiptCategoriesCell setTitle:NSLocalizedString(@"Predict Receipt Categories", nil)];

    self.includeTaxFieldCell = [self.tableView dequeueReusableCellWithIdentifier:[SwitchControlCell cellIdentifier]];
    [self.includeTaxFieldCell setTitle:NSLocalizedString(@"Include Tax Field For Receipts", nil)];

    self.matchNameToCategoriesCell = [self.tableView dequeueReusableCellWithIdentifier:[SwitchControlCell cellIdentifier]];
    [self.matchNameToCategoriesCell setTitle:NSLocalizedString(@"Match Name to Categories", nil)];

    self.matchCommentsToCategoriesCell = [self.tableView dequeueReusableCellWithIdentifier:[SwitchControlCell cellIdentifier]];
    [self.matchCommentsToCategoriesCell setTitle:NSLocalizedString(@"Match Comments to Categories", nil)];

    self.onlyReportExpenseableCell = [self.tableView dequeueReusableCellWithIdentifier:[SwitchControlCell cellIdentifier]];
    [self.onlyReportExpenseableCell setTitle:NSLocalizedString(@"Only Report Expensable Receipts", nil)];

    self.enableAutocompleteSuggestionsCell = [self.tableView dequeueReusableCellWithIdentifier:[SwitchControlCell cellIdentifier]];
    [self.enableAutocompleteSuggestionsCell setTitle:NSLocalizedString(@"Enable AutoComplete Suggestions", nil)];

    self.defaultReceiptDateToReportStartCell = [self.tableView dequeueReusableCellWithIdentifier:[SwitchControlCell cellIdentifier]];
    [self.defaultReceiptDateToReportStartCell setTitle:NSLocalizedString(@"Default Receipt Date to Report Start Date", nil)];

    self.usePaymentMethodsCell = [self.tableView dequeueReusableCellWithIdentifier:[SwitchControlCell cellIdentifier]];
    [self.usePaymentMethodsCell setTitle:NSLocalizedString(@"Enable Payment Methods", nil)];

    self.customizePaymentMethodsCell = [self.tableView dequeueReusableCellWithIdentifier:[SettingsButtonCell cellIdentifier]];
    [self.customizePaymentMethodsCell setTitle:NSLocalizedString(@"Customize Payment Methods", nil)];

    InputCellsSection *general = [InputCellsSection sectionWithTitle:NSLocalizedString(@"General", nil)
                                                               cells:@[self.emailCell,
                                                                       self.defaultTripLengthCell,
                                                                       self.minReportablePriceCell,
                                                                       self.userIdCell,
                                                                       self.defaultCurrencyCell,
                                                                       self.dateSeparatorCell,
                                                                       self.cameraSettingsCell,
                                                                       self.costCenterCell,
                                                                       self.predictReceiptCategoriesCell,
                                                                       self.includeTaxFieldCell,
                                                                       self.matchNameToCategoriesCell,
                                                                       self.matchCommentsToCategoriesCell,
                                                                       self.onlyReportExpenseableCell,
                                                                       self.enableAutocompleteSuggestionsCell,
                                                                       self.defaultReceiptDateToReportStartCell,
                                                                       self.usePaymentMethodsCell,
                                                                       self.customizePaymentMethodsCell]];
    [self addSectionForPresentation:general];

    [self addInlinedPickerCell:self.defaultCurrencyPickerCell forCell:self.defaultCurrencyCell];

    self.manageCategoriesCell = [self.tableView dequeueReusableCellWithIdentifier:[SettingsButtonCell cellIdentifier]];
    [self.manageCategoriesCell setTitle:NSLocalizedString(@"Manage Categories", nil)];

    [self addSectionForPresentation:[InputCellsSection sectionWithTitle:NSLocalizedString(@"Categories", nil) cells:@[self.manageCategoriesCell]]];

    self.includeCSVHeadersCell = [self.tableView dequeueReusableCellWithIdentifier:[SwitchControlCell cellIdentifier]];
    [self.includeCSVHeadersCell setTitle:NSLocalizedString(@"Include Header Columns", nil)];

    self.configureCSVColumnsCell = [self.tableView dequeueReusableCellWithIdentifier:[SettingsButtonCell cellIdentifier]];
    [self.configureCSVColumnsCell setTitle:NSLocalizedString(@"Configure CSV Columns", nil)];

    [self addSectionForPresentation:[InputCellsSection sectionWithTitle:NSLocalizedString(@"Customize CSV Output", nil) cells:@[self.includeCSVHeadersCell, self.configureCSVColumnsCell]]];

    self.configurePDFColumnsCell = [self.tableView dequeueReusableCellWithIdentifier:[SettingsButtonCell cellIdentifier]];
    [self.configurePDFColumnsCell setTitle:NSLocalizedString(@"Configure PDF Columns", nil)];

    [self addSectionForPresentation:[InputCellsSection sectionWithTitle:NSLocalizedString(@"Customize PDF Output", nil) cells:@[self.configurePDFColumnsCell]]];

    self.addDistancePriceToReportCell = [self.tableView dequeueReusableCellWithIdentifier:[SwitchControlCell cellIdentifier]];
    [self.addDistancePriceToReportCell setTitle:NSLocalizedString(@"Add Distane Price to Report", nil)];


    self.gasRateCell = [self.tableView dequeueReusableCellWithIdentifier:[SettingsTopTitledTextEntryCell cellIdentifier]];
    [self.gasRateCell setTitle:NSLocalizedString(@"Gas Rate", nil)];
    [self.gasRateCell activateDecimalEntryMode];

    self.includeDistanceTableCell = [self.tableView dequeueReusableCellWithIdentifier:[SwitchControlCell cellIdentifier]];
    [self.includeDistanceTableCell setTitle:NSLocalizedString(@"Include Distance Table", nil)];

    self.reportOnDailyDistanceCell = [self.tableView dequeueReusableCellWithIdentifier:[SwitchControlCell cellIdentifier]];
    [self.reportOnDailyDistanceCell setTitle:NSLocalizedString(@"Report on Daily Distance", nil)];

    [self addSectionForPresentation:[InputCellsSection sectionWithTitle:NSLocalizedString(@"Distance", nil)
                                                                  cells:@[self.addDistancePriceToReportCell,
                                                                          self.gasRateCell,
                                                                          self.includeDistanceTableCell,
                                                                          self.reportOnDailyDistanceCell]]];


    self.backupCell = [self.tableView dequeueReusableCellWithIdentifier:[SettingsButtonCell cellIdentifier]];
    [self.backupCell setTitle:NSLocalizedString(@"Make Backup", nil)];

    [self addSectionForPresentation:[InputCellsSection sectionWithTitle:NSLocalizedString(@"Backup", nil) cells:@[self.backupCell]]];

    [self.navigationController setToolbarHidden:YES];
}

- (void)populateValues {
    [self.emailCell setValue:[WBPreferences defaultEmailReceipient]];
    [self.defaultTripLengthCell setValue:[NSString stringWithFormat:@"%d",[WBPreferences defaultTripDuration]]];

    double price = [WBPreferences minimumReceiptPriceToIncludeInReports];
    double minPrice = ([WBPreferences MIN_FLOAT]/4.0); // we have to make significant change because it's long float and have little precision
    if (price < minPrice) {
        [self.minReportablePriceCell setValue:@""];
    } else {
        long long priceLong = roundl(price);
        [self.minReportablePriceCell setValue:[NSString stringWithFormat:@"%lld", priceLong]];
    }

    [self.userIdCell setValue:[WBPreferences userID]];
    [self.defaultCurrencyCell setValue:[WBPreferences defaultCurrency]];
    [self.defaultCurrencyPickerCell setSelectedValue:[StringPickableWrapper wrapValue:[WBPreferences defaultCurrency]]];
    [self.predictReceiptCategoriesCell setSwitchOn:[WBPreferences predictCategories]];
    [self.includeTaxFieldCell setSwitchOn:[WBPreferences includeTaxField]];
    [self.matchNameToCategoriesCell setSwitchOn:[WBPreferences matchNameToCategory]];
    [self.matchCommentsToCategoriesCell setSwitchOn:[WBPreferences matchCommentToCategory]];
    [self.onlyReportExpenseableCell setSwitchOn:[WBPreferences onlyIncludeExpensableReceiptsInReports]];
    [self.enableAutocompleteSuggestionsCell setSwitchOn:[WBPreferences enableAutoCompleteSuggestions]];
    [self.defaultReceiptDateToReportStartCell setSwitchOn:[WBPreferences defaultToFirstReportDate]];
    [self.usePaymentMethodsCell setSwitchOn:[WBPreferences usePaymentMethods]];

    NSArray *separators = @[@"-", @"/", @"."];
    NSString *systemSeparator = [[[WBDateFormatter alloc] init] separatorForCurrentLocale];
    if ([separators indexOfObject:systemSeparator] == NSNotFound) {
        separators = [separators arrayByAddingObject:systemSeparator];
    }

    NSUInteger idx = [separators indexOfObject:[WBPreferences dateSeparator]];
    if (idx == NSNotFound) {
        idx = 1;
    }
    [self.dateSeparatorCell setValues:separators selected:idx];

    [self.costCenterCell setSwitchOn:[WBPreferences trackCostCenter]];

    self.cameraValues = @[@512, @1024, @0];

    NSMutableArray *presentedCameraValues = [NSMutableArray array];
    NSUInteger selectedCameraValueIndex = 1;
    for (NSUInteger index = 0; index < self.cameraValues.count; index++) {
        int val = [((NSNumber*) self.cameraValues[index]) intValue];
        if (val == 0) {
            [presentedCameraValues addObject:NSLocalizedString(@"Default", nil)];
        } else {
            [presentedCameraValues addObject:[NSString stringWithFormat:@"%d %@", val, NSLocalizedString(@"Pixels", nil)]];
        }

        if (val == [WBPreferences cameraMaxHeightWidth]) {
            selectedCameraValueIndex = index;
        }
    }
    [self.cameraSettingsCell setValues:presentedCameraValues selected:selectedCameraValueIndex];

    [self.includeCSVHeadersCell setSwitchOn:[WBPreferences includeCSVHeaders]];

    [self.addDistancePriceToReportCell setSwitchOn:[WBPreferences isTheDistancePriceBeIncludedInReports]];
    float defaultValue = [WBPreferences distanceRateDefaultValue];
    if (defaultValue < 0.001) {
        [self.gasRateCell setValue:@""];
    } else {
        NSDecimalNumber *mileageRate = (NSDecimalNumber *) [[NSDecimalNumber alloc] initWithFloat:defaultValue];
        [self.gasRateCell setValue:[mileageRate descriptionWithLocale:[NSLocale currentLocale]]];
    }
    [self.includeDistanceTableCell setSwitchOn:[WBPreferences printDistanceTable]];
    [self.reportOnDailyDistanceCell setSwitchOn:[WBPreferences printDailyDistanceValues]];
}

- (void)writeSettingsToPreferences {
    NSString *daysStr = self.defaultTripLengthCell.value;
    if ([daysStr length] > 0 && [daysStr length] < 4) {
        [WBPreferences setDefaultTripDuration:[daysStr intValue]];
    }
    
    NSString *priceStr = [self.minReportablePriceCell value];
    if ([priceStr length] > 0 && [priceStr length] < 4) {
        [WBPreferences setMinimumReceiptPriceToIncludeInReports:[priceStr floatValue]];
    } else if ([priceStr length] == 0) {
        [WBPreferences setMinimumReceiptPriceToIncludeInReports:[WBPreferences MIN_FLOAT]];
    }

    [WBPreferences setDefaultEmailReceipient:self.emailCell.value];
    [WBPreferences setUserID:self.userIdCell.value];
    [WBPreferences setDefaultCurrency:[self.defaultCurrencyCell value]];
    [WBPreferences setDateSeparator:[self.dateSeparatorCell selectedValue]];
    [WBPreferences setTrackCostCenter:[self.costCenterCell isSwitchOn]];

    NSNumber *cam = self.cameraValues[(NSUInteger) [self.cameraSettingsCell selectedSegmentIndex]];
    [WBPreferences setCameraMaxHeightWidth:[cam intValue]];

    [WBPreferences setPredictCategories:[self.predictReceiptCategoriesCell isSwitchOn]];
    [WBPreferences setIncludeTaxField:self.includeTaxFieldCell.isSwitchOn];
    [WBPreferences setMatchNameToCategory:self.matchNameToCategoriesCell.isSwitchOn];
    [WBPreferences setMatchCommentToCategory:self.matchCommentsToCategoriesCell.isSwitchOn];
    [WBPreferences setOnlyIncludeExpensableReceiptsInReports:self.onlyReportExpenseableCell.isSwitchOn];
    [WBPreferences setEnableAutoCompleteSuggestions:self.enableAutocompleteSuggestionsCell.isSwitchOn];
    [WBPreferences setDefaultToFirstReportDate:self.defaultReceiptDateToReportStartCell.isSwitchOn];
    [WBPreferences setUsePaymentMethods:self.usePaymentMethodsCell.isSwitchOn];

    [WBPreferences setIncludeCSVHeaders:self.includeCSVHeadersCell.isSwitchOn];

    [WBPreferences setTheDistancePriceBeIncludedInReports:self.addDistancePriceToReportCell.isSwitchOn];
    NSString *gasRate = [self.gasRateCell value];
    NSDecimalNumber *rate = [NSDecimalNumber decimalNumberOrZero:gasRate];
    [WBPreferences setDistanceRateDefaultValue:[rate floatValue]];
    [WBPreferences setPrintDistanceTable:[self.includeDistanceTableCell isSwitchOn]];
    [WBPreferences setPrintDailyDistanceValues:[self.reportOnDailyDistanceCell isSwitchOn]];

    [WBPreferences save];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self populateValues];
    visibleInstance = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    visibleInstance = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] hasPrefix:@"Configure"]) {
        WBColumnsViewController *vc = (WBColumnsViewController *) [segue destinationViewController];
        vc.forCSV = [[segue identifier] isEqualToString:@"ConfigureCSV"];
    }
}

- (void)showMailerForData:(NSData *)data {
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;

    // forward our navbar tint color to mail composer
    [mc.navigationBar setTintColor:[UINavigationBar appearance].tintColor];

    [mc setToRecipients:@[[WBPreferences defaultEmailReceipient]]];
    [mc addAttachmentData:data
                 mimeType:@"application/octet-stream"
                 fileName:@"SmartReceipts.smr"];

    // forward style, mail composer is so dumb and overrides our style
    UIStatusBarStyle barStyle = [UIApplication sharedApplication].statusBarStyle;

    [self presentViewController:mc animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:barStyle];
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    if (error) {
        NSLog(@"Mail error: %@", [error localizedDescription]);
    }

    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionExport {
    void (^exportActionBlock)() = ^{
        [HUD showUIBlockingIndicatorWithText:NSLocalizedString(@"Exporting ...", nil)];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *data = nil;
            @try {
                NSString *path = [[[WBBackupHelper alloc] init] exportAll];
                if (path) {
                    data = [NSData dataWithContentsOfFile:path];
                }
            } @catch (NSException *e) {
                data = nil;
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hideUIBlockingIndicator];

                if (data) {
                    [self showMailerForData:data];
                } else {
                    [[[UIAlertView alloc]
                            initWithTitle:NSLocalizedString(@"Error", nil)
                                  message:NSLocalizedString(@"Failed to properly export your data.", nil)
                                 delegate:nil
                        cancelButtonTitle:NSLocalizedString(@"OK", nil)
                        otherButtonTitles:nil] show];
                }

            });
        });
    };

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Export your receipts?", nil)
                                                        message:NSLocalizedString(@"You can reimport your data by clicking on the SmartReceipts.SMR file, which is generated by clicking below.", nil)
                                               cancelButtonItem:[RIButtonItem itemWithLabel:NSLocalizedString(@"Cancel", nil)]
                                               otherButtonItems:[RIButtonItem itemWithLabel:NSLocalizedString(@"Export", nil) action:exportActionBlock], nil];

    [alertView show];
}

- (IBAction)actionDone:(id)sender {
    [self writeSettingsToPreferences];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tappedCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (cell == self.manageCategoriesCell) {
        [self performSegueWithIdentifier:PushManageCategoriesSegueIdentifier sender:nil];
    } else if (cell == self.configureCSVColumnsCell) {
        [self performSegueWithIdentifier:PushConfigureCSVColumnsSegueIdentifier sender:nil];
    } else if (cell == self.configurePDFColumnsCell) {
        [self performSegueWithIdentifier:PushConfigurePDFColumnsSegueIdentifier sender:nil];
    } else if (cell == self.backupCell) {
        [self actionExport];
    } else if (cell == self.customizePaymentMethodsCell) {
        [self performSegueWithIdentifier:PushPaymentMethodsControllerSegueIdentifier sender:nil];
    }
}

@end