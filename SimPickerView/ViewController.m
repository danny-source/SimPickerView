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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDelete:(id)sender
{
    NSIndexPath *sel = [self.simPickerView getFocusIndexPath];
    [self.items removeObjectAtIndex: sel.item];
    [self.simPickerView reloadData];
}


- (IBAction)onAdd:(id)sender
{
    NSIndexPath *sel = [self.simPickerView getFocusIndexPath];
    [self.items insertObject:@"Ipsum Loram" atIndex:sel.item];
    [self.simPickerView reloadData];
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
@end
