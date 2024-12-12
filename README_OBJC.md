# iOS DFU Library

[![Version](http://img.shields.io/cocoapods/v/NordicDFU.svg)](http://cocoapods.org/pods/NordicDFU)

## Installation instructions for Obj-C projects

**Using Cocoapods:**

- Create/Update your **Podfile** with the following contents
```
target 'YourAppTargetName' do
use_frameworks!
pod 'NordicDFU'
end
```
- Install dependencies
```
pod install
```
- Open the newly created `.xcworkspace` and begin working on your project.
- If Xcode asks to migrate code to Swift 5.5, choose **Later**. (The codebase is Swift 5.5 already)
- Click on the `Pods` project, then go to the `Build Settings`
- Click on the `NordicDFU` target, then set the `Use Legacy Swift version` setting to `No`
- Repeat the same for the `ZIPFoundation` target.
- Build the project, it should now succeed.
- Import the library to any of your obj-c classes by using `@import NordicDFU;` and begin working on your project.


Currently, the only tested and supported method for Obj-C projects is using Cocoapods.
