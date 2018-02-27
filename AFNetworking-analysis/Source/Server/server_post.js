const http = require('http');
const common = require('./libs/common');
const fs = require('fs');
const url = require('url');

/** 
 * 这个是用来测试AFNetworking的文件提交的Server
 * 研究HTTP协议的传输规则
 * 打印请求头，请求体内容
 *  **/
let server = http.createServer((request, res)=>{
  let arr = [];

  request.on('data', data=>{
    arr.push(data);
  });
  request.on('end', ()=>{
    let data = Buffer.concat(arr);
    //data
    //解析二进制文件上传数据
    let post = {};
    let files = {};
    if (request.headers['content-type']){
      let str = request.headers['content-type'].split('; ')[1];
      if (str){
        let boundary = '--' + str.split('=')[1];
        //1.用"分隔符切分整个数据"
        let arr = data.split(boundary);
        //2.丢弃头尾两个数据
        arr.shift();
        arr.pop();

        //3.丢弃掉每个数据头尾的"\r\n"
        arr = arr.map(buffer => buffer.slice(2, buffer.length - 2));

        //4.每个数据在第一个"\r\n\r\n"处切成两半
        

        // console.log("--------------------------   请求路径  --------------------------");
        // console.log("\n");
        // console.log("url: " + request.url);
        // console.log("method: " + request.method);
        // console.log("---------------------------------------------------------------");

        // console.log("--------------------------   请求头  --------------------------");
        // console.log("\n");
        // const date = new Date().toLocaleDateString();
        // console.log("--------------------------   请求时间 " + date + "--------------------------");

        // console.log("\n");
        // console.log(request.headers);
        // console.log("\n");

        // console.log("---------------------------------------------------------------");


        // console.log("--------------------------   请求参数  --------------------------");
        // console.log("\n");
        // console.log(post);
        // console.log("\n");

        // console.log("---------------------------------------------------------------");

        arr.forEach(buffer => {
          // console.log(buffer.toString('utf-8', 0, buffer.length));
          // return;
          
          let n = buffer.indexOf('\r\n\r\n');

          let disposition = buffer.slice(0, n);
          let content = buffer.slice(n + 4);

          disposition = disposition.toString();

          if (disposition.indexOf('\r\n')==-1){
            //普通数据
            //Content-Disposition: form-data; name="user"
            content = content.toString();

            let name = disposition.split('; ')[1].split('=')[1];
            name = name.substring(1, name.length-1);

            post[name] = content;
          } else {
            //文件数据
            /*
            Content-Disposition: form-data; name="f1"; filename="a.txt"\r\n
            Content-Type: text/plain
            */
           
            console.log("--------------------------   请求体的头  --------------------------");
            let [line1, line2, line3] = disposition.split('\r\n');
            console.log("\n" + line1);
            console.log("\n" + line2);
            console.log("---------------------------------------------------------------");
            
            console.log("--------------------------   请求体的数据内容  --------------------------");
            console.log("\n" + content.toString('base64', 0, content.length));
            console.log("---------------------------------------------------------------");

            let [,name,filename] = line1.split('; ');
            let type = line2.split(': ')[1];

            name = name.split('=')[1];
            name = name.substring(1,name.length-1);

            filename = filename.split('=')[1];
            filename = filename.substring(1,filename.length-1);

            let path = `upload/${filename}`;

            fs.writeFile(path, content, err => {
              if (err){
                console.log('文件写入失败', err);
              } else {

                files[name] = {filename, path, type};
                // console.log("files" + files);
                
                // console.log("--------------------------   上传文件内容  --------------------------");
                // console.log("\n");
                // console.log("\n filename:" + filename);
                // console.log("\n path:" + path);
                // console.log("\nContent-Type:" + type);
                
                // console.log("---------------------------------------------------------------");
              }
            });
          }
        });
      }
    }
    res.end();
  });
});
server.listen(8090);
