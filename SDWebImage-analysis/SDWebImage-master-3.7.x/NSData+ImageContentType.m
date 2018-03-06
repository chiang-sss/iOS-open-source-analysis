//
// Created by Fabrice Aneche on 06/01/14.
// Copyright (c) 2014 Dailymotion. All rights reserved.
//

#import "NSData+ImageContentType.h"


@implementation NSData (ImageContentType)

+ (NSString *)sd_contentTypeForImageData:(NSData *)data {
    uint8_t c;
    /// 把data数据，取第一位，然后用u8转，获取头数据,是什么字节开头的
    [data getBytes:&c length:1];

    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        case 0x52:
            // R as RIFF for WEBP
            
            // WebP是由12个字节组成的文件头.属于特别的一种类型
            // WebP : 524946462A73010057454250
            // 52开头的，但是长度却小于12的，默认当成未定义的格式
            if ([data length] < 12) {
                return nil;
            }
            /**
             524946462A73010057454250 通过 ASCII编码后，获得的数据，如上
             52 -> R
             49 -> I
             46 -> F
             46 -> F
             **/
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }

            return nil;
    }
    return nil;
}

@end


@implementation NSData (ImageContentTypeDeprecated)

+ (NSString *)contentTypeForImageData:(NSData *)data {
    return [self sd_contentTypeForImageData:data];
}

@end
