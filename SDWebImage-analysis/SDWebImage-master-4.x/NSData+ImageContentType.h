/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 * (c) Fabrice Aneche
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import <Foundation/Foundation.h>
#import "SDWebImageCompat.h"


/**
    枚举定义图片格式

 - SDImageFormatUndefined: 图片的格式
 */
typedef NS_ENUM(NSInteger, SDImageFormat) {
    SDImageFormatUndefined = -1,    /// 未定义格式   说明不是图片格式，有可能是其他格式
    SDImageFormatJPEG = 0,          /// JPEG
    SDImageFormatPNG,               /// PNG
    SDImageFormatGIF,               /// GIF
    SDImageFormatTIFF,              /// TIFF
    SDImageFormatWebP               /// WebP
};

@interface NSData (ImageContentType)

/**
 当文件都使用二进制流作为传输时，用文件头区分该文件到底是什么类型的
 
 @param data 二进制data数据
 
 @return 图片格式
 */
+ (SDImageFormat)sd_imageFormatForImageData:(nullable NSData *)data;


/**
 + (SDImageFormat)sd_imageFormatForImageData:(nullable NSData *)data __deprecated_msg("Use `sd_contentTypeForImageData:`");
 
 使用__deprecated_msg来定义一个函数是否已经过期,不建议使用
**/
@end
