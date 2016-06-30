//
//  ViewController.m
//  FKAnalysisCrash
//
//  Created by fengsh on 16/6/16.
//  Copyright © 2016年 fengsh. All rights reserved.
//

#import "ViewController.h"
#import "FKArchiveFile.h"
#import "FKCommandTask.h"

const NSString *suid = @"UUID: ";
const NSString *sid = @"91BA500F-3A0B-3398-B5FE-4ACBCA17493C";

@interface ViewController()
{
    NSMutableArray          *_filelist;
    NSString                *_currentSelectedArch;
    NSString                *_dsymfilePath;
    NSString                *_crashfilePath;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view.window setTitle:@"ggg"];

    self.archiveview.delegate = self;
    self.drapCrash.delegate = self;
    self.drapdSYM.delegate = self;
    self.archiveListView.delegate = self;
    self.archiveListView.dataSource = self;
    
    _filelist = [NSMutableArray array];
    
    [self.radioapp setState:NSOnState];
    
    [self loadPanelView];
}

- (void)loadPanelView
{
    if (self.radioapp.state == NSOnState) {
        self.loadaddrtittle.stringValue = @"请输入crash地址";
        self.addrtitle.hidden = YES;
        self.offsetAddress.hidden = YES;
    }
    else
    {
        self.loadaddrtittle.stringValue = @"运行时栈地址(Stack address)";
        self.addrtitle.stringValue = @"运行时偏移地址Slide address";
        self.addrtitle.hidden = NO;
        self.offsetAddress.hidden = NO;
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

-(void)dragDropView:(FKDragDropView *)dropview FileList:(NSArray*)fileList
{
    
    //如果数组不存在或为空直接返回不做处理（这种方法应该被广泛的使用，在进行数据处理前应该现判断是否为空。）
    if(!fileList || [fileList count] <= 0)return;
    //在这里我们将遍历这个数字，输出所有的链接，在后台你将会看到所有接受到的文件地址
    [_filelist removeAllObjects];
    for (int n = 0 ; n < [fileList count] ; n++) {
        NSString *file = [fileList objectAtIndex:n];
        NSString *ext = [file pathExtension];
        if ([ext isEqualToString:@"xcarchive"]) {
            FKArchiveFile *af = [[FKArchiveFile alloc]initwithFileString:file];
            [_filelist addObject:af];
        }
        
        if (dropview == self.drapdSYM && [ext isEqualToString:@"dSYM"])
        {
            _dsymfilePath = [file copy];
            
            NSArray *list = [FKCommandTask readUUIDBydSYMInfo:_dsymfilePath];
            self.lbdsymuuid.stringValue = list[0];
            return;
        }
        
        if (dropview == self.drapCrash && [ext isEqualToString:@"crash"])
        {
            _crashfilePath = [file copy];
            return;
        }
    }
    
    [self.archiveListView reloadData];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item
{
    return _filelist[index];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item
{
    return _filelist.count;
}

- (nullable NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item
{
    NSTableCellView *result = [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    FKArchiveFile *af = item;
    
    result.imageView.image = nil;
    result.textField.stringValue = af.fileName;
    
    return result;
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    _currentSelectedArch = nil;
    FKArchiveFile *selectedItem = [self.archiveListView itemAtRow:[self.archiveListView selectedRow]];
    
    [self parseArchivFile:selectedItem];
    //动态创建单选架构
    [self createRadioButton:selectedItem.cpuArchs];
}

- (void)parseArchivFile:(FKArchiveFile *)avf
{
    //此方式，如果把app名改了，就不好取到执行的二进制文件了。
   // NSArray *list = [FKCommandTask readUUIDByAppInfo:[[avf.appUrl path] stringByAppendingPathComponent:avf.appName]];
    
    NSArray *list = [FKCommandTask readUUIDBydSYMInfo:[avf.dSYMUrl path]];
    
    NSMutableArray *arr = [NSMutableArray array];
    
    for (NSString *s in list) {
        if (s.length > 0) {

            NSString *uuid = [s substringWithRange:NSMakeRange(suid.length, sid.length)];
            NSString *cpu = [self metchCpu:s];
            CPUAndUUID *cid = [[CPUAndUUID alloc]init];
            cid.uuid = uuid;
            cid.cpu = cpu;
            [arr addObject:cid];
        }
    }
    
    avf.cpuArchs = arr;
    
    if (arr.count == 0)
    {
        self.watchlog.string = @"解释打包文件出错!";
    }
}

//匹配cpu
- (NSString *)metchCpu:(NSString *)src
{
    NSString *s = [src lowercaseString];
    NSRange start = [s rangeOfString:@"("];
    NSRange end = [s rangeOfString:@")"];
    NSInteger len = end.location - start.location;
    if ((start.location != NSNotFound) && (end.location != NSNotFound) && len > 0) {
        return [s substringWithRange:NSMakeRange(start.location+1, len-1)];
    }
    
    return nil;
}

//一列3个，
- (void)createRadioButton:(NSArray *)archs
{
    CGFloat H = CGRectGetHeight(self.raidoGroup.frame);
    CGFloat itemW = 70;
    //每个item间隔
    CGFloat offy = (H - 3*20 - 4 - 4) / 3;//边缘间隔4
    CGFloat offx = 10;

    for (NSInteger i = 1 ; i <= archs.count; i++) {
        NSInteger col = ceilf(i / 3.0) ;
        NSInteger ii = i % 3;
        if (ii == 0)
        {
            ii = 3;
        }
        
        NSButton *radiobutton = [[NSButton alloc]initWithFrame:NSMakeRect(offx + (offx + itemW)*(col-1),4 + (20 + offy)*(ii-1), itemW, 20)];
        [radiobutton setButtonType:NSRadioButton];
        radiobutton.tag = i-1;
        [radiobutton setTarget:self];
        [radiobutton setAction:@selector(onRadioButtonClicked:)];
        CPUAndUUID *cid = archs[i-1];
        
        [radiobutton setTitle:cid.cpu];
        [self.raidoGroup addSubview:radiobutton];
    }
}

- (void)onRadioButtonClicked:(NSButton *)button
{
    NSInteger idx = button.tag;
    FKArchiveFile *selectedItem = [self.archiveListView itemAtRow:[self.archiveListView selectedRow]];
    if (idx < selectedItem.cpuArchs.count) {
        CPUAndUUID *cid = selectedItem.cpuArchs[idx];
        self.txtUUID.stringValue = cid.uuid;
        _currentSelectedArch = cid.cpu;
    }
}

- (IBAction)onParseCrashAddrClicked:(id)sender
{
    FKArchiveFile *selectedItem = [self.archiveListView itemAtRow:[self.archiveListView selectedRow]];
    
    if (!selectedItem) {
        return;
    }
    
    if (!_currentSelectedArch) {
        return;
    }
    
    NSString *laddr = [self.loadAddress.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *offaddr = [self.offsetAddress.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    if (self.radioapp.state == NSOnState) {
        if (laddr.length > 0) {
            self.watchlog.string = [FKCommandTask parseCrashAddressFormApp:[selectedItem.appUrl path] withCrashAddress:laddr inCpuArch:_currentSelectedArch];
        }
        else
        {
            _watchlog.string = @"嘿，点什么呢，地址没填呢。";
        }
    }
    else
    {
        if (laddr.length >0  && offaddr.length > 0) {
            
            if ([laddr rangeOfString:@"0x"].location == NSNotFound)
            {
                _watchlog.string = @"运行时栈地址(Stack address) 不合法: 应该使用 0x1002 的形式";
                return;
            }
            
            if ([offaddr rangeOfString:@"0x"].location == NSNotFound)
            {
                _watchlog.string = @"运行时偏移地址Slide address 不合法: 应该使用 0x1002 的形式";
                return;
            }

            NSString *crashaddr = [FKCommandTask hexStringSub:laddr with:offaddr];
            
            self.watchlog.string = [FKCommandTask parseCrashAddressFormdSYM:[selectedItem.dSYMUrl path] withCrashAddress: crashaddr inCpuArch:_currentSelectedArch];
        }
        else
        {
            _watchlog.string = @"哥们，别玩了，地址没输呢，检查下。";
        }
    }
}

- (IBAction)onAppclicked:(id)sender
{
    [self.radiodsym setState:NSOffState];
    
    [self loadPanelView];
}

- (IBAction)ondsymClicked:(id)sender
{
    [self.radioapp setState:NSOffState];
    
    [self loadPanelView];
}

@end
