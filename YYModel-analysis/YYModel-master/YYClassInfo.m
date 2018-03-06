//
//  YYClassInfo.m
//  YYModel <https://github.com/ibireme/YYModel>
//
//  Created by ibireme on 15/5/9.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "YYClassInfo.h"
#import <objc/runtime.h>


/**
 
 通过指定类型编码字符串，返回类型编码字符串中Foundation Framework
 编码字符和method encodings编码字符
 
 **/
YYEncodingType YYEncodingGetType(const char *typeEncoding) {
    
    
    char *type = (char *)typeEncoding;
    /// type为空,则代表未知编码格式
    if (!type) return YYEncodingTypeUnknown;
    
    size_t len = strlen(type);
    
    /// type长度为0,则代表未知编码格式
    if (len == 0) return YYEncodingTypeUnknown;
    
    YYEncodingType qualifier = 0;
    
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= YYEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= YYEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= YYEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= YYEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= YYEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= YYEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= YYEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }

    len = strlen(type);
//    是否还存在后续的字符
    if (len == 0) return YYEncodingTypeUnknown | qualifier;

    /**
     
      int        : i
      float      : f
      float *    : ^f
      char       : c
      char *     : *
      BOOL       : B
      void       : v
      void *     : ^v
      NSObject * : @
      NSObject   : {NSObject=#}
      [NSObject] : #
      NSError ** : ^@
      int[]      : [5i]
      float[]    : [3f]
      struct     : {_struct=sqQ}
     
     **/
    switch (*type) {
        case 'v': return YYEncodingTypeVoid | qualifier;
        case 'B': return YYEncodingTypeBool | qualifier;
        case 'c': return YYEncodingTypeInt8 | qualifier;
        case 'C': return YYEncodingTypeUInt8 | qualifier;
        case 's': return YYEncodingTypeInt16 | qualifier;
        case 'S': return YYEncodingTypeUInt16 | qualifier;
        case 'i': return YYEncodingTypeInt32 | qualifier;
        case 'I': return YYEncodingTypeUInt32 | qualifier;
        case 'l': return YYEncodingTypeInt32 | qualifier;
        case 'L': return YYEncodingTypeUInt32 | qualifier;
        case 'q': return YYEncodingTypeInt64 | qualifier;
        case 'Q': return YYEncodingTypeUInt64 | qualifier;
        case 'f': return YYEncodingTypeFloat | qualifier;
        case 'd': return YYEncodingTypeDouble | qualifier;
        case 'D': return YYEncodingTypeLongDouble | qualifier;
        case '#': return YYEncodingTypeClass | qualifier;
        case ':': return YYEncodingTypeSEL | qualifier;
        case '*': return YYEncodingTypeCString | qualifier;
        case '^': return YYEncodingTypePointer | qualifier;
        case '[': return YYEncodingTypeCArray | qualifier;
        case '(': return YYEncodingTypeUnion | qualifier;
        case '{': return YYEncodingTypeStruct | qualifier;
        case '@': {
            /// 特殊判断
            if (len == 2 && *(type + 1) == '?')
                return YYEncodingTypeBlock | qualifier;
            else
                return YYEncodingTypeObject | qualifier;
        }
        default: return YYEncodingTypeUnknown | qualifier;
    }
}



//////////////////////////////////////////////////       YYClassIvarInfo        //////////////////////////////////////////////////
@implementation YYClassIvarInfo

- (instancetype)initWithIvar:(Ivar)ivar {
    if (!ivar) return nil;
    
    self = [super init];
    
    _ivar = ivar;
    
    ///  获取成员变量的名称
    const char *name = ivar_getName(ivar);
    
    if (name) {
        /// 把c的字符串转化成oc的字符串
        _name = [NSString stringWithUTF8String:name];
        
    }
    ///  获取偏移量
    _offset = ivar_getOffset(ivar);
    
    const char *typeEncoding = ivar_getTypeEncoding(ivar);
    
    if (typeEncoding) {
        /// 转为oc的字符串
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        ///  转成枚举类型，方便后期判断
        _type = YYEncodingGetType(typeEncoding);
    }
    return self;
}

