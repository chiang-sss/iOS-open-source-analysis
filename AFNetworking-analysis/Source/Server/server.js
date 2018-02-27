const http = require("http");
const url = require("url");
const util = require("util");


const server = http.createServer((request, response) => {
          
    response.writeHead(200, {
        "content-type" : "text/html;charset=utf-8"
    });
    if (request.url == '/favicon.ico') {
        response.write("");
        response.end();
        return;
    }


    console.log("--------------------------   请求路径  --------------------------");
    console.log("\n");
    console.log("url: " + request.url);
    console.log("method: " + request.method);
    console.log("---------------------------------------------------------------");

    console.log("--------------------------   请求头  --------------------------");
    console.log("\n");
    const date = new Date().toLocaleDateString();
    console.log("--------------------------   请求时间 " + date + "--------------------------");

    console.log("\n");
    console.log(request.headers);
    console.log("\n");

    console.log("---------------------------------------------------------------");


    console.log("--------------------------   请求体  --------------------------");
    console.log("\n");

    var params = url.parse(request.url, true).query;
    console.log("\n name:" + params.username);
    console.log("\n url:" + params.password);
    console.log("\n");

    console.log("---------------------------------------------------------------");

    response.write("{\"data\":1}");
    response.end();
});

server.listen("8090");
