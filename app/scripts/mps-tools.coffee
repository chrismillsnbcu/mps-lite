# MPS Tools.

'use strict'
mps=mps||{}
debugmode=debugmode||{}
debugmode.log&&window.console||(debugmode.log=0)
mps.debugMsg = []

#--[Ad DOM Object] Return DOM selector using slot name.
mps.selectAd = (adunit) ->
	if(typeof(adunit) != 'undefined' && adunit != '' && typeof(mps) == 'object' && typeof(mps.advars)!='undefined' && typeof(mps.adslots[adunit])!='undefined' && typeof(mps._select) == 'function' && (adselect=mps._select('#'+mps.adslots[adunit])))
		return adselect
	else
		return false

#--[GPT Ad Object] Return Google ad object reference using the slot name.
mps.getSlot = (slotstr, loadset) ->
	_advars = mps.advars
	if parseInt(loadset) > -1
		if !mps._advars[loadset]
			return false
		_advars = mps._advars[loadset]
	if typeof slotstr != 'string'
		mps._debug 'mps.getSlot: param is not a string'
		return false
	if typeof _advars != 'object' or typeof _advars[slotstr] != 'string'
		mps._debug 'mps.getSlot: invalid slot name'
		return false
	if typeof mps._advarprefix != 'string' or typeof window[mps._advarprefix] != 'object'
		mps._debug 'mps.getSlot: invalid page gpt object'
		return false
	if typeof window[mps._advarprefix][_advars[slotstr]] != 'object'
		mps._debug 'mps.getSlot: failed to load slot object'
		return false
	window[mps._advarprefix][_advars[slotstr]]

#//--[Single DOM Object via Selector String] example strings: #id .class body.
mps._select = (selector) ->
	if typeof jQuery == 'function'
		return jQuery(selector)[0] or false
	# jQuery available
	if typeof selector != 'string' or selector.length < 2
		return false
	if typeof document.querySelectorAll == 'function' or typeof document.querySelectorAll == 'object'
		# Modern Browser
		return document.querySelectorAll(selector)[0] or false
	if selector.charAt(0) == '#'
		# Old Browser (func by first char)
		top.document.getElementById(selector.substr(1)) or false
	else if selector.charAt(0) == '.'
		top.document.getElementsByClassName(selector.substr(1))[0] or false
	else
		top.document.getElementsByTagName(selector)[0] or false

#--[Insert HTML into Selector] mps._append (obj)domelement,(str)html.
mps._append = (selector, d) ->
	if typeof selector == 'string'
		selector = mps._select(selector)
	if typeof selector != 'object' or typeof d != 'string'
		mps._debug 'mps._append() invalid parameters'
		return false
	if typeof jQuery == 'function'
		return jQuery(selector).append(d) or false
	# jQuery available
	content = d
	content = Array::concat([], content)
	if content.length
		frag = document.createDocumentFragment()
		tmp = frag.appendChild(document.createElement('div'))
		tmp.innerHTML = 'X' + content
		scripts = tmp.getElementsByTagName('script')
		# Append html.
		if selector
			selector.insertAdjacentHTML 'beforeend', content
		else
			mps._log 'Invalid selector provided.'
		i = 0
		while i < scripts.length
			newScript = document.createElement('script')
			if scripts[i].id
				newScript.id = scripts[i].id
			if scripts[i].src
				newScript.type = 'text/javascript'
				newScript.src = scripts[i].src
				document.getElementsByTagName('head')[0].appendChild newScript
			else
				nscript = document.createElement('script')
				js = scripts[i].innerHTML
				nscript.type = 'text/javascript'
				nscript.text = js
				document.getElementsByTagName('head')[0].appendChild(nscript).parentNode.removeChild nscript
			i++
	return


#--[Remove Selector(s) from DOM] mps._remove (obj.
mps._remove = (elem) ->
	if !elem
		mps._log 'Invalid selector provided.'
		return false
	# jQuery available
	if typeof jQuery == 'function'
		if jQuery(elem).length > 0
			jQuery(elem).remove()
			return false
		else
			mps._log 'Invalid selector provided.'
			return false
	# querySelectorAll, getElementsByClassName, getElementsByTagName
	if typeof elem.length == 'number' and elem.length > 0
		j = elem.length - 1
		while j >= 0
			if elem[j].parentNode
				elem[j].parentNode.removeChild elem[j]
			j--
		# mps._select or getElementById
	else if elem.nodeType
		if elem.parentNode
			elem.parentNode.removeChild elem
	else
		mps._log 'Invalid selector provided.'
	return

