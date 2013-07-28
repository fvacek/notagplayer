console.debug("importing globaldefs.js");
if(typeof __GLOBALDEFS_JS === "undefined") {
	var __GLOBALDEFS_JS = true;

	function stringext_init()
	{
		console.debug("stringext_init()");
		if (typeof String.prototype.startsWith !== 'function') {
			console.debug("creating stringext.startsWith");
		    String.prototype.startsWith = function(prefix) {
		        return this.lastIndexOf(prefix, 0) === 0;
		    }
		}

		if (typeof String.prototype.endsWith !== 'function') {
		    String.prototype.endsWith = function(suffix) {
		        return this.indexOf(suffix, this.length - suffix.length) !== -1;
		    }
		}

		if(!String.prototype.trim) {
			String.prototype.trim = function () {
			    return this.replace(/^\s+|\s+$/g,'');
			}
		}
	}
	
	console.debug("creating globaldefs.js");
	//Qt.include("stringext.js"); do not work, don't know why
	stringext_init();

	function splitPath(path)
	{
		var ret = path.split("/");
		if(ret.length && !ret[0].length) ret = ret.slice(1);
		if(ret.length && !ret[ret.length-1].length) ret = ret.slice(0, -1);
		
		return ret;
	}

	var accountsPath = "/accounts/1000/";
	var deviceSubPath = "shared/";
	var sdcardSubPath = "removable/sdcard/";
	var boxSubPath = "shared/Box/";
	var dropboxSubPath = "shared/Dropbox/";
	var deviceMusicPath = accountsPath + deviceSubPath + "music/";
	var sdcardMusicPath = accountsPath + sdcardSubPath + "music/";

	function decorateSystemPath(path)
	{
		//console.debug("decorateSystemPath: " + ret + " path: " + path);
		if(path) {
			var ret = path;
		    if(ret.startsWith(accountsPath)) {
		    	var schema = ""; 
		    	ret = ret.slice(accountsPath.length);
		        if(ret.startsWith(boxSubPath)) {
		        	ret = ret.slice(boxSubPath.length);
		        	schema = "Box";    
		        }
		        else if(ret.startsWith(dropboxSubPath)) {
		        	ret = ret.slice(dropboxSubPath.length);
		        	schema = "DropBox";    
		        }
		        else if(ret.startsWith(sdcardSubPath)) {
		        	ret = ret.slice(sdcardSubPath.length);
		        	schema = "sdcard";    
		        }
		        else if(ret.startsWith(deviceSubPath)) {
		        	ret = ret.slice(deviceSubPath.length);
		        	schema = "device";    
		        }
		        else {
		        	schema = "account";    
		        }
		        ret = schema + ":///" + ret;
		    }
		}
		else {
			var ret = "";
		}
	    /*
	    if(typeof ret != "string") {
	    	console.debug("decorateSystemPath error, path: " + path);
	    	ret = "error";
	    }
	    */
		//console.debug("decorateSystemPath: " + ret + " path: " + path);
	    return ret;
	}
}


