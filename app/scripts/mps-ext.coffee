###--------------------------------------
[mps:EXT] Client-Side MPS Load + Execute
--------------------------------------###

'use strict'

mps = mps||{}
debugmode=debugmode||{}
mpscall=mpscall||{}
mpsopts=mpsopts||{}
mpsinstance=mpsinstance||false
mps._ext={
	'_p':{},
	'loaded':0,
	'loadheader':0,
	'loadfooter':0,
	'nowrite':0,
	#'nowrite':'<?php print !empty($vars['nowrite']) ? $vars['nowrite'] : 0 ?>',
	'_insertedads':[],
	'_jq':((typeof(jQuery)=='function')?1:0)
};
mpsopts.callback = mpsopts.callback || 'mpsCallback'
mpsopts.catprefix = mpsopts.catprefix || ''
mpsopts.deriveparams = mpsopts.deriveparams || {1:'cat1',2:'cat2',3:'cat3',4:'cat4',5:'cat5',6:'cat6'}
mpsopts.deriveoff = if mpsopts.deriveoff then true else false
mpsopts.maxcats = mpsopts.maxcats || 6
mpsopts.updatecorrelator = mpsopts.updatecorrelator || false
mpsopts.maxpathsegs = mpsopts.maxpathsegs || 4
mpsopts.subset = mpsopts.subset || mpsopts.subset || false
mpsopts.skipheader = if typeof(mpsopts.skipheader)=='undefined'||mpsopts.skipheader!=1 then 0 else 1
mpsopts.legacyqueues= if typeof(mpsopts.legacyqueues)=='undefined' then 1 else mpsopts.legacyqueues
mps._ext._set = mps._ext._set || -1
mps._reqs = mps._reqs || {}
mps._queue = mps._queue || {}
mps._queue.gptloadset=mps._queue.gptloadset||{}
mps._queue.mpsloaded = mps._queue.mpsloaded || []
mps._queue.gptloaded = mps._queue.gptloaded || []
mps._queue.mpsinit = mps._queue.mpsinit || []
mps._queue.adload = mps._queue.adload || []
mps._queue.refreshads = mps._queue.refreshads || []
mps._queue.lazyload = mps._queue.lazyload || []
mps._queue.setrails = mps._queue.setrails || []
mps._queue.adshow = mps._queue.adshow || []
mps._queue.adhide = mps._queue.adhide || []
mps._queue.gptloadset[0]=mps._queue.gptloadset[0]||[]
mps._ext._ = mps._loadset || 0
mps._reqset = mps._reqset || 0
mps._gptloaded=false
isMPS = true

#<?php if(!($mpstoolsjs = @file_get_contents(DOCROOT.'js/internal/mpstools.js'))) $mpstoolsjs = 'mps._log("[mps/Loader] FAILED TO LOAD mpstools.js INTO RESPONSE");'; print $mpstoolsjs; ?>
if !mps._loadset
	mps._queue.exec = (args) ->
		if typeof(args) == 'function'
			args.call()

	mps._queue['mpsinit'].push = ->
		if mps._ext && mps._ext.loaded == 1
			mps._queue.exec(arguments[0]);
		return Array.prototype.push.apply(this,arguments);

	if typeof(mps._queue.gptloaded.length) != 'undefined'
		i = 0
		while i < mps._queue.gptloaded.length
		  mps._queue.gptloadset[0].push(mps._queue.gptloaded[i]);
		  i++
		mps._queue.gptloaded=[];

	mps._queue['gptloaded'].push = ->
		if arguments[0]
			if mpsopts.legacyqueues == 1
				gptLoadset = mps._reqset
			else
				gptLoadset = mps._reqset + 1
			mps._queue.gptloadset[gptLoadset] = mps._queue.gptloadset[gptLoadset]||[]
			mps._queue.gptloadset[gptLoadset].push(arguments[0])
		return Array.prototype.push.apply(this)

	mps._queue.render = (type, slot, loadset) ->
		mps._debug('[mps/Loader] MPS QUEUE: (processing queue items) ' + type + ' ' + mps._elapsed());
		`var i`
		switch type
			when 'mps'
				i = 0
				while i < mps._queue.mpsinit.length
					mps._queue.mpsinit[i].call()
					i++
				if mps._queue.mpsloaded.length
					mps._queue.mpsloaded.shift().call()
			else
				i = 0
				while i < mps._queue[type].length
					if typeof (loadset == 'number') then mps._queue[type][i].call(this, slot, loadset) else mps._queue[type][i].call(this, slot)
					i++
				break

		mps._queue.clear = (type) ->
			if type
				mps._debug('[mps/Loader] MPS QUEUE: (clear ' + type + ')');
				if mps._queue[type] then mps._queue[type] = [] else mps._debug('[mps/Loader] MPS QUEUE: (clear ' + type + ') is not a valid queue.');
			else
				mps._debug('[mps/Loader] MPS QUEUE: (clear all)');
				for i of mps._queue
					if typeof mps._queue[i] == 'object' and i != 'mpsloaded'
						mps._queue[i] = []
