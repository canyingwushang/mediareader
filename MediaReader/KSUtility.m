
#import "KSUtility.h"
#import "SystemConfiguration/SCNetworkReachability.h"
#include <sys/types.h>
#include <sys/sysctl.h>

// 字节转字符串
NSString* sizeToString(double size)
{
    //DSLog(@"size is %f",size);
    if(size==0.0f)
    {
        return [NSString stringWithFormat : SizeFormat_KB,0.0f];
    }
    else if(size < 1024)
    {
        return [NSString stringWithFormat : SizeFormat_KB,1.0f];
    }

    NSString* strFileInfoFormat = nil;
    size /= 1024;
    if (size < 1024)
    {
        strFileInfoFormat = SizeFormat_KB;
    }
    else
    {
        size /= 1024;
        if (size < 1024)				
            strFileInfoFormat = SizeFormat_MB;
        else
        {
            size /= 1024;
            strFileInfoFormat = SizeFormat_GB;
        }
    }
    
    return [NSString stringWithFormat : strFileInfoFormat,size];
}

NSString* dateToString(NSDate* date)
{
	static NSDateFormatter* s_dateFormatter = nil;	// 会导致程序退出时的内存漏吗？
	if (nil == s_dateFormatter)
	{
		s_dateFormatter = [[NSDateFormatter alloc] init];
		[s_dateFormatter setDateFormat : @"yyyy-MM-dd HH:mm:ss"];
	}
	
	return [s_dateFormatter stringFromDate : date];
}
// 行转IndexPath
NSIndexPath* makeRowIndexPath(NSUInteger row)
{
	NSUInteger indexArray[] = {0, row};
	return [NSIndexPath indexPathWithIndexes : indexArray length : 2];
}
// 网络状态
BOOL isNetworkReachabel()
{
	BOOL isReachabel = NO;
	
	struct sockaddr addr = {0};
	addr.sa_len = sizeof(addr);
	addr.sa_family = AF_INET;
	SCNetworkReachabilityRef defaultRoute = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, &addr);
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(defaultRoute, &flags))
	{
		isReachabel = flags & kSCNetworkFlagsReachable;
	}
	CFRelease(defaultRoute);
	
	return isReachabel;
}
BOOL isUsingWifi()
{
	BOOL isUsingWifi = NO;
	struct sockaddr addr = {0};
	addr.sa_len = sizeof(addr);
	addr.sa_family = AF_INET;
	SCNetworkReachabilityRef defaultRoute = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, &addr);
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(defaultRoute, &flags))
	{
		BOOL isReachabel = (flags & kSCNetworkFlagsReachable) != 0;
		BOOL needsConnection = (flags & kSCNetworkFlagsConnectionRequired) != 0;
		BOOL isWWAN = (flags & kSCNetworkReachabilityFlagsIsWWAN) != 0;		// 运营商网络，非wifi
		isUsingWifi = isReachabel && !needsConnection && !isWWAN;
	}
	CFRelease(defaultRoute);
	
	return isUsingWifi;
}
BOOL isUsingWWAN()
{
	BOOL isUsingWWAN = NO;
	struct sockaddr addr = {0};
	addr.sa_len = sizeof(addr);
	addr.sa_family = AF_INET;
	SCNetworkReachabilityRef defaultRoute = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, &addr);
	SCNetworkReachabilityFlags flags;
	if (SCNetworkReachabilityGetFlags(defaultRoute, &flags))
	{
		BOOL isReachabel = (flags & kSCNetworkFlagsReachable) != 0;
		BOOL needsConnection = (flags & kSCNetworkFlagsConnectionRequired) != 0;
		BOOL isWWAN = (flags & kSCNetworkReachabilityFlagsIsWWAN) != 0;		// 运营商网络，非wifi
		isUsingWWAN = isReachabel && !needsConnection && isWWAN;
	}
	CFRelease(defaultRoute);
	
	return isUsingWWAN;
}
// 硬件信息
const NSString* getDeviceVersion()
{
	static NSString* s_deviceVersion = nil;
	if (nil == s_deviceVersion)
	{
		size_t size;
		sysctlbyname("hw.machine", NULL, &size, NULL, 0);
		char *machine = malloc(size);
		sysctlbyname("hw.machine", machine, &size, NULL, 0);
		
		s_deviceVersion = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
		[s_deviceVersion retain];	// 静态对象，未释放
		free(machine);
	}
	return s_deviceVersion;
}
BOOL isDeviceSupportHiSpeed()			// 是否是高速的硬件，对Navigation的动画有效果
{
	static NSInteger s_deviceVersion = 0;
	if (0 == s_deviceVersion)
	{
		const NSString* ver = getDeviceVersion();
		if ([ver isEqualToString : @"iPhone1,1"] ||		// iphone 1
			[ver isEqualToString : @"iPod1,1"] ||
			[ver isEqualToString : @"iPhone1,2"] ||		// iphone 3G
			[ver isEqualToString:@"iPod1,2"] ||
			[ver isEqualToString : @"iPad1,1"] )
			s_deviceVersion = 1;
		else
			s_deviceVersion = 2;
	}
	return s_deviceVersion > 1;
}
BOOL IsDeviceG11()
{
	static NSInteger s_G11 = 0;
	if (0 == s_G11)
	{
		const NSString* ver = getDeviceVersion();
		if ([ver isEqualToString:@"iPhone1,1"] ||
			[ver isEqualToString:@"iPod1,1"] )
			s_G11 = 2;
		else
			s_G11 = 1;
	}
	return s_G11 > 1;
}
BOOL IsDeviceG1()
{
	return isDeviceSupportHiSpeed();
//	const NSString* ver = getDeviceVersion();
//    if ([ver isEqualToString:@"iPhone1,1"]) return YES;
//    if ([ver isEqualToString:@"iPhone1,2"]) return YES;
//    if ([ver isEqualToString:@"iPod1,1"])   return YES;
//    if ([ver isEqualToString:@"iPod1,2"])   return YES;
// 	return NO;
}
NSUInteger getDeviceUniqueIdentifier()
{
	static NSUInteger s_DeviceID = 0;
	if (0 == s_DeviceID)
	{
		s_DeviceID = [[[UIDevice currentDevice] uniqueIdentifier] hash];
	}
	return s_DeviceID;
}
const NSString* getDeviceUniqueIdentifierString()
{
	static NSString* s_DeviceIDString = nil;
	if (nil == s_DeviceIDString)
	{
		s_DeviceIDString = [NSString stringWithFormat : @"%u", getDeviceUniqueIdentifier()];
		[s_DeviceIDString retain];		// 静态对象，未释放
	}
	return s_DeviceIDString;
}
const NSString* getSessionString()
{
	static NSString* s_SessionString = nil;
	if (nil == s_SessionString)
	{
		NSDate* date = [NSDate dateWithTimeIntervalSinceReferenceDate : 300000000];
		NSTimeInterval interval = -[date timeIntervalSinceDate : [NSDate date]];
		s_SessionString = [NSString stringWithFormat : @"%.0f", interval];
		[s_SessionString retain];		// 静态对象，未释放
	}
	return s_SessionString;
}
const NSString* getDeviceIdString()
{
	static NSString* s_DevidString = nil;
	if (nil == s_DevidString)
	{
		s_DevidString = [[UIDevice currentDevice] uniqueIdentifier];
		[s_DevidString retain];		// 静态对象，未释放
	}
	return s_DevidString;
}
//model
const NSString* getDeviceModelString()
{
	static NSString* s_ModelString = nil;
	if (nil == s_ModelString)
	{
		s_ModelString = [[UIDevice currentDevice] model];
		[s_ModelString retain];		// 静态对象，未释放
	}
	return s_ModelString;
}

