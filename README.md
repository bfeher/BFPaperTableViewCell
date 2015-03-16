BFPaperTableViewCell
====================
[![CocoaPods](https://img.shields.io/cocoapods/v/BFPaperTableViewCell.svg?style=flat)](https://github.com/bfeher/BFPaperTableViewCell)

> A subclass of UITableViewCell inspired by Google's Material Design: Paper Elements.

![Animated Screenshot](https://raw.githubusercontent.com/bfeher/BFPaperTableViewCell/master/BFPaperTableViewCellDemoGif.gif "Animated Screenshot")

Changes
--------
> Please see included [CHANGELOG file](https://github.com/bfeher/BFPaperTableViewCell/blob/master/CHANGELOG.md).


About
---------
### Now with smoother animations and more public properties for even easier customization!

_BFPaperTableViewCell_ is a subclass of UITableViewCell that behaves much like the new paper table cells from Google's Material Design Labs.
All animation are asynchronous and are performed on sublayers.
_BFPaperTableViewCells_ work right away with pleasing default behaviors, however they can be easily customized! The tap-circle color, background fade color, background fade alpha, background highlight (linger or fade away), tap-circle ripple locaiton, and tap-circle diameter are all readily customizable via public properties.

By default, _BFPaperTableViewCells_ use "Smart Color" which will match the tap-circle and background fade colors to the color of the `textLabel`.
You can turn off Smart Color by setting the property, `.usesSmartColor` to `NO`. If you disable Smart Color, a gray color will be used by default for both the tap-circle and the background color fade.
You can set your own colors via: `.tapCircleColor` and `.backgroundFadeColor`. Note that setting these disables Smart Color.

## Properties
`BOOL usesSmartColor` <br />
A flag to set YES to use Smart Color, or NO to use a custom color scheme. While Smart Color is the default (usesSmartColor = YES), customization is cool too.

`CGFloat touchDownAnimationDuration` <br />
A CGFLoat representing the duration of the animations which take place on touch DOWN! Default is `0.25f` seconds. (Go Steelers)

`CGFloat touchUpAnimationDuration` <br />
A CGFLoat representing the duration of the animations which take place on touch UP! Default is `2 * touchDownAnimationDuration` seconds.

`CGFloat tapCircleDiameterStartValue` <br />
A CGFLoat representing the diameter of the tap-circle as soon as it spawns, before it grows. Default is `5.f`.

`CGFloat tapCircleDiameter` <br />
The CGFloat value representing the Diameter of the tap-circle. By default it will be the result of `MAX(self.frame.width, self.frame.height)`. `tapCircleDiameterFull` will calculate a circle that always fills the entire view. Any value less than or equal to `tapCircleDiameterFull` will result in default being used. The constants: `tapCircleDiameterLarge`, `tapCircleDiameterMedium`, and `tapCircleDiameterSmall` are also available for use. */

`CGFloat tapCircleBurstAmount` <br />
The CGFloat value representing how much we should increase the diameter of the tap-circle by when we burst it. Default is `100.f`.

`UIColor *tapCircleColor` <br />
The UIColor to use for the circle which appears where you tap. NOTE: Setting this defeats the "Smart Color" ability of the tap circle. Alpha values less than `1` are recommended.

`UIColor *backgroundFadeColor` <br />
The UIColor to fade clear backgrounds to. NOTE: Setting this defeats the "Smart Color" ability of the background fade. Alpha values less than `1` are recommended.

`BOOL rippleFromTapLocation` <br />
A flag to set to `YES` to have the tap-circle ripple from point of touch. If this is set to `NO`, the tap-circle will always ripple from the center of the view. Default is `YES`.

`BOOL letBackgroundLinger`<br />
A BOOL flag that determines whether or not to keep the background around after a tap, essentially "highlighting/selecting" the cell. Note that this does not trigger `setSelected:`! It is purely aesthetic. Also this kinda clashes with `cell.selectionStyle`, so by defualt the constructor sets that to `UITableViewCellSelectionStyleNone`. Default is YES.

`BOOL alwaysCompleteFullAnimation` <br />
A BOOL flag indicating whether or not to always complete a full animation cycle (bg fade in, tap-circle grow and burst, bg fade out) before starting another one. NO will behave just like the other BFPaper controls, tapping rapidly spawns many circles which all fade out in turn. Default is `YES`.

`CGFloat tapDelay` <br />
A CGFLoat to set the amount of time in seconds to delay the tap event / trigger to spawn circles. For example, if the tapDelay is set to `1.f`, you need to press and hold the cell for 1 second to trigger spawning a circle. Default is `0.1f`.


Usage
---------
Add the _BFPaperTableViewCell_ header and implementation file to your project. (.h & .m)

After that, you can use it just like any other `UITableViewCell`. 

If you use storyboards with prototype cells, be sure to change the prototype cell's class to _BFPaperTableViewCell_!

###Example
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
  cell.tapCircleColor = [[UIColor paperColorDeepPurple] colorWithAlphaComponent:0.3f];
  cell.backgroundFadeColor = [UIColor paperColorBlue];
  cell.backgroundFadeAlpha = 0.7f;
  cell.letBackgroundLinger = NO;
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
pod 'BFPaperTableViewCell', '~> 2.2.2'
```


License
--------
_BFPaperTableViewCell_ uses the MIT License:

> Please see included [LICENSE file](https://raw.githubusercontent.com/bfeher/BFPaperTableViewCell/master/LICENSE.md).
