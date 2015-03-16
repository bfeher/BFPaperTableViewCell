BFPaperTableViewCell
====================
[![CocoaPods](https://img.shields.io/cocoapods/v/BFPaperTableViewCell.svg?style=flat)](https://github.com/bfeher/BFPaperTableViewCell)

> Note that this changelog was started very late, at roughly the time between version 2.1.17 and 2.2.1. Previous changes are lost to the All Father, forever to be unknown.



2.2.2
---------
+ Merged a branch from github user @eithanshavit, bringing back support for a tapDelay of 0.


2.2.1
---------
+ Added a changelog!
+ Added public property `tapDelay` to allow control over whether or not to spawn a tap circle. If the touch ends or is cancelled before the tap-delay is complete, no circles will be spawned. Default is `0.1f`.
- Removed vestigial private property `letGo`.
- Removed vestigial private property `beganHighlight`.
- Removed vestigial private property `beganSelection`.
- Removed vestigial private property `bAlreadyFadedBackgroundIn`.
- Removed vestigial private property `bAlreadyFadedBackgroundOut`.