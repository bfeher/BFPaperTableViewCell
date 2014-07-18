BFPaperTableViewCell
====================

> A subclass of UITableViewCell inspired by Google's Material Design: Paper Elements.

![Animated Screenshot](link.gif "Animated Screenshot")


About
---------
_BFPaperTableViewCell_ is a subclass of UITableViewCell that behaves much like the new paper table cells from Google's Material Design Labs.
All animation are asynchronous and are performed on sublayers.
_BFPaperTableViewCell_s work right away with pleasing default behaviors, however they can be easily customized! The tap-circle color, background fade color, and tap-circle diameter are all readily customizable via public properties.

By default, _BFPaperTableViewCell_s use "Smart Color" which will match the tap-circle and background fade colors to the color of the `textLabel`.
You can turn off Smart Color by setting the property, `.usesSmartColor` to `NO`. If you disable Smart Color, a gray color will be used by default for both the tap-circle and the background color fade.
You can set your own colors via: `.tapCircleColor` and `.backgroundFadeColor`. Note that setting these disables Smart Color.

## Properties
`BOOL usesSmartColor;` 
A flag to set YES to use Smart Color, or NO to use a custom color scheme. While Smart Color is the default (usesSmartColor = YES), customization is cool too.

`UIColor *tapCircleColor;` 
The UIColor to use for the circle which appears where you tap. NOTE: Setting this defeats the "Smart Color" ability of the tap circle. Alpha values less than 1 are recommended.

`UIColor *backgroundFadeColor;` 
The UIColor to fade the background to. NOTE: Setting this defeats the "Smart Color" ability of the background fade. An alpha value of 1 is recommended, as the fade is a constant (`bfPaperCell_fadeConstant`) defined in the BFPaperTableViewCell.m. This bothers me too.

`CGFloat tapCircleDiameter;` 
The CGFloat value representing the Diameter of the tap-circle. By default it will be calculated to almost be big enough to cover up the whole background. Any value less than zero will result in default being used. Three pleasing sizes, `bfPaperTableViewCell_tapCircleDiameterSmall`, `bfPaperTableViewCell_tapCircleDiameterMedium`, and `bfPaperTableViewCell_tapCircleDiameterLarge` are also available for use.

`BOOL rippleFromTapLocation;`
A flag to set to YES to have the tap-circle ripple from point of touch. If this is set to NO, the tap-circle will always ripple from the center of the button. Default is YES.


Usage
---------
Add the _BFPaperTableViewCell_ header and implementation file to your project. (.h & .m)

After that, you can use it just like any other `UITableViewCell`. 

If you use storyboards with prototype cells, be sure to change the prototype cell's class to _BFPaperTableViewCell_!

### Storyboard Example
```objective-c
// Register BFPaperTableViewCell for our tableView in viewDidLoad:
- (void)viewDidLoad
{
...
[self.tableView registerClass:[BFPaperTableViewCell class] forCellReuseIdentifier:@"BFPaperCell"];  // NOTE: This is not required if we declared a prototype cell in our storyboard (which this example project does). This is here purely for information purposes.
...
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
BFPaperTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BFPaperCell" forIndexPath:indexPath];
if (!cell) {
cell = [[BFPaperTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BFPaperCell"];
}
cell.rippleFromTapLocation = NO; // Will always ripple from center if NO.
cell.tapCircleColor = [[UIColor paperColorDeepPurple] colorWithAlphaComponent:0.3];
cell.backgroundFadeColor = [UIColor paperColorBlue];
cell.tapCircleDiameter = bfPaperTableViewCell_tapCircleDiameterSmall;
return cell;
}
```


Cocoapods
-------

CocoaPods are the best way to manage library dependencies in Objective-C projects.
Learn more at http://cocoapods.org

Add this to your podfile to add _BFPaperTableViewCell_ to your project.
```ruby
platform :ios, '7.0'
pod "BFPaperTableViewCell", "~> 1.0"
```


License
--------
_BFPaperTableViewCell_ uses the MIT License:

> Please see included [LICENSE file](link/LICENSE.md).
