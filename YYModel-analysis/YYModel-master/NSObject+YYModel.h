//
//  NSObject+YYModel.h
//  YYModel <https://github.com/ibireme/YYModel>
//
//  Created by ibireme on 15/5/10.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provide some data-model method:
 
 * Convert json to any object, or convert any object to json.
 * Set object properties with a key-value dictionary (like KVC).
 * Implementations of `NSCoding`, `NSCopying`, `-hash` and `-isEqual:`.
 
 See `YYModel` protocol for custom methods.
 
 
 Sample Code:
    
     ********************** json convertor *********************
     @interface YYAuthor : NSObject
        @property (nonatomic, strong) NSString *name;
        @property (nonatomic, assign) NSDate *birthday;
     @end
     @implementation YYAuthor
     @end
 
     @interface YYBook : NSObject
        @property (nonatomic, copy) NSString *name;
        @property (nonatomic, assign) NSUInteger pages;
        @property (nonatomic, strong) YYAuthor *author;
     @end
     @implementation YYBook
     @end
    
     int main() {
         // create model from json
         YYBook *book = [YYBook yy_modelWithJSON:@"{\"name\": \"Harry Potter\", \"pages\": 256, \"author\": {\"name\": \"J.K.Rowling\", \"birthday\": \"1965-07-31\" }}"];
 
         // convert model to json
         NSString *json = [book yy_modelToJSONString];
         // {"author":{"name":"J.K.Rowling","birthday":"1965-07-31T00:00:00+0000"},"name":"Harry Potter","pages":256}
     }
 
     ********************** Coding/Copying/hash/equal *********************
     @interface YYShadow :NSObject <NSCoding, NSCopying>
        @property (nonatomic, copy) NSString *name;
        @property (nonatomic, assign) CGSize size;
     @end
 
     @implementation YYShadow
     - (void)encodeWithCoder:(NSCoder *)aCoder { [self yy_modelEncodeWithCoder:aCoder]; }
     - (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self yy_modelInitWithCoder:aDecoder]; }
     - (id)copyWithZone:(NSZone *)zone { return [self yy_modelCopy]; }
     - (NSUInteger)hash { return [self yy_modelHash]; }
     - (BOOL)isEqual:(id)object { return [self yy_modelIsEqual:object]; }
     @end
 
 */
@interface NSObject (YYModel)


/**
 NSDictionary,NSString,NSData 等三种json格式数据转对象模型
**/
+ (nullable instancetype)yy_modelWithJSON:(id)json;

/**
 NSDictionary的json格式数据转对象模型
 **/
+ (nullable instancetype)yy_modelWithDictionary:(NSDictionary *)dictionary;

/**
 将JSON对象的各字段映射到Model的各个字段
 **/
- (BOOL)yy_modelSetWithJSON:(id)json;

/**
 将NSDictionary的各字段映射到Model的各个字段
 **/
- (BOOL)yy_modelSetWithDictionary:(NSDictionary *)dic;

/**
 根据Model创建JSON对象
 **/
- (nullable id)yy_modelToJSONObject;

/**
 根据Model创建NSData的JSON数据
 **/
- (nullable NSData *)yy_modelToJSONData;

/**
 根据Model创建JSON字符串
 **/
- (nullable NSString *)yy_modelToJSONString;


/**
 复制Model
 **/
- (nullable id)yy_modelCopy;

/**
 对Model进行归档
 **/
- (void)yy_modelEncodeWithCoder:(NSCoder *)aCoder;

/**
 对Model进行解档
 **/
- (id)yy_modelInitWithCoder:(NSCoder *)aDecoder;

/**
获取model的hash值
 **/
- (NSUInteger)yy_modelHash;

/**
 判断Model是否一样
 **/
- (BOOL)yy_modelIsEqual:(id)model;

/**
 输出Model的相关信息
 **/
- (NSString *)yy_modelDescription;

@end



/**
 Provide some data-model method for NSArray.
 */
@interface NSArray (YYModel)

/**
 根据JSON创建Model数组
 **/
+ (nullable NSArray *)yy_modelArrayWithClass:(Class)cls json:(id)json;

@end



/**
 Provide some data-model method for NSDictionary.
 */
@interface NSDictionary (YYModel)

/**
 根据JSON的value和Class对象创建Model,并创建一个新字典，
 取json的key作为key，取Model作为value
 
 eg:
 
**/
+ (nullable NSDictionary *)yy_modelDictionaryWithClass:(Class)cls json:(id)json;
@end



/**
 If the default model transform does not fit to your model class, implement one or
 more method in this protocol to change the default key-value transform process.
 There's no need to add '<YYModel>' to your class header.
 */
@protocol YYModel <NSObject>
@optional