###
mps._elapsed(); // Begin execution timer

mps._ext.mpsRequestParams = function(mpscall) {
	mps._debug('[mps/Loader] mpsRequestParams()');
	//(paths) mps._ext._pathsegs
	sitepath = mpscall.path || window.location.pathname;
	if(sitepath!='' && sitepath!='/' && sitepath.indexOf('/') > -1) {
		if(sitepath.substr(-1)=='/') sitepath=sitepath.substr(0, sitepath.length-1);
		if(sitepath.substr(0,1)=='/') sitepath=sitepath.substr(1,sitepath.length-1);
		sitepatharr = sitepath.split('/');
		mps._ext._pathsegs=[];
		var cleanpatharr=[],cutpatharr=[];
		for (var i=0; i<sitepatharr.length; i++) {
			mps._ext._pathsegs[i+1] = sitepatharr[i];
			if(i < mpsopts.maxpathsegs) {
				cleanpatharr[i+1]= sitepatharr[i];
			} else {
				cutpatharr[i+1] = sitepatharr[i];
			}
		}
		cleanpath = cleanpatharr.join('/');
		mpscall.path = cleanpath;
	} else {
		mps._ext._pathsegs = (sitepath!='/' && sitepath!='') ? [undefined,sitepath] : [undefined]; 
		mpscall.path = sitepath;
	}
	var qs = window.location.search.substring(1).split('&'),qsv;
	mps._ext._qsparams={};
	for(var i=0; i<qs.length; i++){
		qsv = qs[i].split('=');
		if(typeof(qsv[1])!='undefined') mps._ext._qsparams[qsv[0]] = qsv[1];
	}
	return mpscall;
}

mps._ext.mpsDeriveParams = function() {
	derived={};
	if(mpsopts.deriveoff) return derived;
	mps._debug('[mps/Loader] EXECUTE mpsDeriveParams()');

	// Extract mpscall params using format defined in mpsopts.deriveparams
	if(typeof(mpsopts.deriveparams)=='object') {
		var catkeys=['cat1','cat2','cat3','cat4','cat5','cat6'], catstring='';
		for(var k in mpsopts.deriveparams) {
			if(isNaN(k)) { //qs
				if(typeof(mps._ext._qsparams[k])=='string') derived[mpsopts.deriveparams[k]] = mps._ext._qsparams[k];
			} else { //url
				if(typeof(mps._ext._pathsegs[k])=='string') derived[mpsopts.deriveparams[k]] = mps._ext._pathsegs[k];
			}
		}
		for (var i=0; i<catkeys.length; i++) {
			if(typeof(derived[catkeys[i]])=='string') {
				catstring+=derived[catkeys[i]].replace('|','~');
				delete(derived[catkeys[i]]);
			}
			catstring+='|';
		}
		derived.cat = mps._trim(catstring,'| ').replace('||','|~|');
		mps._debug('[mps/Loader] (derived params) '+JSON.stringify(derived));
	}
	return derived;
}

mps._ext.mpsQueryString = function(mpscall) {
	if(typeof(mpscall)!='object') return '';
	var mpscallenc='';
	for(var key in mpscall) {
		if(typeof(mpscall[key])=='object') {
			for(var keyk in mpscall[key]) {
				mpscall[key+'['+keyk+']'] = mpscall[key][keyk];
			}
			delete mpscall[key];
		}
	}
	for (var k in mpscall) {
		if(typeof(mpscall[k])!='undefined' && mpscall[k] != '') {
			// Truncate really long strings at 250 chars
			if(typeof(mpscall[k]=='string') && mpscall.length > 0) mpscall[k]=mps._trim(mpscall[k].substring(0,250));
			mpscallenc+=encodeURIComponent(k)+'='+encodeURIComponent(mpscall[k]) + '&';
		}
	}
	if(mpscallenc.substr(-1)=='&') mpscallenc = mpscallenc.substr(0, mpscallenc.length - 1);
	return mpscallenc;
}

