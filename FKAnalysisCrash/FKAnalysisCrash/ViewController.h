//
//  ViewController.h
//  FKAnalysisCrash
//
//  Created by fengsh on 16/6/16.
//  Copyright © 2016年 fengsh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FKDragDropView.h"
#import "FKRadioGroup.h"

@interface ViewController : NSViewController<DragDropViewDelegate,NSOutlineViewDelegate,NSOutlineViewDataSource>

@property (weak) IBOutlet FKDragDropView *archiveview;
@property (weak) IBOutlet NSOutlineView *archiveListView;
@property (weak) IBOutlet FKRadioGroup *raidoGroup;
@property (weak) IBOutlet NSTextField *txtUUID;
@property (weak) IBOutlet NSTextField *loadAddress;
@property (weak) IBOutlet NSTextField *offsetAddress;
@property (unsafe_unretained) IBOutlet NSTextView *watchlog;
@property (weak) IBOutlet NSButton *radioapp;
@property (weak) IBOutlet NSButton *radiodsym;
@property (weak) IBOutlet NSTextField *loadaddrtittle;
@property (weak) IBOutlet NSTextField *addrtitle;
@property (weak) IBOutlet FKDragDropView *drapdSYM;
@property (weak) IBOutlet FKDragDropView *drapCrash;
@property (weak) IBOutlet NSTextField *lbdsymuuid;

@end

