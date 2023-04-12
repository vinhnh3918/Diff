#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>

#import <sys/sysctl.h>
#import <sys/time.h>
#import <sys/types.h>
#import <unistd.h>

@implementation AppDelegate

- (double)measureAppStartUpTime {
    struct kinfo_proc kinfo;
    size_t size = sizeof(kinfo);
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    sysctl(mib, 4, &kinfo, &size, NULL, 0);
    struct timeval time;
    gettimeofday(&time, NULL);
    double currentTimeMilliseconds = (double)(time.tv_sec * 1000) + (double)time.tv_usec / 1000.0;
    double processTimeMilliseconds = (double)(kinfo.kp_proc.p_starttime.tv_sec * 1000) + (double)kinfo.kp_proc.p_starttime.tv_usec / 1000.0;
    return (currentTimeMilliseconds - processTimeMilliseconds) / 1000.0;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"DiffRN";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};
  NSLog(@"VDT %f", self.measureAppStartUpTime);
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

/// This method controls whether the `concurrentRoot`feature of React18 is turned on or off.
///
/// @see: https://reactjs.org/blog/2022/03/29/react-v18.html
/// @note: This requires to be rendering on Fabric (i.e. on the New Architecture).
/// @return: `true` if the `concurrentRoot` feature is enabled. Otherwise, it returns `false`.
- (BOOL)concurrentRootEnabled
{
  return true;
}

@end