mps._ext.mpsRequestUrl = function(LOADMODE) {
	if(typeof(mpscall)!='object') return '';
	if(typeof(LOADMODE)=='string') {
		mpscall.LOADMODE=LOADMODE;
	} else {
		delete mpscall.LOADMODE;
		LOADMODE='';
	}
	mpscall.NOLOAD='mpstools';
	<?php if(!empty($_REQUEST['IRSOURCE'])): ?>mpscall.IRSOURCE = '<?php print addslashes($_REQUEST['IRSOURCE']); ?>';<?php endif; ?>
	<?php if(!empty($vars['nowrite'])): ?>
		mpscall.ASYNC=1;
		mps._ext._async=1;
	<?php endif ?>
	mps.qs = mps._ext.mpsQueryString(mpscall);
	var subset = (typeof(mpsopts.subset)=='string' && mpsopts.subset.length>0) ? '/'+mpsopts.subset : '';
	mps.requesturl = mpsinstance + '/request/page/jsonp'+subset+'?CALLBACK=' + mpsopts.callback + '&'+ mps.qs;
	mps._debug('[mps/Loader] mpsRequestUrl('+LOADMODE+'): '+mps.requesturl);
	return mps.requesturl;
}

mps._ext.mpsOnReady = function(usejq) {
	mps._debug("[mps/Loader] CALLED mpsOnReady() "+mps._elapsed());
	usejq = (typeof(usejq)=='undefined'||usejq!=1) ? 0 : 1;
	if(mps._ext.loaded == 1 && mps._ext.loadfooter == 0) {
		if(usejq == 1) {
			mps._debug('[mps/Loader] No Footer Execution Detected - Attaching Footer (jquery)');
			jQuery('body').append(mps.response.pagevars.insert_bodyfooter);
			mps._ext.loadfooter=1;
		} else {
			mps._append(mps._select('body'),mps.response.pagevars.insert_bodyfooter);
			mps._debug('[mps/Loader] No Footer Execution Detected - Attaching Footer (non-jquery)');
		}
	}
	if(mps._ext.nowrite=="0") mps._ext.nowrite="2";
}

//--> SET REQUEST VARS & OPTS
mps._debug(($dM=(new Array(8).join('*')))+' [mps] Debug Mode: ('+debugmode.log+') '+$dM);
if(typeof(mpsopts.host)=='string'&&mpsopts.host.length>0) mpsinstance=mpsopts.host;
if(typeof(mpsinstance)!='string'||mpsinstance=='') mpsinstance='<?php print MPS_DOMAIN; ?>';

//--> JSONP CALLBACK
function mpsCallback(data) {
	mps._debug('[mps/Loader] JSONP Callback Execution '+mps._elapsed());
	if(typeof(data)=='object' && typeof(data.pagevars.insert_head)!='undefined' && typeof(data.pagevars.insert_head)!='undefined') { // TODO: More response validation
		mps.response = data;
		mps.adslothtml = {};
		if(typeof(mps)=='object' && typeof(mps.response)=='object' && typeof(mps.response.dart)=='object' && typeof(mps.response.dart.adunits)=='object') {
			for(var adunit in mps.response.dart.adunits) {
				mps.adslothtml[adunit] = mps.response.dart.adunits[adunit].data;
			}
		}
		mps._ext.loaded = 1;
		mps.executeInserts();
		//--> DOCUMENT READY EVENT HOOK
		if(typeof(jQuery)!='function') {
			mps._debug('[mps/Loader] NO JQUERY (using native js)');
			<?php if(empty($vars['nowrite'])): ?>
			<?php endif; ?>
			mps._ext._jq = 1;
			mps._ready(function(){
				mps._ext.mpsOnReady(0);
			});
		} else {
			mps._debug('[mps/Loader] JQUERY AVAILABLE');
			jQuery().ready(function() {
				mps._ext.mpsOnReady(1);
			});
		}
		mps._queue.render('mps');
		if(typeof(mps.initCallback)=='function') mps.initCallback();
	}
}

