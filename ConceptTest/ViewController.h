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

@property (nonatomic, weak) IBOutlet UIButton *aButton;
@property (nonatomic, weak) IBOutlet UIButton *bButton;
@property (nonatomic, weak) IBOutlet UIButton *cButton;
@property (nonatomic, weak) IBOutlet UIButton *dButton;

@property (nonatomic, weak) IBOutlet F3PlotStrip *headingStrip;
@property (nonatomic, weak) IBOutlet F3PlotStrip *pitchStrip;

- (IBAction)didTapA:(id)sender;
- (IBAction)didTapB:(id)sender;
- (IBAction)didTapC:(id)sender;
- (IBAction)didTapD:(id)sender;

- (IBAction)stopAll;

@end
