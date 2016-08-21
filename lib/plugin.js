var request = require('request');

function Receiver(srv, rp, memos_cb, rp_type) {
	var me = this;	
        if (!rp_type) rp_type = 'RP';
	var firstMemo = 0;
	var url = srv+'/v1/'+rp_type+'/'+rp;
	this.maxMemos = 128;
	this.maxDelay = 30000;
	
	this.start = function() {
		me.stopped = false;
		function once() {
			if (!me.stopped) {
				me._get(once);
			}			
		}
		once();
	}
	
	this.stop = function() {
		me.stopped = true;
	}
	
	this._get = function (complete) {
		 console.log('This is the URL: ' + url);
		var req = {
			      url: url 
			    , method: 'GET'
			    , json: true
			    , headers: { 
			         'Content-Type': 'application/json'
			       , 'X-First': me.firstMemo
			       , 'X-Last':  me.firstMemo + me.maxMemos - 1
			       , 'X-Delay': me.maxDelay
			      }
			}
                console.log(url);
		request(req, function (error, resp, memo) {
			if (!error && resp.statusCode == 200) {
				var next = parseInt(resp.headers['x-next']);
				var sver = parseInt(resp.headers['x-sver']);
					if (sver != me.sver) {
						me.sver = sver;
						console.log('server restarted');
						me.firstMemo = 0;
						if (memos_cb) memos_cb();
					} else {
						if (!isNaN(next)) {
							me.firstMemo = next;
						}
						if (memos_cb) memos_cb(memo);
					}
		        	//console.log(memo);
			        complete();		        
		    } else {
                        console.log('request fail')
		    	if (error) console.log(error);
		    	else console.log(resp.statusCode);
		    	setTimeout(complete, 30000);
		    }
		});
	}

} 

function Emitter(srv, rp) {
	var url = srv+'/v1/RP/'+rp;
	this.memo = function (obj) {
		var req = {
			      url: url 
			    , method: 'PUT'
			    , json: obj
			    , headers: { 
			        	   'Content-Type': 'application/json'
			      }				
			}
		request(req, function (error, resp, body) {
                	if (error || resp.statusCode !== 200) {
		    	if (error) console.log(error);
		    	else console.log(resp.statusCode);
		    	return;
		    }
                    console.log('Success: ');
                    console.log(body);
	    	//console.log('Emitter success'); 
		});
	}
}


function Enforcer(srv, rp) {
	var url = srv+'/v1/ERP/'+rp;
	this.clear = function (sid) {
		var req = {
			      url: url 
			    , method: 'DELETE'
			    , headers: { 
			         'X-Sid': sid
                               }
			}
		request(req, function (error, resp, body) {
			if (error || resp.statusCode !== 200) {
		    	if (error) console.log(error);
		    	else console.log(resp.statusCode);
		    	return;
		    }
	    	//console.log('Emitter success'); 
		});
	}
	this.memo = function (obj) {
		var req = {
			      url: url 
			    , method: 'PUT'
			    , json: obj
			    , headers: { 
			        	   'Content-Type': 'application/json'
			      }				
			}
		request(req, function (error, resp, body) {
			if (error || resp.statusCode !== 200) {
		    	if (error) console.log(error);
		    	else console.log(resp.statusCode);
		    	return;
		    }
	    	//console.log('Emitter success'); 
		});
	}
}
function Reporter(srv, rp) {
	var url = srv+'/v1/RRP/'+rp;
	this.memo = function (obj) {
		var req = {
			      url: url 
			    , method: 'PUT'
			    , json: obj
			    , headers: { 
			        	   'Content-Type': 'application/json'
			      }				
			}
		request(req, function (error, resp, body) {
		    if (error || resp.statusCode !== 200) {
		    	if (error) console.log(error);
		    	else console.log(resp.statusCode);
		    	return;
		    }
		});
	}
}


module.exports = {
			  Emitter:Emitter
			, Receiver:Receiver
			, Reporter:Reporter
			, Enforcer:Enforcer
		};