mps._ext.determineSlot = function(adunit) {
	if(typeof(adunit)=='string' && typeof(mps)=='object' && typeof(mps.adunit)=='object' && typeof(mps.response)=='object' && typeof(mps.response.dart)=='object' && typeof(mps.response.dart.adunits)=='object') {
		if(typeof(mps.response.dart.adunits[adunit])=='object' && typeof(mps.response.dart.adunits[adunit].data)!='undefined' && mps.response.dart.adunits[adunit].data!='') {
			return adunit;
		}
		// Determine whether to use slot name or regular name
		if(typeof(mps.adunits[adunit])=='string') {
			if(typeof(mps.response.dart.adunits[mps.adunits[adunit]])=='object' && typeof(mps.response.dart.adunits[mps.adunits[adunit]].data)!='undefined' && mps.response.dart.adunits[mps.adunits[adunit]].data!='') {
				return mps.adunits[adunit];
			}
			// Get other ad units that have same slot
			for(var i in mps.adunits) {
				if(mps.adunits[i] == mps.adunits[adunit]) {
					if(typeof(mps.response.dart.adunits[mps.adunits[i]])=='object' && typeof(mps.response.dart.adunits[i].data)!='undefined' && mps.response.dart.adunits[i].data!='') {
						return i;
					}
				}
			}
		}
	}
	return adunit;
}

//--> MPS PAGE FUNCTIONS
mps.getAd = function(adunit,_swap) {
	var _adunit = adunit;
	var adunit = mps._ext.determineSlot(adunit);
	if (_swap){
		for(var adunitname in mps.adunits){
			if(adunit == mps.adunits[adunitname]){
				adunit = adunitname;
				break;
			} else if (mps.adunits.hasOwnProperty(adunit)) {
				adunit = mps.adunits[adunit];
				break;
			}
		}
	}
	var adslothtml = '';
	var beenrequested = false;
	if(typeof(adunit)!='undefined' && typeof(mps)=='object' && typeof(mps.response)=='object' && typeof(mps.response.dart)=='object' && typeof(mps.response.dart.adunits)=='object' && typeof(mps.response.dart.adunits[adunit])=='object' && typeof(mps.response.dart.adunits[adunit].data)!='undefined') {
		if(mps._ext._insertedads.indexOf(adunit) >= 0) {
			beenrequested = true;
		} else {
			mps._ext._insertedads.push(adunit);
		}
		if(mps.response.dart.adunits[adunit].data != '') {
			adslothtml = mps.response.dart.adunits[adunit].data;
			//save mps._req adslot begin time
			if(mps.pagevars.dart_mode == 'legacy'){
				var adslotname = 'legacy';
			}else{
				var adslotname = mps.response.dart.adunits[adunit].data.split('data-mps-slot=');
				adslotname = adslotname[1].split('"')[1];
			}
			if(typeof mps._ext == 'object' && typeof mps._reqs == 'object') mps._reqs[mps._ext._set]['begin_'+adslotname] = mps._elapsed('',true);

			mps._debug("[mps/Loader] mps.getAd('"+_adunit+"')"+(beenrequested?' [already called for this load]':'')+" "+mps._elapsed());
		} else {
			mps._debug("[mps/Loader] mps.getAd('"+_adunit+"') SKIPPED: Disabled "+mps._elapsed());
			adslothtml = '<!--(mps.getAd) '+adunit+' disabled-->';
		}
	} else {
		if (_swap){
			adslothtml = '<!--(mps.getAd) '+adunit+' unavailable-->';
			mps._debug("[mps/Loader] mps.getAd('"+_adunit+"') SKIPPED: Unavailable "+mps._elapsed());
		} else {
			return mps.getAd(adunit,true);
		}
	}
	return adslothtml;
}

mps.getComponent = function(sid) {
	componentdata='';
	if(typeof(sid)!='undefined' && sid !='' && typeof(mps)=='object' && typeof(mps.response)=='object' && typeof(mps.response.components)=='object' && typeof(mps.response.components[sid])=='object' && typeof(mps.response.components[sid].data)!='undefined') {
		mps._debug('[mps/Loader] mps.getComponent() LOAD: '+sid);
		if(mps.response.components[sid].data != '') {
			componentdata = mps.response.components[sid].data;
		}
	} else {
		mps._debug('[mps/Loader] mps.getComponent() SKIP: '+sid);
	}
	return componentdata;
}

mps.targetingArray = function(str) {
	if(typeof(str)=='string'&&str.length) {
		_targetingArr = [],_tmpArr = [],map={},_str = str.split(';');
		for(var i=0;i<_str.length;i++) {
			if(_str[i].indexOf('=') > -1) {
				_kv = _str[i].split('=');
				_tmpArr.push(_kv);
			}
		}
		for(var i=0; i<_tmpArr.length; i++) {
			if(_tmpArr[i][0] in map) {
				map[_tmpArr[i][0]].push(_tmpArr[i][1]);
			} else {
				map[_tmpArr[i][0]] = [_tmpArr[i][1]];
			}
		}
		for(var k in map) {
			if(map[k].length > 1) {
				_targetingArr.push([k,map[k]]);
			} else {
				_targetingArr.push([k,map[k][0]]);
			}
		}
		return _targetingArr;
	}
	return false;
};