@end

//////////////////////////////////////////////////       YYClassMethodInfo        //////////////////////////////////////////////////

@implementation YYClassMethodInfo

- (instancetype)initWithMethod:(Method)method {
    
    if (!method) return nil;
    self = [super init];
    
    _method = method;
    
    
    /// Method获取方法的名称
    _sel = method_getName(method);
    
    /// 方法的实现地址
    _imp = method_getImplementation(method);
    
    /// SEL 获取方法名
    const char *name = sel_getName(_sel);
    
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    /// 获取类型
    const char *typeEncoding = method_getTypeEncoding(method);
    if (typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
    }
    
    /// 获取返回值类型
    char *returnType = method_copyReturnType(method);
    if (returnType) {
        _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
        
        /// 但凡 通过copy retain alloc 系统方法得到的内存，必须使用relea() 或 free() 进行释放
        free(returnType);
    }
    
    unsigned int argumentCount = method_getNumberOfArguments(method);
    
    if (argumentCount > 0) {
        
        NSMutableArray *argumentTypes = [NSMutableArray new];
        
        for (unsigned int i = 0; i < argumentCount; i++) {
            /// 获取参数中的某一个参数
            char *argumentType = method_copyArgumentType(method, i);
            
            NSString *type = argumentType ? [NSString stringWithUTF8String:argumentType] : nil;
            [argumentTypes addObject:type ? type : @""];
            if (argumentType) free(argumentType);
        }
        _argumentTypeEncodings = argumentTypes;
    }
    return self;
}

@end


//////////////////////////////////////////////////       YYClassPropertyInfo        //////////////////////////////////////////////////

