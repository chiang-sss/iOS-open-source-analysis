const http = require("http");


const server = http.createServer((request, response) => {
             
    // console.log(request);

	response.writeHead(200, {
        "content-type" : "text/html;charset=utf-8"
    });
    // response.write("这是测试页面的数据" + new Date().toLocaleString());
    response.write("这是测试页面的数据");
    response.end();
});

server.listen("8090");
