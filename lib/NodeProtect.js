Plugin = require("plugin.js");
path = require('path')

var filename = module.filename;
var name = filename.slice(filename.lastIndexOf(path.sep)+1, filename.length -3);
console.log('blueSecure plugin '+name+' started');    

process.stdin.resume();
process.stdin.setEncoding('utf8');

var data = "";

process.stdin.on('data', function(chunk) {
    data += chunk;
});

process.stdin.on('end', function() {
    var app = JSON.parse(data);
    //console.log (app);
    var info = process.env.VCAP_APPLICATION;    
    if (info) {
        info = JSON.parse(info);
        app.appId = info.application_id;
        app.uris = info.uris;
    }
    app.platform = "NodeJS";
	testEmitter  = new Plugin.Emitter (app.url, 'image/pkg');
    
    //console.log(JSON.stringify(result));
	testEmitter.memo(app);
});
