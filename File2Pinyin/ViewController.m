//
//  ViewController.m
//  File2Pinyin
//
//  Created by 孙继刚 on 16/3/30.
//  Copyright © 2016年 Madordie. All rights reserved.
//

#import "ViewController.h"
#import "PinYin4Objc.h"

@interface ViewController ()
@property (weak) IBOutlet NSPathControl *path;
@property (unsafe_unretained) IBOutlet NSTextView *log;

@property (nonatomic, strong) HanyuPinyinOutputFormat *format;

@end
@implementation ViewController
- (IBAction)change:(id)sender {
    self.log.string = @"";
    NSString *path = [self.path.pathItems.lastObject.URL.absoluteString stringByRemovingPercentEncoding];
    [self logout:path];
    [self changeFileName2Pinyin:[path substringFromIndex:@"file://".length]];
}

- (void)changeFileName2Pinyin:(NSString *)path {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray<NSString *> *files = [fileManager contentsOfDirectoryAtPath:path error:&error];
    if (files) {
        [self logout:@"开始处理："];
        [self logout:path];
        [files enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BOOL isDirectory = YES;
            NSString *fullPath = [path stringByAppendingPathComponent:obj];
            if([fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory]) {
                if (!isDirectory) {
                    
                    NSString *newFile = [[obj componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]] componentsJoinedByString:@"_"];
                    
                    [PinyinHelper toHanyuPinyinStringWithNSString:newFile
                                      withHanyuPinyinOutputFormat:self.format
                                                     withNSString:@"_"
                                                      outputBlock:^(NSString *pinYin) {
                                                          [self logout:[NSString stringWithFormat:@"%@ -> %@", obj, pinYin]];
                                                          NSString *info;
                                                          NSError *error;
                                                          if (![fileManager moveItemAtPath:fullPath toPath:[path stringByAppendingPathComponent:pinYin] error:&error]) {
                                                              info = [NSString stringWithFormat:@"error:%@", error];
                                                          } else {
                                                              info = @"OK.";
                                                          }
                                                          [self logout:info];
                                                      }];
                }
            }
        }];
    } else {
        [self logout:[NSString stringWithFormat:@"错误：%@", error]];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.log.editable = NO;
    
    HanyuPinyinOutputFormat *outputFormat=[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];
    [outputFormat setVCharType:VCharTypeWithV];
    [outputFormat setCaseType:CaseTypeLowercase];
    self.format = outputFormat;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)logout:(NSString *)log {
    self.log.string = [NSString stringWithFormat:@"%@\t%@\n", self.log.string, log];
}

@end