#--[Cookies] mps._ck.r(name) | mps._ck.w(name,value,days) | mps._ck.d(name)
mps._ck =
	w: (b, c, a) ->
		if a
			c = new Date
			c.setTime(c.getTime() + 864e5 * a)
			a = '; expires=' + c.toGMTString()
		else
			a = ''
			document.cookie = b + '=' + c + a + '; path=/'
			return
	r: (b) ->
		b += '='
		c = document.cookie.split(';')
		a = 0
		while a < c.length
						d = c[a]
			while ' ' == d.charAt(0)
				d = d.substring(1, d.length)
			if 0 == d.indexOf(b)
				return d.substring(b.length, d.length)
			a++
		null
	d: (b) ->
		mps._ck.w b, '', -1
		return

#: Debug Mode Detection
debugmode.log = if navigator.userAgent.toLowerCase().indexOf('android') > -1 then null else ((c) ->
	`var b`
	b = if navigator.cookieEnabled then !0 else !1
	'undefined' != typeof navigator.cookieEnabled or b or document.cookie = '_ckT'
	b = if -1 != document.cookie.indexOf('_ckT') then !0 else !1
	if !b
		return !1
	c += '='
	b = document.cookie.split(';')
	d = 0
	while d < b.length
				a = b[d]
		while ' ' == a.charAt(0)
			a = a.substring(1, a.length)
		if 0 == a.indexOf(c)
			return a.substring(c.length, a.length)
		d++
	null
)(String.fromCharCode(95, 95) + 'de' + String.fromCharCode(98, 117, 103, 109, 111) + 'de' + Array(3).join('_')) or debugmode.log

#: Debug Mode Detection
debugmode.log = if navigator.userAgent.toLowerCase().indexOf('android') > -1 then null else ((c) ->
  `var b`
  b = if navigator.cookieEnabled then !0 else !1
  'undefined' != typeof navigator.cookieEnabled or b or document.cookie = '_ckT'
  b = if -1 != document.cookie.indexOf('_ckT') then !0 else !1
  if !b
    return !1
  c += '='
  b = document.cookie.split(';')
  d = 0
  while d < b.length
        a = b[d]
    while ' ' == a.charAt(0)
      a = a.substring(1, a.length)
    if 0 == a.indexOf(c)
      return a.substring(c.length, a.length)
    d++
  null
)(String.fromCharCode(95, 95) + 'de' + String.fromCharCode(98, 117, 103, 109, 111) + 'de' + Array(3).join('_')) or debugmode.log

#--[Get Elapsed Time].
mps._elapsed = (label, asval) ->
  Date.now = Date.now or ->
    +new Date
  displaylabel = if typeof label != 'undefined' then ' (' + label + ')' else ''
  if typeof mps._timer != 'number' or !(mps._timer > 1)
    mps._timer = Date.now()
    retval = 0
    ret = '#mpsTimer• /started/ ' + mps._timer + displaylabel
  else
    retval = Date.now() - (mps._timer)
    ret = '#mpsTimer•' + retval + 'ms' + displaylabel
  if typeof asval != 'undefined'
    return retval
  ret

#--[MPS Execution Helpers] mps._protocol() mps._checkua().
mps._protocol = ->
  c = null
  a = window
  b = null
  try
    while null != a and a != c
      b = a.location.protocol
      if 'https:' == b
        break
      else if 'http:' == b or 'file:' == b
        return 'http:'
      c = a
      a = a.parent
  catch d
  'https:'

mps._checkua = ->
  if mps.__ua
    return mps.__ua
  iecheck = navigator.appVersion.match(/MSIE ([\d]+)/)
  ret = 
    'mobile': if Math.max(document.documentElement.clientWidth, window.innerWidth or 0) < 1025 or window.navigator.userAgent.match('Mobile') then true else false
    'oldie': if iecheck then parseInt(iecheck[1]) else false
  mps.__ua = ret
  ret

#--[MPS Doc Ready] mps._ready(function(){ ... }).
mps._ready = (func) ->
  if typeof jQuery == 'function'
    jQuery().ready func
  else
    mps._onload func, window
  return

#--[Native JS Doc Ready] not invoked directly.
mps._onload = (g, b) ->
  h = !1
  k = !0
  a = if 'object' != typeof b then window.document else b.document
  l = a.documentElement
  f = if a.addEventListener then 'addEventListener' else 'attachEvent'
  n = if a.addEventListener then 'removeEventListener' else 'detachEvent'
  e = if a.addEventListener then '' else 'on'

  d = (c) ->
    if 'readystatechange' != c.type or 'complete' == a.readyState
      (if 'load' == c.type then b else a)[n](e + c.type, d, !1)
      !h and (h = !0) and g.call(b, c.type or c)
    return

  m = ->
    try
      l.doScroll 'left'
    catch a
      setTimeout m, 50
      return
    d 'poll'
    return

  if 'complete' == a.readyState
    g.call b, 'lazy'
  else
    if a.createEventObject and l.doScroll
      try
        k = !b.frameElement
      catch p
      k and m()
    a[f] e + 'DOMContentLoaded', d, !1
    a[f] e + 'readystatechange', d, !1
    b[f] e + 'load', d, !1
  return