//ios version
const NSString* getIOSVersionString()
{
    static NSString* s_versionString = nil;
	if (nil == s_versionString)
	{
		s_versionString = [[UIDevice currentDevice] systemVersion];
		[s_versionString retain];		// 静态对象，未释放
	}
	return s_versionString;
}

// 软件系统信息
double getIOSVersion()
{
	static double s_version = -1;
	if (-1 == s_version)
	{
		NSString* ver = [[UIDevice currentDevice] systemVersion];
		s_version = [ver doubleValue];
	}
	return s_version;
}
//BOOL isOSSupportAssetsLibrary()		// 是否支持相册
//{
//	return getIOSVersion() >= 4.0;
//}
//BOOL isOSSupportGestures()			// 是否支持手势
//{
//	return getIOSVersion() >= 3.2;
//}
//BOOL isOSSupportOpenWith()
//{
//	return getIOSVersion() >= 3.2;
//}
//BOOL isOSSupportAppDelegateMessage_OpenUrlSourceApplication()
//{
//	// check for "UIApplicationDelegate application:openURL:sourceApplication:annotation:"
//	return getIOSVersion() >= 4.2;
//}
// 屏幕大小
CGRect getMaxViewFrame(UIInterfaceOrientation orientaition)
{
	BOOL bStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
	switch (orientaition)
	{
		case UIInterfaceOrientationPortrait           :
		case UIInterfaceOrientationPortraitUpsideDown :
		case UIInterfaceOrientationLandscapeLeft      :
		case UIInterfaceOrientationLandscapeRight     :
			break;
		default:
			orientaition = [[UIApplication sharedApplication] statusBarOrientation];
	}
	
	switch (orientaition)
	{
		case UIInterfaceOrientationPortrait           :
		case UIInterfaceOrientationPortraitUpsideDown :
			return CGRectMake(0.0, 0.0, 
							  bStatusBarHidden ? kPortraitFullViewWidthStatusBarHidden : kPortraitFullViewWidth,
							  bStatusBarHidden ? kPortraitFullViewHeightStatusBarHidden : kPortraitFullViewHeight);
			break;
			//case UIInterfaceOrientationLandscapeLeft      :
			//case UIInterfaceOrientationLandscapeRight     :
		default:
			return CGRectMake(0.0, 0.0, 
							  bStatusBarHidden ?  kLandscapeFullViewWidthStatusBarHidden : kLandscapeFullViewWidth,
							  bStatusBarHidden ? kLandscapeFullViewHeightStatusBarHidden : kLandscapeFullViewHeight);
	}
}

#import <math.h>
CGFloat distanceFromPoints(CGPoint first, CGPoint second)
{
	CGFloat x = fabsf(second.x - first.x);
	CGFloat y = fabsf(second.y - first.y);
	if (0 == x)
		return y;
	if (0 == y)
		return x;
	return sqrt(x * x + y * y);
}
BOOL isPointInRect (CGPoint pt, CGRect rect)
{
	if (pt.x >= rect.origin.x && (pt.x - rect.origin.x) <= rect.size.width &&
		pt.y >= rect.origin.y && (pt.y - rect.origin.y) <=  rect.size.height)
		return YES;
	return NO;
}
