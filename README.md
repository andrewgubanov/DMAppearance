# DMAppearance
Custom proxy with partial UIApearance functionality to facilitate appearance sweets for any other object apart from UIKit ones.
This implementation keeps track of the original method calls and does not apply the style from appearance to the reciever for those methods.

## How To Use
``` objc
@interface MyObject : NSObject <DMAppearance>
@property (nonatomic, copy) NSString *name;
@end

@implementation MyObject

+ (instancetype)appearance
{
    return (id)[DMAppearanceRecorder appearanceRecorderForClass:self];
}
@end

```
Then, when your object is ready to accept appearance styling you can call:
``` objc
[[DMAppearanceRecorder appearanceRecorderForClass:[self class]] applyAppearanceForTarget:self];
```

Somewhere in your code where you would use MyObject:
``` objc
MyObject *appearance = [MyObject appearance];
appearance.name = @"Shared name";
```

And somewhere else:
``` objc
MyObject *myObject = [[MyObject alloc] init];
NSLog(@"%@", myObject.name);

myObject = [[MyObject alloc] init];
myObject.name = @"Custom name";
NSLog(@"%@", myObject.name);
```
Dispalyed result would be:
``` objc
"Shared name"
"Custom name"
```

You can alse refer to Demo project for mode details.

## Installation

DMAppearance is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DMAppearance"
