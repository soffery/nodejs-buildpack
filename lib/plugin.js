var request = require('request');
var fs = require('fs');


function Receiver(srv, rp, memos_cb, sid, rp_type) {
	var me = this;	
        if (!rp_type) rp_type = 'RP';
	var firstMemo = 0;
	var url = srv+'/v1/'+rp_type+'/'+rp;
	this.maxMemos = 128;
	this.maxDelay = 30000;
        this.limit = 32;
	
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
		var req = {
			      url: url 
			    , method: 'GET'
			    , json: true
			    , headers: { 
			         'Content-Type': 'application/json'
			       , 'X-Limit': me.limit
			       , 'X-First': me.firstMemo
			       , 'X-Last':  me.firstMemo + me.maxMemos - 1
			       , 'X-Delay': me.maxDelay
			      }
			}
                if (sid) req.headers['X-Sid'] = sid;
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

function SidReceiver(srv, rp, sid, memos_cb, rp_type) {
	var me = this;	
        if (!rp_type) rp_type = 'RP';
	var url = srv+'/v1/'+rp_type+'/'+rp;
	this.maxDelay = 30000;
        this.limit = 16;
	
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
		var req = {
			      url: url 
			    , method: 'GET'
			    , json: true
			    , headers: { 
			         'Content-Type': 'application/json'
			       , 'X-Sid': sid
			       , 'X-Limit': me.limit
			       , 'X-Delay': me.maxDelay
			      }
			}
                console.log(url);
		request(req, function (error, resp, memo) {
			if (!error && resp.statusCode == 200) {
				var sver = parseInt(resp.headers['x-sver']);
                                if (sver != me.sver) {
                                    me.sver = sver;
                                    console.log('server restarted');
                                    if (memos_cb) memos_cb();
                                } else {
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
	var me = this;	
	var filename = module.filename;
	var defenderDir = filename.slice(0,filename.lastIndexOf(path.sep)+1 );
	

	var url = srv+'/v1/RP/'+rp;
	this.maxDelay = 3000;
	this.memo = function (obj) {
		var req = {
			      url: url 
			    , method: 'PUT'
			    , json: obj
			    , headers: { 
			         'Content-Type': 'application/json'
			       , 'X-Delay': me.maxDelay
			      }				
			}
		request(req, function (error, resp, body) {
            if (error) {
				if (error) console.log(error);
				else console.log(resp.statusCode);
				return;
			}
            
			if ( resp.statusCode > 199 && resp.statusCode < 300 ) {
				// randomly selecting user action - done for testing only
				var actAry = ["reinstall_packages","update_packages","undo_all_updates","undo_last_update"];
				var action = actAry [Math.floor((Math.random()*actAry.length))];
				console.log ( "This is the action "  + action);
				//selecting random action to test each time 
				body = { 
					sid: 'vJ763MqFy6t5Y1JuloUHLuSgtmJS0Wrh',
					pkgv_action: action,
					_id: 38
				};
				if ( !body ){
					// don't print anything here as this is the normal stage
					return; 
				}
				console.log('Emitter got body ' + resp.statusCode); 
				/* body example  
				{ 
					sid: 'vJ763MqFy6t5Y1JuloUHLuSgtmJS0Wrh',
					pkgv_action: 'undo_last_update',
					_id: 38
				}*/
				// NOTE - can add a check here aginst local machine sid file ,to see if it is 
				//       the correct sid - if not ignore the body.
				console.log("Got action " + JSON.stringify(body));
				if (!body.sid || !body.pkgv_action){
					return;
				}
				console.log(defenderDir + "action.txt");
				fs.writeFile(defenderDir + "action.txt", body.pkgv_action +"\n", function() {
					console.log('action.txt was written');
				});
			}
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
                   console.log(resp.statusCode);
                   console.log(body);
		   if (error) console.log(error);
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
			, SidReceiver:SidReceiver
			, Reporter:Reporter
			, Enforcer:Enforcer
		};
