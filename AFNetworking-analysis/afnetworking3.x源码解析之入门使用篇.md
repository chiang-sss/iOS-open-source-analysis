#AFNetworking3.x源码解析之入门使用篇
-----------------------------------
##AFNetworking基本框架简介:
# 

	AFNetWorking目前是iOS开发者中使用最多的网络框架,目前使用最多的则是3.x版本，少数使用2.x
	3.x版本与2.x版本区别在于2.x版本是对NSURLConnection和NSURLSession的封装,iOS 9(AFN3.x版本)之后删除了	NSURLConnection的API的所有支持,完全基于NSURLSession 的API.
	
##AFNetworking网络请求流程图




##AFNetworking网络请求
# 
AFNetworking的GET请求示例

```

	AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                         @"text/json",
                                                         @"text/javascript",
                                                         @"text/html", nil];
                                                         /// 增加对text/html的支持
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@"chiang3s" forKey:@"username"];
    [parameters setObject:@"123456" forKey:@"password"];
    
    ///	AFNetworkingGetRequestUrl的网络请求地址，则百度随便搜一个api哈
    
    NSURLSessionDataTask *task = [manager GET:AFNetworkingGetRequestUrl
                                   parameters:parameters
                                     progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"downloadProgress:%@", downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject:%@", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@", error);
    }];
    
    [task resume];	/// 开始执行这个网络请求
```