@implementation YYClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) return nil;
    self = [super init];
    
    _property = property;
    
    /// 获取属性名称
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    /// 获取每一个属性的编码字符串
    YYEncodingType type = 0;
    
    unsigned int attrCount;
    
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    
    ///  编译每一个属性的 objc_property_attribute_t
    for (unsigned int i = 0; i < attrCount; i++) {
        
        /// 根据objc_property_attribute_t 中的name 判断是什么类型，执行相应的方法
        switch (attrs[i].name[0]) {
                
                /// T 代表 属性的类型编码
            case 'T': { // Type encoding
                if (attrs[i].value) {
                    
                    _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                    type = YYEncodingGetType(attrs[i].value);
                    
                    if ((type & YYEncodingTypeMask) == YYEncodingTypeObject && _typeEncoding.length) {
                        NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                        if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                        
                        NSString *clsName = nil;
                        if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                            if (clsName.length) _cls = objc_getClass(clsName.UTF8String);
                        }
                        
                        NSMutableArray *protocols = nil;
                        while ([scanner scanString:@"<" intoString:NULL]) {
                            NSString* protocol = nil;
                            if ([scanner scanUpToString:@">" intoString: &protocol]) {
                                if (protocol.length) {
                                    if (!protocols) protocols = [NSMutableArray new];
                                    [protocols addObject:protocol];
                                }
                            }
                            [scanner scanString:@">" intoString:NULL];
                        }
                        _protocols = protocols;
                    }
                }
            } break;
                
            case 'V': { // Instance variable
                if (attrs[i].value) {
                    _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
                
            case 'R': {
                type |= YYEncodingTypePropertyReadonly;
            } break;
                
            case 'C': {
                /// Copy修饰
                type |= YYEncodingTypePropertyCopy;
            } break;
                
            case '&': {
                type |= YYEncodingTypePropertyRetain;
            } break;
                
            case 'N': {
                
                type |= YYEncodingTypePropertyNonatomic;
            } break;
                
            case 'D': {
                
                type |= YYEncodingTypePropertyDynamic;
            } break;
                
            case 'W': {
                /// Weak修饰
                type |= YYEncodingTypePropertyWeak;
            } break;
                
            case 'G': {
                /// Getter方法
                type |= YYEncodingTypePropertyCustomGetter;
                if (attrs[i].value) {
                    _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } break;
                
            case 'S': {
                /// Setter方法
                type |= YYEncodingTypePropertyCustomSetter;
                if (attrs[i].value) {
                    _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } // break; commented for code coverage in next line
            default: break;
        }
    }
    
    if (attrs) {    /// 释放
        free(attrs);
        attrs = NULL;
    }
    
    _type = type;
    
    if (_name.length) {
        
        if (!_getter) { /// 把 geeter 转成 SEL
            _getter = NSSelectorFromString(_name);
        }
        
        if (!_setter) { /// 把 setter 转成 SEL
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
        }
    }
    return self;
}

@end

//////////////////////////////////////////////////       YYClassInfo        //////////////////////////////////////////////////

@implementation YYClassInfo {
    BOOL _needUpdate;
}

- (instancetype)initWithClass:(Class)cls {
    if (!cls) return nil;
    self = [super init];
    _cls = cls;
    _superCls = class_getSuperclass(cls);
    _isMeta = class_isMetaClass(cls);
    
    if (!_isMeta) {
        _metaCls = objc_getMetaClass(class_getName(cls));
    }
    
    _name = NSStringFromClass(cls);
    [self _update];

    _superClassInfo = [self.class classInfoWithClass:_superCls];
    return self;
}

- (void)_update {
    
    _ivarInfos = nil;
    _methodInfos = nil;
    _propertyInfos = nil;
    
    Class cls = self.cls;
    
    /// 获取所有的方法
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(cls, &methodCount);
    if (methods) {
        NSMutableDictionary *methodInfos = [NSMutableDictionary new];
        _methodInfos = methodInfos;
        for (unsigned int i = 0; i < methodCount; i++) {
            YYClassMethodInfo *info = [[YYClassMethodInfo alloc] initWithMethod:methods[i]];
            if (info.name) methodInfos[info.name] = info;
        }
        free(methods);
    }
    
    /// 获取所有的属性
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
    if (properties) {
        NSMutableDictionary *propertyInfos = [NSMutableDictionary new];
        _propertyInfos = propertyInfos;
        for (unsigned int i = 0; i < propertyCount; i++) {
            YYClassPropertyInfo *info = [[YYClassPropertyInfo alloc] initWithProperty:properties[i]];
            if (info.name) propertyInfos[info.name] = info;
        }
        free(properties);
    }
    
    /// 获取所有的Ivar
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &ivarCount);
    if (ivars) {
        NSMutableDictionary *ivarInfos = [NSMutableDictionary new];
        _ivarInfos = ivarInfos;
        for (unsigned int i = 0; i < ivarCount; i++) {
            YYClassIvarInfo *info = [[YYClassIvarInfo alloc] initWithIvar:ivars[i]];
            if (info.name) ivarInfos[info.name] = info;
        }
        free(ivars);
    }
    
    /// 如果Ivar,method,property等都没有或者没有获取到，则在这里赋空数组
    if (!_ivarInfos) _ivarInfos = @{};
    if (!_methodInfos) _methodInfos = @{};
    if (!_propertyInfos) _propertyInfos = @{};
    
    _needUpdate = NO;
}

- (void)setNeedUpdate {
    _needUpdate = YES;
}

- (BOOL)needUpdate {
    return _needUpdate;
}

+ (instancetype)classInfoWithClass:(Class)cls {
    
    ///  非空判断
    if (!cls) return nil;
    
    
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaCache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaCache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    YYClassInfo *info = CFDictionaryGetValue(class_isMetaClass(cls) ? metaCache : classCache, (__bridge const void *)(cls));
    if (info && info->_needUpdate) {
        [info _update];
    }
    dispatch_semaphore_signal(lock);
    if (!info) {
        info = [[YYClassInfo alloc] initWithClass:cls];
        if (info) {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(info.isMeta ? metaCache : classCache, (__bridge const void *)(cls), (__bridge const void *)(info));
            dispatch_semaphore_signal(lock);
        }
    }
    return info;
}

+ (instancetype)classInfoWithClassName:(NSString *)className {
    Class cls = NSClassFromString(className);
    return [self classInfoWithClass:cls];
}

@end