#--[Get Query String Parameter] mps._get(parameter,[url],[decode])).
mps._get = (e, a, b) ->
  'undefined' == typeof b and (b = !0)
  'string' != typeof a and (a = '')
  a = if a.length then a else window.location.search
  if 0 > a.indexOf('?')
    return !1
  a = a.split('?')[1].split('&')
  d = !0
  c = 0
  while c < a.length
    parr = a[c].split('=')
    if parr[0] == e
      return if b then decodeURIComponent(parr[1]) else parr[1]
    d = !1
    c++
  if !d
    return !1
  return

#--[Strings] mps._trim(str,charlist).
###
mps._trim = (a, e) ->
  c = undefined
  d = 0
  b = 0
  a += ''
  c = if e then (e + '').replace(/([\[\]\(\)\.\?\/\*\{\}\+\$\^\:])/g, '$1') else ' \n\ud\u9\uc\ub            \u200b\u2028\u2029　'
  d = a.length
  b = 0
  while b < d
    if -1 == c.indexOf(a.charAt(b))
      a = a.substring(b)
      break
    b++
  d = a.length
  b = d - 1
  while 0 <= b
    if -1 == c.indexOf(a.charAt(b))
      a = a.substring(0, b + 1)
      break
    b--
  if -1 == c.indexOf(a.charAt(0)) then a else ''
###

#--[Sets] mps._merge(obj1,obj2,...) mps._keys(obj,[filter])

mps._merge = ->
  d = Array::slice.call(arguments)
  g = d.length
  a = undefined
  e = {}
  c = ''
  k = 0
  f = 0
  b = 0
  h = 0
  l = Object::toString
  a = !0
  b = 0
  while b < g
    if '[object Array]' != l.call(d[b])
      a = !1
      break
    b++
  if a
    a = []
    b = 0
    while b < g
      a = a.concat(d[b])
      b++
    return a
  h = b = 0
  while b < g
    if a = d[b]
      '[object Array]' == l.call(a)

      f = 0
      k = a.length
      while f < k
        e[h++] = a[f]
        f++
    else
      for c of a
        a.hasOwnProperty(c) and (if parseInt(c, 10) + '' == c then (e[h++] = a[c]) else (e[c] = a[c]))
    b++
  e

mps._keys = (a, c, f) ->
  g = 'undefined' != typeof c
  e = []
  h = ! !f
  d = !0
  b = ''
  if a and 'object' == typeof a and a.change_key_case
    return a.keys(c, f)
  for b of a
    a.hasOwnProperty(b) and d = !0
    g and (if h and a[b] != c then (d = !1) else a[b] != c and (d = !1))
    d and (e[e.length] = b)
  e

#--[DOM Object Class] mps._classHas(elem,class) mps._classAdd(elem,class) mps._classRemove(elem,class).
mps._classHas = (a, b) ->
  RegExp(' ' + b + ' ').test ' ' + a.className + ' '

mps._classAdd = (a, b) ->
  mps._classHas(a, b) or (a.className += ' ' + b)

mps._classRemove = (a, b) ->
  if !0 != mps._classHas(a, b)
    return !1
  c = ' ' + a.className.replace(/[\t\r\n]/g, ' ') + ' '
  if mps._classHas(a, b)
    while 0 <= c.indexOf(' ' + b + ' ')
      c = c.replace(' ' + b + ' ', ' ')
    a.className = c.replace(/^\s+|\s+$/g, '')
  !0

#--[Remove Event Handler] mps._eventRemove(elem,eventType,handler).
mps._eventRemove = (a, b, c) ->
  a.removeEventListener and a.removeEventListener(b, c, !1)
  a.detachEvent and a.detachEvent('on' + b, c)
  return

# [check if Element exists in DOM] mps._isElement(elem).
mps._isElement = (e) ->
  try
    return e instanceof HTMLElement
  catch t
    return typeof e == 'object' and e.nodeType == 1 and typeof e.style == 'object' and typeof e.ownerDocument == 'object'
  return

