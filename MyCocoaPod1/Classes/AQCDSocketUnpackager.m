//
//  AQCDSocketUnpackager.m
//  UDP_Socket_Client
//
//  Created by MarkMyLove-Mac on 2017/6/28.
//  Copyright © 2017年 林钰堂. All rights reserved.
//

#import "AQCDSocketUnpackager.h"

static short int kPackageHeader = 0xfffb;
static short int kPackageEnder = 0xfffe;

@interface AQCDSocketUnpackager ()

// 不完整的包，等待接收完整, 通过senderId来存放
@property (nonatomic, strong) NSMutableDictionary *unPackageDict;
@property (nonatomic, strong) NSMutableSet *packageSuccessSetIdSet;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

@implementation AQCDSocketUnpackager
- (instancetype)init {
    self = [super init];
    if (self) {
        self.semaphore = dispatch_semaphore_create(2);
    }
    return self;
}


/// 接收数据包， 同过代理回掉
- (void)unpackageTCP_MessagePackage:(NSData *)package complete:(void (^)())complete{
    
//    2 字节包头 + 4位包长度 + 4位发送者id + 4位接受者id + 8位消息id + 1位命令类型 + 1位消息类型 + 2位顺序号 + 2位总包数 + 内容 + 2位结尾
    
    BOOL isSuccess = YES;
    
    NSInteger locaton = 0;
    
    /// 取包头，如果不是，丢弃 2位
    short int packageHeader;
    [package getBytes: &packageHeader range: NSMakeRange(locaton, 2)];
    /// 避免高低位不一样
    short int nPackageHeader = ntohs(packageHeader);
    short int hPackageHeader = packageHeader;
    locaton += 2;
    if ( (nPackageHeader != kPackageHeader) && (hPackageHeader != kPackageHeader)) {
        isSuccess = NO;
    }
    int contentLenght = 0;
    
    /// 取总长度 4位
    int totalLenght;
    [package getBytes: &totalLenght range: NSMakeRange(locaton, 4)];
    locaton += 4;
    contentLenght = totalLenght;
    NSLog(@"取总长度-----%d", contentLenght);

    /// 取接受者 4位
    int senderId;
    [package getBytes: &senderId range: NSMakeRange(locaton, 4)];
    senderId = senderId;
    locaton += 4;
    contentLenght -= 4;
    
    /// 取接受者 4位
    int receiverId;
    [package getBytes: &receiverId range: NSMakeRange(locaton, 4)];
    receiverId = receiverId;
    locaton += 4;
    contentLenght -= 4;
    
    // 取消息id 8位字符串
    NSData *messsagIdData = [package subdataWithRange: NSMakeRange(locaton, 8)];
    locaton += 8;
    contentLenght -= 8;
    NSString *messageId = [[NSString alloc] initWithData:messsagIdData encoding: NSUTF8StringEncoding];
    
    /// 取命令类型 1位
    char orderType;
    [package getBytes: &orderType range: NSMakeRange(locaton, 1)];
    locaton += 1;
    contentLenght -= 1;

    /// 取子命令类型 1位
    char contentType;
    [package getBytes: &contentType range: NSMakeRange(locaton, 1)];
    locaton += 1;
    contentLenght -= 1;
    
    /// 取包序号 2
    short int packageNumber;
    [package getBytes: &packageNumber range: NSMakeRange(locaton, 2)];
    locaton += 2;
    contentLenght -= 2;

    /// 取总包数 2
    short int totalPackageCount;
    [package getBytes: &totalPackageCount range: NSMakeRange(locaton, 2)];
    locaton += 2;
    contentLenght -= 2;
    
    
    long long timeStamp;
    [package getBytes: &timeStamp range: NSMakeRange(locaton, 8)];
    locaton += 8;
    contentLenght -= 8;

    // 取内容，并解析成字符串
    NSData *contentData = [package subdataWithRange: NSMakeRange(locaton, contentLenght)];
    locaton += contentLenght;
    NSData *data = contentData;
    
    /// 尾包头 2位，如果不是，丢弃
    short int packageEnder = 0;
    [package getBytes: &packageEnder range: NSMakeRange(locaton, 2)];
    
    /// 避免高低位不一样
    short int nPackageEnder= ntohs(packageEnder);
    short int hPackageEnder = packageEnder;
    if ( (nPackageEnder != kPackageEnder) && (hPackageEnder != kPackageEnder)) {
        isSuccess = NO;
    }
    
}


/// 获取包的数组
- (NSMutableDictionary *)unPackageForMessageId:(NSString *)messageId {
    NSMutableDictionary *dict = self.unPackageDict[ messageId ];
    if (dict == nil) {
        dict = [[NSMutableDictionary alloc] init];
        [self.unPackageDict setObject: dict forKey: messageId];
    }
    return dict;
}

/// 未解压的所有数据
- (NSMutableDictionary *)unPackageDict {
    if (_unPackageDict == nil) {
        _unPackageDict = [[NSMutableDictionary alloc] init];;
    }
    return _unPackageDict;
}

- (NSMutableSet *)packageSuccessSetIdSet {
    if (_packageSuccessSetIdSet == nil) {
        _packageSuccessSetIdSet = [[NSMutableSet alloc] init];
    }
    return _packageSuccessSetIdSet;
}

@end
