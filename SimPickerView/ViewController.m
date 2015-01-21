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
    self.items = [NSMutableArray arrayWithObjects:@"item 0", @"item 1", @"item 2", @"item 3", @"item 4", @"item 5", @"item 6", @"item 7", @"item 8", @"item 9", @"item 10", @"item 11", @"item 12" , @"item 13", @"item 14", @"item 15", @"item 16", nil];
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

    NSString *newItem = [NSString stringWithFormat: @"Ipsum Lorem %ld", count];
    [self.simPickerView insertItem: newItem atRow: sel.item];
    count++;
}

- (IBAction)onAppend:(id)sender {
    NSIndexPath *sel = [self.simPickerView getFocusIndexPath];
    static NSInteger count = 0;
    NSString *newItem = [NSString stringWithFormat: @"Ipsum Lorem %ld", count];
    [self.simPickerView insertItem: newItem afterRow: sel.item];
    count++;
}

#pragma mark - delegate
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
    NSLog(@"did select row %ld", row);
}

- (void)callbackInsertItem:(id)item atRow:(NSInteger)row
{
    [self.items insertObject:item atIndex:row];
}

- (void)callbackDeleteRow:(NSInteger)deleteRow
{
    [self.items removeObjectAtIndex: deleteRow];
}

- (void)buttonDisclosurePressed:(UIButton *)btn onIndex:(NSInteger)index
{
    NSLog(@"disclosure btn pressed on Index %ld", index);
}

- (void)buttonDeletePressed:(UIButton *)btn onIndex:(NSInteger)index
{
    NSLog(@"delete btn pressed on Index %ld", index);
}
@end