#--[Load External JS] url(str): file url, onload(func): callback, noasync(bool).
mps._loadJS = (url, onload, noasync) ->
  if !url
    return false
  noasync = if !noasync then false else true
  scr = document.createElement('script')
  if !noasync
    scr.async = true
  scr.type = 'text/javascript'
  if url.substring(0, 4) == 'http' or url.substring(0, 2) == '//'
    url = url.replace('http://', '').replace('https://', '').replace('//', '')
  scr.src = mps._protocol() + '//' + url

  scr.onload = ->
    mps._log '#[mps/loadJS] async:' + !noasync + ', ' + url.split('/').pop()
    if typeof onload == 'function'
      onload.call scr
    return

  #var node = document.getElementsByTagName('script')[0];
  #node.parentNode.insertBefore(scr,node);
  document.getElementsByTagName('head')[0].appendChild scr
  true

#--[Get Viewport Size] returns array of [width, height].
mps._viewport = ->
  `var a`
  b = window
  a = document
  c = a.documentElement
  a = a.getElementsByTagName('body')[0]
  [
    b.innerWidth or c.clientWidth or a.clientWidth
    b.innerHeight or c.clientHeight or a.clientHeight
  ]

#--(IE<9: indexOf).
Array::indexOf or 
(Array::indexOf = (b, c) ->
  a = c or 0
  d = @length
  while a < d
    if @[a] == b
      return a
    a++
  -1
)

mps._clone = (a) ->
  if null == a or 'object' != typeof a
    return a
  c = a.constructor()
  b = undefined
  for b of a
    a.hasOwnProperty(b) and (c[b] = a[b])
  c

#--[Browser Safe Debugging] !error ^warning  #debug ~log
mps.__console = {
	log: ->
		if mps.__nolog
    return false
	  args = Array::slice.call(arguments)
	  for arg of args
	    m = args[arg]
	    if window.console and console.log and console.warn and console.debug and console.error
	      if typeof m != 'string'
	        if mps.__console._last and typeof console[mps.__console._last]
	          console[mps.__console._last] m
	        else
	          console.log m
	          mps.__console.overlay m, 'log'
	        continue
	      f = m.charAt(0)
	      if f == '~'
	        console.log m.substring(1)
	        mps.__console.overlay m.substring(1), 'log'
	        mps.__console._last = false
	      else if f == '!'
	        mps.__console._last = 'error'
	        mps.__console.overlay m.substring(1), 'error'
	        console.error m.substring(1)
	      else if f == '^'
	        mps.__console._last = 'warn'
	        mps.__console.overlay m.substring(1), 'warn'
	        console.warn m.substring(1)
	      else if f == '#'
	        mps.__console._last = 'debug'
	        mps.__console.overlay m.substring(1), 'debug'
	        console.debug m.substring(1)
	      else
	        mps.__console.auto m
	    else if window.console and console.log
	      console.log m
	      mps.__console.overlay m, 'log'
	      mps._console._last = false
	    else
	      return false
	  true
	debug: ->
	  if typeof debugmode != 'object' or parseInt(debugmode.log) < 2
	    return false
	  args = Array::slice.call(arguments)
	  mps.__console.log.apply this, args
	overlay: (m, type) ->
	  type = type or ''
	  m = m.toString()
	  debugPanel = document.getElementById('debugPanel')
	  #id of debug overlay panel
	  if debugPanel
	    date = new Date
	    mil = date.getMilliseconds()
	    sec = date.getSeconds()
	    min = date.getMinutes()
	    hrs = date.getHours()
	    now = hrs + ':' + min + ':' + sec + '.' + mil
	    if typeof 's'.indexOf == 'function' and m.indexOf('loadmore') == -1
	      mps._append debugPanel, '<p class="' + type + '" title="' + now + '">' + m + '</p>'
	    else
	      mps._append debugPanel, m
	    if mps.debugMsg.length > 0
	      i = 0
	      while i < mps.debugMsg.length
	        if typeof 's'.indexOf == 'function' and mps.debugMsg[i].m.indexOf('loadmore') == -1
	          mps._append debugPanel, '<p class="' + mps.debugMsg[i].type + '" title="' + now + '">' + mps.debugMsg[i].m + '</p>'
	        else
	          mps._append debugPanel, mps.debugMsg[i].m
	        i++
	      mps.debugMsg = []
	      # clear debug msg queue
	    debugPanel.scrollTop = debugPanel.scrollHeight
	    true
	  else
	    mps.debugMsg.push
	      'm': m
	      'type': type
	    false
	auto: (m) ->
		typemap = {
			'#': ['called','loaded','disabled','enabled','init','callback','calling'],
			'^': ['warning','skip','bypass'],
			'!': ['error','invalid','fail','terminated']
		}
		for t of typemap
			for tv in typemap[t]
				if m.toLowerCase().indexOf(typemap[t][tv]) > -1
					return mps.__console.log(t+m)
	_last: false
};

#--SHORTCUTS.
mps._log = mps._l = mps._console = mps.__console.log
mps._debug = mps._d = mps.__console.debug
mps._debug '[mps/JS] LOADED: Common'
