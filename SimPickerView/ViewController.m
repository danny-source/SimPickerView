//
//  ViewController.m
//  SimPickerView
//
//  Created by CHING PING on 2014/12/31.
//  Copyright (c) 2014年 CHING PING. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) NSMutableArray *items;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.items = [NSMutableArray arrayWithObjects:@"項目 0", @"項目 1", @"项目 2", @"一つ書き 3", @"item 4", @"item 5", @"item 6", @"item 7", @"item 8", @"item 9", @"item 10", @"item 11", @"item 12" , @"item 13", @"item 14", @"item 15", @"item 16", nil];

    self.simPickerView.delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.simPickerView markFirstDisclosure];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDelete:(id)sender
{
    NSIndexPath *sel = [self.simPickerView getFocusIndexPath];
    [self.simPickerView deleteRow: sel.item];
}

static NSInteger count = 0;

- (IBAction)onAdd:(id)sender
{
    NSIndexPath *sel = [self.simPickerView getFocusIndexPath];

    NSString *newItem = [NSString stringWithFormat: @"Ipsum Lorem %ld", (long)count];
    [self.simPickerView insertItem: newItem atRow: sel.item];
    count++;
    [self.simPickerView reloadDataWithCompleteion:^{
        [self.simPickerView didSelectItemAtRow:2];
    }];
}

- (IBAction)onAppend:(id)sender {
    NSIndexPath *sel = [self.simPickerView getFocusIndexPath];
    static NSInteger count = 0;
    NSString *newItem = [NSString stringWithFormat: @"Ipsum Lorem %ld", (long)count];
    [self.simPickerView insertItem: newItem afterRow: sel.item];
    count++;
}

- (IBAction)onReloadAndSelectItem0:(id)sender {
    [self.simPickerView reloadDataWithCompleteion:^{
        [self.simPickerView didSelectItemAtRow:3];
    }];
//    [self.simPickerView didSelectItemAtRow:3];
}

#pragma mark - delegate
- (BOOL)shouldShowDeleteButtonOnIndex:(NSInteger)index
{
    NSString *msg;
    BOOL result = YES;

    if (index < 4) {
        msg = @"The first 4 elements can NOT be deleted";
        result = NO;
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:@"SimPicker Demo"
                                              message:msg
                                              preferredStyle:UIAlertControllerStyleAlert];


        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"OK action");
                                   }];

        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        result = YES;
    }


    return result;
}

- (NSInteger)numberOfRowsInPickerView:(SimPickerView *)pickerView
{
    return self.items.count;
}

- (NSString *)pickerView:(SimPickerView *)pickerView titleForRow:(NSInteger)row
{
    return self.items[row];
}

-(void)pickerView:(SimPickerView *)pickerView didSelectRow:(NSInteger)row
{
    NSLog(@"did select row %ld", (long)row);
}

- (BOOL)callbackInsertItem:(id)item atRow:(NSInteger)row
{
    [self.items insertObject:item atIndex:row];
    return true;
}

- (BOOL)callbackDeleteRow:(NSInteger)deleteRow
{
    [self.items removeObjectAtIndex: deleteRow];
    return true;
}

- (void)buttonDisclosurePressed:(UIButton *)btn onIndex:(NSInteger)index
{
    NSLog(@"disclosure btn pressed on Index %ld", (long)index);
}

- (void)buttonDeletePressed:(UIButton *)btn onIndex:(NSInteger)index
{
    NSLog(@"delete btn pressed on Index %ld", (long)index);
}

- (void)longTouchPressedOnIndex:(NSInteger)index
{
    NSLog(@"longTouchPressedOnIndex:%ld",(long)index);
}
- (IBAction)onNextItem:(id)sender
{
    NSInteger row = [[self.simPickerView getFocusIndexPath] item];
    row = row + 1;
    if (row < self.items.count) {
        [self.simPickerView didSelectItemAtRow: row];
    }
}

- (IBAction)onPreviousItem:(id)sender
{
    NSInteger row = [[self.simPickerView getFocusIndexPath] item];
    row = row - 1;
    if (row >= 0) {
        [self.simPickerView didSelectItemAtRow: row];
    }

}

@end
