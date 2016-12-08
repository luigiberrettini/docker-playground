const http = require("http");
const os = require("os");
http.createServer(function (req, res) {
    const interfaces = os.networkInterfaces();
    var addresses = "";
    for (var i in interfaces) {
        for (var j in interfaces[i]) {
            var ifDetails = interfaces[i][j];
            if (ifDetails.family === "IPv4" && ifDetails.internal == false) {
                addresses += ifDetails.address + " ";
            }
        }
    }
    res.writeHead(200, {"Content-Type": "text/plain"});
    res.write("SERVER_ADDR " + addresses + "\n");
    res.end();
}).listen(80);