mps.targetingAppend = function(selector,adslot,targetingappend,disableDetect,newpath) {
	var _setTargeting = mps.targetingArray(targetingappend);
	if(mps && mps._ext && mpscall) {
		mps._ext.mpscalls = mps._ext.mpscalls||{};
		mps._ext.pagevars = mps._ext.pagevars||{};
		if(typeof(mps._ext.mpscalls[0])!='object') {
			mps._ext.mpscalls[0] = mps._clone(mpscall);
		}
		if(typeof(mps._ext.pagevars[0])!='object') {
			mps._ext.pagevars[0] = mps._clone(mps.pagevars);
		}
	}
	if(newpath) {
		mps._debug('[mps/Loader]: new path: ' + newpath + ' specified, mps.makeRequest()');
		mpscall['path'] = newpath;
		mpscall.READONLY = 1;
		mps.pagevars.path = newpath;
		if(_setTargeting) {
			if(!mps.pagevars.fields) {
				mps.pagevars.fields = {};
			}
			for(var i =0; i<_setTargeting.length; i++) {
				mpscall['field[' + _setTargeting[i][0] + ']'] = _setTargeting[i][1].toString();
				mps.pagevars.fields[_setTargeting[i][0]] = _setTargeting[i][1].toString();
			}
		}
		mps.makeRequest('more');
		var gptQueue = mps._reqset > mps._loadset ? mps._reqset : mps._loadset;
		mps._queue.gptloadset[gptQueue]=mps._queue.gptloadset[gptQueue]||[];
		mps._queue.gptloadset[gptQueue].push(function(){
			for(var i=0; i<_setTargeting.length; i++) {
				gpt[mps.advars[adslot]].setTargeting(_setTargeting[i][0], _setTargeting[i][1]);
			}
			mps.insertAd(selector, adslot, null, disableDetect);
		});
	} else {
		if(_setTargeting) {
			mps._debug('[mps/Loader]: set targeting and insertAd()');
			for(var i=0; i<_setTargeting.length; i++) {
				gpt[mps.advars[adslot]].setTargeting(_setTargeting[i][0], _setTargeting[i][1]);
			}
			mps.insertAd(selector, adslot, null, disableDetect);
		} else {
			mps._debug('[mps/Loader]: no path or targeting params specified, insertAd()');
			mps.insertAd(selector, adslot, null, disableDetect);
		}
	}
};
//--[Insert Ad Slot into Page] params: (obj) dom element, (str) ad slot name
mps.insertAd = function(selector,adslot,targetingappend,disableDetect,newpath){
	if(disableDetect && mps.lazyload && mps.lazyload[mps._loadset]) {
		mps._debug('[mps/Loader] insertAd disable detected display called on adslot: '+adslot);
		var detectIndex = mps.lazyload[mps._loadset].adslots.indexOf(adslot);
		if(detectIndex > -1) {
			mps.lazyload[mps._loadset].adslots.splice(detectIndex, 1);
		}
	}
	if(targetingappend && targetingappend.length || newpath) {
		mps.targetingAppend(selector,adslot,targetingappend,disableDetect,newpath);
		return false;
	}
	if(mps._gptloaded == false) {
		var gptQueue = mps._reqset > mps._loadset ? mps._reqset : mps._loadset;
		mps._queue.gptloadset[gptQueue]=mps._queue.gptloadset[gptQueue]||[];
		mps._queue.gptloadset[gptQueue].push(function(){ mps.insertAd(selector,adslot) });
		return true;
	}
	if(selector) {
		mps._debug('[mps/Loader] insertAd('+selector+','+adslot+') '+mps._elapsed());
		var adcode = mps.getAd(adslot);
		if(adcode) return mps._append(selector,adcode);
	}
	return false;
}

//--[Insert Component into Page] params: (obj) dom element, (str) service identifer
mps.insertComponent = function(selector,sid){
	var componentdata='';
	if(typeof(sid)!='undefined' && sid !='' && typeof(mps)=='object' && typeof(mps.response)=='object' && typeof(mps.response.components)=='object' && typeof(mps.response.components[sid])=='object' && typeof(mps.response.components[sid].data)!='undefined') {
		mps._debug('[mps/Loader] mps.getComponent() LOAD: '+sid);
		if(mps.response.components[sid].data != '' && !(selector)) {
			componentdata = mps.response.components[sid].data;
		} else if (mps.response.components[sid].data != '' && selector){
			componentdata = mps._append(selector,mps.response.components[sid].data);
		}
	} else {
		mps._debug('[mps/Loader] mps.getComponent() SKIP: '+sid);
	}
	return componentdata;
}

