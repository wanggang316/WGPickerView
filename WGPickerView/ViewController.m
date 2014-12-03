//
//  ViewController.m
//  WGPickerView
//
//  Created by 王刚 on 14/12/2.
//  Copyright (c) 2014年 www. All rights reserved.
//

#import "ViewController.h"

#define kTitleKey @"title"
#define kDetailKey @"detail"

#define kPositionRow 1
#define kCountRow 2

#define kPickerTag  99


static NSString *kShowCellID = @"showCell";
static NSString *kPickerID = @"viewPicker";
static NSString *kOtherCellID = @"otherCell";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>


@property (nonatomic, strong) NSArray *dateArray;
@property (weak, nonatomic) IBOutlet UIPickerView *positionPickerView;

@property (nonatomic, strong) NSIndexPath *pickerIndexPath;

@property (assign) NSInteger pickerCellRowHeight;


@property (nonatomic, strong) NSArray *pickerDataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableDictionary *itemOne = [@{kTitleKey: @"请填写信息："} mutableCopy];
    NSMutableDictionary *itemTwo = [@{kTitleKey: @"职务", kDetailKey: @"请选择"} mutableCopy];
    NSMutableDictionary *itemThree = [@{kTitleKey: @"日期", kDetailKey: @"请选择"} mutableCopy];
    NSMutableDictionary *itemFour = [@{kTitleKey: @"其它"} mutableCopy];
    self.dateArray = @[itemOne, itemTwo, itemThree, itemFour];
    
    
    UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kPickerID];
    self.pickerCellRowHeight = CGRectGetHeight(pickerViewCellToCheck.frame);
    
    //pickerView
    self.positionPickerView.dataSource = self;
    self.positionPickerView.delegate = self;
    self.pickerDataArray = @[@"ios工程师", @"python工程师", @"Go工程师", @"前端工程师"];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)hasInlineDatePicker {
    return (self.pickerIndexPath != nil);
}

- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath {
    return [self hasInlineDatePicker] && self.pickerIndexPath.row == indexPath.row;
}

- (BOOL)indexPathData:(NSIndexPath *)indexPath {
    BOOL hasData = NO;
    if (indexPath.row == kPositionRow || indexPath.row == kCountRow || ([self hasInlineDatePicker] && indexPath.row == kCountRow + 1) ) {
        hasData = YES;
    }
    return hasData;
}

- (BOOL)hasPickerAtIndexPath:(NSIndexPath *)indexPath {
    BOOL hasPicker = NO;
    NSInteger targetRow = indexPath.row;
    targetRow ++;
    UITableViewCell *checkPickerCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetRow inSection:0]];
    UIPickerView *checkPickerView = (UIPickerView *)[checkPickerCell viewWithTag:kPickerTag];
    
    
    hasPicker = (checkPickerView != nil);
    return hasPicker;
}

- (void)updatePicker
{
    if (self.pickerIndexPath != nil)
    {
        UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.pickerIndexPath];
        
        UIPickerView *targetedDatePicker = (UIPickerView *)[associatedDatePickerCell viewWithTag:kPickerTag];
        if (targetedDatePicker != nil)
        {
            // we found a UIDatePicker in this cell, so update it's date value
            //
            NSDictionary *itemData = self.dateArray[self.pickerIndexPath.row - 1];
//            [targetedDatePicker setDate:[itemData valueForKey:kDetailKey] animated:NO];
        }
    }
}



#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self indexPathHasPicker:indexPath] ? 100 : self.tableView.rowHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self hasInlineDatePicker]) {
        NSInteger numRows = self.dateArray.count;
        return ++numRows;
    }
    
    return self.dateArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    NSString *cellID = kOtherCellID;
    
    if ([self indexPathHasPicker:indexPath]) {
        cellID = kPickerID;
    } else if ([self indexPathData:indexPath]) {
        cellID = kShowCellID;
    }
    
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    NSInteger modelRow = indexPath.row;
    if (self.pickerIndexPath != nil && self.pickerIndexPath.row < indexPath.row) {
        modelRow--;
    }
    
    
    NSDictionary *itemData = self.dateArray[modelRow];
    
    if ([cellID isEqualToString:kShowCellID]) {
        cell.textLabel.text = itemData[kTitleKey];
        cell.detailTextLabel.text = itemData[kDetailKey];
    } else if ([cellID isEqualToString:kOtherCellID]){
        cell.textLabel.text = itemData[kTitleKey];
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"------> indexpath.row = %d",indexPath.row);
    
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"cell.reuseIdentifier :%@", cell.reuseIdentifier);
    if (cell.reuseIdentifier == kShowCellID) {
        [self displayInlinePickerForRowAtIndexPath:indexPath];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


- (void)displayInlinePickerForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView beginUpdates];
    
    BOOL before = NO;
    if ([self hasInlineDatePicker]) {
        before = self.pickerIndexPath.row < indexPath.row;
    }
    
    BOOL sameCellClicked = self.pickerIndexPath.row - 1 == indexPath.row;
    
    if ([self hasInlineDatePicker]) {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.pickerIndexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        self.pickerIndexPath = nil;
    }
    
    if (!sameCellClicked) {
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];
        [self togglePickerForSelectedIndexPath:indexPathToReveal];
        
        self.pickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
    }
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
    [self updatePicker];
}


- (void)togglePickerForSelectedIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
    
    if ([self hasPickerAtIndexPath:indexPath]) {
        
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
    
}


#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.pickerDataArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.pickerDataArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"select row is %d", row);
    NSString *selectedData = self.pickerDataArray[row];
    NSLog(@"sleect row data is %@", selectedData);
    
    NSIndexPath *targetedCellIndexPath = nil;
    
    if ([self hasInlineDatePicker])
    {
        targetedCellIndexPath = [NSIndexPath indexPathForRow:self.pickerIndexPath.row - 1 inSection:0];
    }
    else
    {
        targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    
    NSMutableDictionary *itemData = self.dateArray[targetedCellIndexPath.row];
    [itemData setValue:self.pickerDataArray[row] forKey:kDetailKey];
    
    cell.detailTextLabel.text = self.pickerDataArray[row];
}


@end
