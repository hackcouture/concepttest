//
//  ViewController.h
//  ConceptTest
//
//  Created by phil on 10/26/13.
//  Copyright (c) 2013 Phil Kast. All rights reserved.
//

#import <UIKit/UIKit.h>

@class F3PlotStrip;

@interface ViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *yesLabel;
@property (nonatomic, weak) IBOutlet UILabel *noLabel;

@property (nonatomic, weak) IBOutlet F3PlotStrip *plotStrip;

@end
