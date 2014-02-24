//
//  MRCoverViewController.h
//  MediaReader
//
//  Created by jinbo he on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRCatalogViewController.h"
#import "FlipTransition.h"
#import "HMGLTransitionManager.h"

@interface MRCoverViewController : UIViewController
{
    IBOutlet UIImageView * _coverView;
    IBOutlet UIButton    * _btnCatalog;
}
@end
