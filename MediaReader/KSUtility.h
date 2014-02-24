
// 实现工具函数
#ifndef _KSUtility_
#define _KSUtility_

#import <UIKit/UIKit.h>

// 提供RGB模式的UIColor定义.
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

// 字节转字符串
#define SizeFormat_B		@"%0.0fB"
#define SizeFormat_KB		@"%0.0fKB"
#define SizeFormat_MB		@"%0.1fMB"
#define SizeFormat_GB		@"%0.1fGB"

NSString* sizeToString(double size);
NSString* dateToString(NSDate* date);

// 行转IndexPath
NSIndexPath* makeRowIndexPath(NSUInteger row);

// 网络状态
BOOL isNetworkReachabel();
BOOL isUsingWifi();
BOOL isUsingWWAN();

// 硬件系统信息
const NSString* getDeviceVersion();
BOOL isDeviceSupportHiSpeed();			// 是否是高速的硬件，对Navigation的动画有效果
BOOL IsDeviceG11();
BOOL IsDeviceG1();
NSUInteger getDeviceUniqueIdentifier();
const NSString* getDeviceUniqueIdentifierString();
const NSString* getSessionString();
const NSString* getDeviceModelString();
const NSString* getIOSVersionString();
const NSString* getDeviceIdString();
// 软件系统信息

double getIOSVersion();
//BOOL isOSSupportAssetsLibrary();	// 是否支持相册
//BOOL isOSSupportGestures();			// 是否支持手势
//BOOL isOSSupportOpenWith();
//BOOL isOSSupportAppDelegateMessage_OpenUrlSourceApplication();
// 屏幕大小
#ifdef DeviceScreenSize_480_320
	#define kPortraitFullViewWidth		320.0
	#define kPortraitFullViewHeight		460.0
	#define kLandscapeFullViewWidth		480.0
	#define kLandscapeFullViewHeight	300.0

	#define kPortraitFullViewWidthStatusBarHidden		320.0
	#define kPortraitFullViewHeightStatusBarHidden		480.0
	#define kLandscapeFullViewWidthStatusBarHidden		480.0
	#define kLandscapeFullViewHeightStatusBarHidden		320.0
#else
	#define kPortraitFullViewWidth		768.0
	#define kPortraitFullViewHeight		1004.0
	#define kLandscapeFullViewWidth		1024.0
	#define kLandscapeFullViewHeight	748.0

	#define kPortraitFullViewWidthStatusBarHidden		768.0
	#define kPortraitFullViewHeightStatusBarHidden		1024.0
	#define kLandscapeFullViewWidthStatusBarHidden		1024.0
	#define kLandscapeFullViewHeightStatusBarHidden		768.0
#endif

CGRect getMaxViewFrame(UIInterfaceOrientation orientaition);

CGFloat distanceFromPoints(CGPoint first, CGPoint second);
BOOL isPointInRect (CGPoint pt, CGRect rect);
//NSString* getPhotoNameFromDate(NSDate* date);

//比较系统版本号
#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_2_0

#define kCFCoreFoundationVersionNumber_iPhoneOS_2_0	478.23
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_1 478.26
#define kCFCoreFoundationVersionNumber_iPhoneOS_2_2 478.29
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_0 478.47
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_1 478.52
#define kCFCoreFoundationVersionNumber_iPhoneOS_3_2 478.61
#define kCFCoreFoundationVersionNumber_iOS_4_0 550.32
#define kCFCoreFoundationVersionNumber_iOS_4_1 550.38
#define kCFCoreFoundationVersionNumber_iOS_4_2 550.52

#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_4_3
#define kCFCoreFoundationVersionNumber_iOS_4_3 550.58
#endif
#ifndef kCFCoreFoundationVersionNumber_iOS_5_0
#define kCFCoreFoundationVersionNumber_iOS_5_0 675.00
#endif
#ifndef kCFCoreFoundationVersionNumber_iOS_5_1
#define kCFCoreFoundationVersionNumber_iOS_5_1 690.10
#endif

#define IS_IOS_5_0 (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0 && kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_5_1)
#define IS_IOS_5_0_OR_GRATER (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_0)
#define IS_IOS_5_1_OR_GRATER (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_5_1)

#define IS_IOS_3_2_OR_GRATER (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_3_2)

#define IS_IOS_4_2_OR_GRATER (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_4_2)

//是否支持跳转到设置
#define isOSSupportGotoSet IS_IOS_5_0
// 是否支持手势
#define isOSSupportGestures IS_IOS_3_2_OR_GRATER
// 是否支持打开方式
#define isOSSupportOpenWith IS_IOS_3_2_OR_GRATER

#endif