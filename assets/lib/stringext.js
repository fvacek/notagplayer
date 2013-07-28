console.debug("importing stringext.js");
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