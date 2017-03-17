# iOS DFU Library

[![Version](http://img.shields.io/cocoapods/v/iOSDFULibrary.svg)](http://cocoapods.org/pods/iOSDFULibrary)

## Installation instructions for Obj-C projects

**Using Cocoapods:**

- Create/Update your **Podfile** with the following contents
```
target 'YourAppTargetName' do
use_frameworks!
pod 'iOSDFULibrary'
end
```
- Install dependencies

pod install

- Open the newly created `.xcworkspace` and begin working on your project.
- If Xcode asks to migrate code to Swift 3, choose **Later**. (The codebase is Swift 3 already)
- Click on the `Pods` project, then go to the `Build Settings`
- Click on the `iOSDFULibrary` target, then set the `Use Legacy Swift version` setting to `No`
- Repeat the same for the `Zip` target.
- Build the project, it should now succeed.
- Import the library to any of your obj-c classes by using `@import iOSDFULibrary;` and begin working on your project.


Currently, the only tested and supported method for Obj-C projects is using Cocoapods.
