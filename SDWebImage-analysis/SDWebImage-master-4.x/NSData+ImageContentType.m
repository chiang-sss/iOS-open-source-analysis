/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "NSData+ImageContentType.h"


@implementation NSData (ImageContentType)


/**
 当文件都使用二进制流作为传输时，用文件头区分该文件到底是什么类型的

 @param data 二进制data数据

 @return 图片格式
 */
+ (SDImageFormat)sd_imageFormatForImageData:(nullable NSData *)data {
    if (!data) {
        return SDImageFormatUndefined;
    }
    
    uint8_t c;
    /// 把data数据，取第一位，然后用u8转，获取头数据,是什么字节开头的
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return SDImageFormatJPEG;
        case 0x89:
            return SDImageFormatPNG;
        case 0x47:
            return SDImageFormatGIF;
        case 0x49:
        case 0x4D:
            return SDImageFormatTIFF;
        case 0x52:
            // R as RIFF for WEBP
            
            
            // WebP是由12个字节组成的文件头.属于特别的一种类型
            // WebP : 524946462A73010057454250
            // 52开头的，但是长度却小于12的，默认当成未定义的格式
            if (data.length < 12) {
                return SDImageFormatUndefined;
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
                return SDImageFormatWebP;
            }
    }
    return SDImageFormatUndefined;
}

@end