mps.writeFooter = function() {
	if(mps._ext.loaded==1 && typeof(mps.response.pagevars.insert_bodyfooter)=='string' && mps.response.pagevars.insert_bodyfooter.length>0) {
		mps._debug('[mps/Loader] mps.writeFooter LOAD');
		footerdata = mps.response.pagevars.insert_bodyfooter;
	} else {
		mps._debug('[mps/Loader] mps.writeFooter SKIP: Missing response or empty');
		footerdata = '';
	}
	mps._ext.loadfooter = 1;
	<?php if($vars['nowrite']!=1): ?>document.write(footerdata);<?php else: ?>mps._debug('[mps/Loader] mps.writeFooter SKIP: NO WRITE MODE'); return footerdata;<?php endif; ?>
};

mps.updateRequest = function() {

	mps._debug('[mps/Loader] update request.');

	googletag.cmd.push(function() {

		mps._gptloaded = false;

		googletag.pubads().enableAsyncRendering();

		// Reset page level targeting to pagevar values.
		googletag.pubads().setTargeting("pageid", mps.pagevars.cid);
		googletag.pubads().setTargeting("cont", "page");
		googletag.pubads().setTargeting("sect", mps.pagevars.cat);

		mps._loadset++;
		mps.adobs=[];
		mps.adslots={};
		mps.advars={};
		mps.adslothtml = {};
		mps._advarprefix = 'gpt';
		mps.responsiveslots=mps.responsiveslots||{};
		mps.responsiveslots[mps._loadset]={};
		mps._slotscalled[mps._loadset]={};
		mps._slotsdisabled[mps._loadset]={}
		mps.slotsdisabled[mps._loadset]=[];
		mps.slotsdisabled[mps._loadset] = mps.slotsdisabled[0];

		// Update dart response.
		var _adunits = mps.response.dart.adunits;
		for(var i in _adunits) {
			if(typeof(_adunits[i].data) === 'string' && _adunits[i].data.length > 0) {
				var _adunit = i;
				var _mpsid = mps.pagevars.mpsid;
				_adunits[i].data = _adunits[i].data.replace(/data-mps-loadset=\"([^\"]*)\"/,'data-mps-loadset="' + mps._reqset + '"');
				_adunits[i].data = _adunits[i].data.replace(/id=\"([^\"]*)\"/,'id="div-' + mps._advarprefix + '-' + _adunit + '-' + _mpsid + '-' + mps._reqset + '"');
			}
		}

		// Copy adslothtml.
		if(typeof(mps)=='object' && typeof(mps.response)=='object' && typeof(mps.response.dart)=='object' && typeof(mps.response.dart.adunits)=='object') {
			for(var adunit in mps.response.dart.adunits) {
				mps.adslothtml[adunit] = mps.response.dart.adunits[adunit].data;
			}
		}

		// Define googletag slots, set targeting and enable pubads.
		for(var i in mps._gptTargeting) {
			var _gptTargeting = mps._gptTargeting[i];
			if(_gptTargeting.gptid && _gptTargeting.sizes && _gptTargeting.gptdiv) {

				// Set targeting and define in GPT.
				var _gptKey = i.split('.');
				var _slotName = _gptKey[1].split('_');
				_gptKey = _gptKey[1] + '_' + mps._loadset;
				var _gptDiv = _gptTargeting.gptdiv + '-' + mps._loadset;

				gpt[_gptKey] = googletag.defineSlot(_gptTargeting.gptid, _gptTargeting.sizes, _gptDiv)
				.setTargeting("xyz","appendpage")
				.setTargeting("pos",_slotName[0])
				.setCollapseEmptyDiv(false);
				gpt[_gptKey].addService(googletag.pubads());

				// Update mps objects
				mps.adslots[_slotName[0]] = _gptDiv;
				mps.advars[_slotName[0]] = _gptKey;

			}
		}

		mps._adslots[mps._loadset] = mps.adslots;
		mps._advars[mps._loadset] = mps.advars;

		// Callbacks.
		mps._queue.render('mps');
		if(typeof(mps.initCallback)=='function') {
			googletag.cmd.push(function() { mps.initCallback(); });
		}
		mps._gptloadCallback();
	});
};

mps.makeRequest = function(loadmode, retry) {
	if(!retry && loadmode === 'more') {
		if(mps._reqset > mps._loadset || !mps._gptloaded) {
			mps._reqset++;
			mps._queue.mpsloaded.push(function() { mps.makeRequest('more', true) });
			return false;
		}
		mps._adslots[mps._reqset]=mps.adslots;
		mps._reqset++;
	}
	mps._ext.loaded=0; mps._ext.loadheader=0; mps._ext.loadfooter=0;mps._ext._insertedads=[]; mps._gptloaded = false;
	mps._ext.pagevars = mps._ext.pagevars||{};
	mps._ext.mpscalls = mps._ext.mpscalls||{};
	if(typeof(mps._ext.mpscalls[0])!='object') {
		mps._ext.mpscalls[0] = mps._clone(mpscall);
	}
	if(typeof(mps._ext.pagevars[0])!='object') {
		mps._ext.pagevars[0] = mps._clone(mps.pagevars);
	}
	var gptQueue = mps._loadset + 1;
	mps._queue.gptloadset[gptQueue]=mps._queue.gptloadset[gptQueue]||[];
	mps._queue.gptloadset[gptQueue].push(function() {
		mps._ext.pagevars[gptQueue] = mps._clone(mps.pagevars);
		mps.pagevars = mps._clone(mps._ext.pagevars[0]);
		mps._ext.mpscalls[gptQueue] = mps._clone(mpscall);
		mpscall = mps._ext.mpscalls[0];
	});

	var loadmode = (typeof(loadmode)=='string' && loadmode.length > 0) ? loadmode : '';
	<?php if (isset($_COOKIE["__overlay__"])) { ?>
		mps._debug("<span class='loadmore'>loadset:"+mps._reqset+"</span><p class='loadmore' title=''>[mps/Loader] mps.makeRequest("+loadmode+")</p>");
	<?php } ?>
	if(typeof(mps.requesturl)!='string' || mps.requesturl=='') return false;
	if(typeof(loadmode)=='string' && loadmode.length > 0) {
		if(loadmode=='more') {
			mpscall['ASYNC']=1;
			mpscall['_']=mps._loadset+1;
			mps._ext._async = true;
		}
		if((window.googletag && googletag.apiReady) && typeof(googletag.pubads)=='function' && (mpsopts.updatecorrelator === true || mpsopts.updatecorrelator ===1 ) || (mps._loadset && typeof(mpsopts.updatecorrelator)=='number' && ((mps._loadset+1) % mpsopts.updatecorrelator)===0)) {
			mps._debug('[mps/Loader] Refreshing Correlator');
			googletag.pubads().updateCorrelator();
		}
		// If no page values changed, refresh objects without a new request.
		if(mps._ext.pagevars[0].cid === mps.pagevars.cid && mps._ext.pagevars[0].cat === mps.pagevars.cat && mps._ext.pagevars[0].path === mps.pagevars.path) {
			mps.updateRequest();
			return false;
		}
	}
	delete(mps.response);
	mps.requesturl = mps._ext.mpsRequestUrl(loadmode);
	(function(){
		mps._ext._set++;
		mps._reqs[mps._ext._set] = {};
		var src = mps.requesturl;
		var loadscript = document.createElement('script');
		loadscript.async = true; loadscript.type = 'text/javascript';
		if(src.substring(0,4) == 'http' || src.substring(0,2) == '//') src.replace('http://','').replace('https://','').replace('//','');
			src = mps._protocol()+'//'+src;
			loadscript.src = src;
			loadscript.onload=function(){
			if(mps._ext && mps._reqs && mps._reqs[mps._ext._set]){
				mps._reqs[mps._ext._set]['mpsready'] = mps._elapsed('',true);
			}
		}
		var node = document.getElementsByTagName('script')[0];
		node.parentNode.insertBefore(loadscript, node);
	})();
};

mps.executeInserts = function() {
	if(typeof(mps)!='object' || typeof(mps.response)!='object') {
	mps._log('[mps/Loader] Failed executeInserts(): No MPS Response');
		return false;
	}
	if(mps._ext.nowrite=='0') {
		document.write(mps.response.pagevars.insert_head);
		if(mpsopts.headerskip != 1) {
			document.write(mps.response.pagevars.insert_bodyheader);
			mps._ext.loadheader = 1;
		}
		return true;
	} else {
		//@TODO Expand this capability for sites without jQuery
		if(typeof(jQuery)!='function') {
			mps._debug('[mps/Loader] executeInserts (non-jquery)');
			mps._append(mps._select('body'),mps.response.pagevars.insert_head);
			if(mpsopts.headerskip != 1) {
				mps._append(mps._select('body'),mps.response.pagevars.insert_bodyheader);
				mps._ext.loadheader = 1;
			}
		} else {
			mps._debug('[mps/Loader] executeInserts (jquery)');
			jQuery('head').append(mps.response.pagevars.insert_head);
			if(mpsopts.headerskip != 1) {
				jQuery('body').prepend(mps.response.pagevars.insert_bodyheader);
				mps._ext.loadheader = 1;
			}
		}
		return true;
	}
}

//--> BUILD MPS REQUEST VARS
mps._ext._p.defined = mps._ext.mpsRequestParams(mpscall);
mps._ext._p.defined.path = typeof(mps._ext._p.defined.path)!='undefined' ? mps._ext._p.defined.path : '~';
mps._ext._p.derived = mps._ext.mpsDeriveParams();
mpscall = mps._merge(mps._ext._p.derived,mps._ext._p.defined);
mps._debug('[mps/Loader] (merge params)'+JSON.stringify(mps._ext._p));

//--> VARIABLES FOR INCLUDE
if(typeof(mpscall.cat)=='string') {
	mpscall.cat = mps._trim(mpscall.cat,'| ');
	var cats = mpscall.cat.split('|'), lastcat = cats[cats.length-1];
} else {
	var cats = [], lastcat = undefined;
}

<?php #--MPS Autoloader Include Code
	if(!empty($vars['load_include_code'])) {
		print "//--> INCLUDE CODE [".$vars['site']."]\n".$vars['load_include_code']."\n\n";
	}
?>

mps._debug('[mps/Loader] (mpsopts) '+JSON.stringify(mpsopts));

//(cat) resplit cat string
mps._ext._cats = (typeof(mpscall.cat)=='string') ? mpscall.cat.split('|') : [];
lastcat = mps._ext._cats[mps._ext._cats.length-1];
//(cat) set depth limit on cat level
mpsopts.maxcats = (typeof(mpsopts.maxcats)=='string') ? parseInt(mpsopts.maxcats) : mpsopts.maxcats||0; 
if(mpsopts.maxcats > 0  && mps._ext._cats.length > mpsopts.maxcats) { 
	mps._ext._catscut = mps._ext._cats.splice(mpsopts.maxcats+1);
}
//(cat) remove last level if filename or numeric 
if(!isNaN(lastcat) || lastcat.lastIndexOf('.')>0 || lastcat.indexOf('index')===0) {
	mps._ext._cats.splice(mps._ext._cats.length-1,mps._ext._cats.length);
}
//(cat) attach prefix
mpsopts.catprefix = mps._trim(mpsopts.catprefix,'| ');
if(mpsopts.catprefix != '') {
	mps._ext._cats = mps._merge(mpsopts.catprefix.split('|'),mps._ext._cats);
}
//(cat) join and override existing value
mpscall.cat = mps._ext._cats.join('|');

mps._debug('[mps/Loader] (mpscall) ',JSON.stringify(mpscall));
if(parseInt(debugmode.log) == 2) mpscall.CACHESKIP=1;

//--> CREATE URL AND REQUEST
mps.requesturl = mps._ext.mpsRequestUrl();

<?php if(!empty($json_response)): ?>
	mps._ext._set+=1;
	mps._debug('[mps/Loader] LOAD (inline object)');
	mpsresponse = <?php print $json_response ?>;
	mpsCallback(mpsresponse);
<?php else: ?>
	if(mpsinstance!='' && mps.qs.length > 6) {
		<?php if(empty($vars['nowrite'])): ?>
			mps._debug('[mps/Loader] REQUEST+LOAD JSONP',mps._protocol()+'//'+mps.requesturl); mps._ext._set+=1; document.write('<scr'+'ipt id="mps-request-'+mps._loadset+'" src="'+mps._protocol()+'//'+mps.requesturl+'"></scr'+'ipt>');
			mps._reqs[mps._ext._set] = {'mpsready':mps._elapsed('',true)};
		<?php elseif($vars['nowrite']==1): ?>
			mps._debug('[mps/Loader] Skipped MPS Request')
		<?php else: ?>
			mps.makeRequest();
		<?php endif;?>
	}
	delete(mps.qs);
<?php endif; ?>

//--> BACKWARDS COMPATIBILITY
mpsGetAd=mps.getAd; mpsrequesturl=mps.requesturl; mps.writeHeader=function(){};
###