/**
 Custom property mapper.
 
 @discussion If the key in JSON/Dictionary does not match to the model's property name,
 implements this method and returns the additional mapper.
 
 Example:
    
    json: 
        {
            "n":"Harry Pottery",
            "p": 256,
            "ext" : {
                "desc" : "A book written by J.K.Rowling."
            },
            "ID" : 100010
        }
 
    model:
        @interface YYBook : NSObject
        @property NSString *name;
        @property NSInteger page;
        @property NSString *desc;
        @property NSString *bookID;
        @end
        
        @implementation YYBook
        + (NSDictionary *)modelCustomPropertyMapper {
            return @{@"name"  : @"n",
                     @"page"  : @"p",
                     @"desc"  : @"ext.desc",
                     @"bookID": @[@"id", @"ID", @"book_id"]};
        }
        @end
 
 @return A custom mapper for properties.
 */
+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper;

/**
 The generic class mapper for container properties.
 
 @discussion If the property is a container object, such as NSArray/NSSet/NSDictionary,
 implements this method and returns a property->class mapper, tells which kind of 
 object will be add to the array/set/dictionary.
 
  Example:
        @class YYShadow, YYBorder, YYAttachment;
 
        @interface YYAttributes
        @property NSString *name;
        @property NSArray *shadows;
        @property NSSet *borders;
        @property NSDictionary *attachments;
        @end
 
        @implementation YYAttributes
        + (NSDictionary *)modelContainerPropertyGenericClass {
            return @{@"shadows" : [YYShadow class],
                     @"borders" : YYBorder.class,
                     @"attachments" : @"YYAttachment" };
        }
        @end
 
 @return A class mapper.
 */
+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass;

/**
 If you need to create instances of different classes during json->object transform,
 use the method to choose custom class based on dictionary data.
 
 @discussion If the model implements this method, it will be called to determine resulting class
 during `+modelWithJSON:`, `+modelWithDictionary:`, conveting object of properties of parent objects 
 (both singular and containers via `+modelContainerPropertyGenericClass`).
 
 Example:
        @class YYCircle, YYRectangle, YYLine;
 
        @implementation YYShape

        + (Class)modelCustomClassForDictionary:(NSDictionary*)dictionary {
            if (dictionary[@"radius"] != nil) {
                return [YYCircle class];
            } else if (dictionary[@"width"] != nil) {
                return [YYRectangle class];
            } else if (dictionary[@"y2"] != nil) {
                return [YYLine class];
            } else {
                return [self class];
            }
        }

        @end

 @param dictionary The json/kv dictionary.
 
 @return Class to create from this dictionary, `nil` to use current class.

 */
+ (nullable Class)modelCustomClassForDictionary:(NSDictionary *)dictionary;

/**
 All the properties in blacklist will be ignored in model transform process.
 Returns nil to ignore this feature.
 
 @return An array of property's name.
 */
+ (nullable NSArray<NSString *> *)modelPropertyBlacklist;

/**
 If a property is not in the whitelist, it will be ignored in model transform process.
 Returns nil to ignore this feature.
 
 @return An array of property's name.
 */
+ (nullable NSArray<NSString *> *)modelPropertyWhitelist;

/**
 This method's behavior is similar to `- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;`, 
 but be called before the model transform.
 
 @discussion If the model implements this method, it will be called before
 `+modelWithJSON:`, `+modelWithDictionary:`, `-modelSetWithJSON:` and `-modelSetWithDictionary:`.
 If this method returns nil, the transform process will ignore this model.
 
 @param dic  The json/kv dictionary.
 
 @return Returns the modified dictionary, or nil to ignore this model.
 */
- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dic;

/**
 If the default json-to-model transform does not fit to your model object, implement
 this method to do additional process. You can also use this method to validate the 
 model's properties.
 
 @discussion If the model implements this method, it will be called at the end of
 `+modelWithJSON:`, `+modelWithDictionary:`, `-modelSetWithJSON:` and `-modelSetWithDictionary:`.
 If this method returns NO, the transform process will ignore this model.
 
 @param dic  The json/kv dictionary.
 
 @return Returns YES if the model is valid, or NO to ignore this model.
 */
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic;

/**
 If the default model-to-json transform does not fit to your model class, implement
 this method to do additional process. You can also use this method to validate the
 json dictionary.
 
 @discussion If the model implements this method, it will be called at the end of
 `-modelToJSONObject` and `-modelToJSONString`.
 If this method returns NO, the transform process will ignore this json dictionary.
 
 @param dic  The json dictionary.
 
 @return Returns YES if the model is valid, or NO to ignore this model.
 */
- (BOOL)modelCustomTransformToDictionary:(NSMutableDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
