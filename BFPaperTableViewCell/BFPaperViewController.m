//
//  BFPaperViewController.m
//  BFPaperTableViewCell
//
//  Created by Bence Feher on 7/17/14.
//  Copyright (c) 2014 Bence Feher. All rights reserved.
//
// The MIT License (MIT)
//
// Copyright (c) 2014 Bence Feher
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


#import "BFPaperViewController.h"
#import "UIColor+BFPaperColors.h"
#import "BFPaperTableViewCell.h"

@interface BFPaperViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property NSArray *colors;
@end

@implementation BFPaperViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Register BFPaperTableViewCell for our tableView:
    [self.tableView registerClass:[BFPaperTableViewCell class] forCellReuseIdentifier:@"BFPaperCell"];  // NOTE: This is not required if we declared a prototype cell in our storyboard (which this example project does). This is here purely for information purposes.
    
    
    // Fill up an array with all the basic BFPaperColors:
    self.colors = @[[UIColor paperColorBlue], [UIColor paperColorBlue], [UIColor paperColorRed], [UIColor paperColorPink], [UIColor paperColorPurple], [UIColor paperColorDeepPurple], [UIColor paperColorIndigo], [UIColor paperColorBlue], [UIColor paperColorLightBlue], [UIColor paperColorCyan], [UIColor paperColorTeal], [UIColor paperColorGreen], [UIColor paperColorLightGreen], [UIColor paperColorLime], [UIColor paperColorYellow], [UIColor paperColorAmber], [UIColor  paperColorDeepOrange], [UIColor paperColorBrown], [UIColor paperColorGray], [UIColor paperColorBlueGray], [UIColor paperColorGray700], [UIColor paperColorGray700]];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundColor = [UIColor colorWithRed:0.7 green:0.98 blue:0.7 alpha:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.colors.count * 2; // We will have one set of cells with a white background and colored text, and one set with a colored background and white text.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BFPaperTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BFPaperCell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[BFPaperTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BFPaperCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    // Configure the cell...
    
    // Even indexed cells will ripple from the center while odd ones will ripple from tap location:
    if (indexPath.row % 2 == 0) {
        cell.rippleFromTapLocation = NO;
        cell.textLabel.text = @"Ripple from Center";
    }
    else {
        cell.rippleFromTapLocation = YES;
        cell.textLabel.text = @"BFPaperTableViewCell";
    }

    // Demo 2 clear cells:
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [self.colors objectAtIndex:indexPath.row];
        cell.usesSmartColor = YES;
        cell.textLabel.text = @"Clear, Smart Color";
        cell.tapCircleDiameter = bfPaperTableViewCell_tapCircleDiameterDefault;
    }
    else if (indexPath.row == 1) {
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [self.colors objectAtIndex:indexPath.row];
        cell.usesSmartColor = NO;
        cell.textLabel.text = @"Clear, !Smart Color";
        cell.tapCircleDiameter = bfPaperTableViewCell_tapCircleDiameterDefault;
    }
    // The rest of the first half should be white with colored text:
    else if (indexPath.row < self.colors.count){
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [self.colors objectAtIndex:indexPath.row];
        cell.usesSmartColor = YES;
        cell.tapCircleDiameter = bfPaperTableViewCell_tapCircleDiameterDefault;
    }
    // Customize two cells between white bg cells and color bg cells
    else if (indexPath.row <= self.colors.count + 1) {
        cell.textLabel.text = @"Customized!";
        cell.backgroundColor = [UIColor paperColorDeepPurple];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.tapCircleDiameter = bfPaperTableViewCell_tapCircleDiameterSmall;
        cell.tapCircleColor = [[UIColor paperColorPink] colorWithAlphaComponent:0.7];
        cell.backgroundFadeColor = [UIColor paperColorRedA100];
    }
    // After that, just color their background and give them white text:
    else {
        cell.backgroundColor = [self.colors objectAtIndex:indexPath.row % self.colors.count];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.usesSmartColor = YES;
        cell.tapCircleDiameter = bfPaperTableViewCell_tapCircleDiameterDefault;
    }
    
    cell.textLabel.backgroundColor = [UIColor clearColor];  // THIS IS SUPER IMPORTANT!! SET THIS LAST RIGHT BEFORE RETURNING.

    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

@end
