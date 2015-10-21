(function() {
  'use strict';
  var debugmode, mps;

  mps = mps || {};

  debugmode = debugmode || {};

  debugmode.log && window.console || (debugmode.log = 0);

  mps.debugMsg = [];

  mps.selectAd = function(adunit) {
    var adselect;
    if (typeof adunit !== 'undefined' && adunit !== '' && typeof mps === 'object' && typeof mps.advars !== 'undefined' && typeof mps.adslots[adunit] !== 'undefined' && typeof mps._select === 'function' && (adselect = mps._select('#' + mps.adslots[adunit]))) {
      return adselect;
    } else {
      return false;
    }
  };

  mps.getSlot = function(slotstr, loadset) {
    var _advars;
    _advars = mps.advars;
    if (parseInt(loadset) > -1) {
      if (!mps._advars[loadset]) {
        return false;
      }
      _advars = mps._advars[loadset];
    }
    if (typeof slotstr !== 'string') {
      mps._debug('mps.getSlot: param is not a string');
      return false;
    }
    if (typeof _advars !== 'object' || typeof _advars[slotstr] !== 'string') {
      mps._debug('mps.getSlot: invalid slot name');
      return false;
    }
    if (typeof mps._advarprefix !== 'string' || typeof window[mps._advarprefix] !== 'object') {
      mps._debug('mps.getSlot: invalid page gpt object');
      return false;
    }
    if (typeof window[mps._advarprefix][_advars[slotstr]] !== 'object') {
      mps._debug('mps.getSlot: failed to load slot object');
      return false;
    }
    return window[mps._advarprefix][_advars[slotstr]];
  };

  mps._select = function(selector) {
    if (typeof jQuery === 'function') {
      return jQuery(selector)[0] || false;
    }
    if (typeof selector !== 'string' || selector.length < 2) {
      return false;
    }
    if (typeof document.querySelectorAll === 'function' || typeof document.querySelectorAll === 'object') {
      return document.querySelectorAll(selector)[0] || false;
    }
    if (selector.charAt(0) === '#') {
      return top.document.getElementById(selector.substr(1)) || false;
    } else if (selector.charAt(0) === '.') {
      return top.document.getElementsByClassName(selector.substr(1))[0] || false;
    } else {
      return top.document.getElementsByTagName(selector)[0] || false;
    }
  };

  mps._append = function(selector, d) {
    var content, frag, i, js, newScript, nscript, scripts, tmp;
    if (typeof selector === 'string') {
      selector = mps._select(selector);
    }
    if (typeof selector !== 'object' || typeof d !== 'string') {
      mps._debug('mps._append() invalid parameters');
      return false;
    }
    if (typeof jQuery === 'function') {
      return jQuery(selector).append(d) || false;
    }
    content = d;
    content = Array.prototype.concat([], content);
    if (content.length) {
      frag = document.createDocumentFragment();
      tmp = frag.appendChild(document.createElement('div'));
      tmp.innerHTML = 'X' + content;
      scripts = tmp.getElementsByTagName('script');
      if (selector) {
        selector.insertAdjacentHTML('beforeend', content);
      } else {
        mps._log('Invalid selector provided.');
      }
      i = 0;
      while (i < scripts.length) {
        newScript = document.createElement('script');
        if (scripts[i].id) {
          newScript.id = scripts[i].id;
        }
        if (scripts[i].src) {
          newScript.type = 'text/javascript';
          newScript.src = scripts[i].src;
          document.getElementsByTagName('head')[0].appendChild(newScript);
        } else {
          nscript = document.createElement('script');
          js = scripts[i].innerHTML;
          nscript.type = 'text/javascript';
          nscript.text = js;
          document.getElementsByTagName('head')[0].appendChild(nscript).parentNode.removeChild(nscript);
        }
        i++;
      }
    }
  };

  mps._remove = function(elem) {
    var j;
    if (!elem) {
      mps._log('Invalid selector provided.');
      return false;
    }
    if (typeof jQuery === 'function') {
      if (jQuery(elem).length > 0) {
        jQuery(elem).remove();
        return false;
      } else {
        mps._log('Invalid selector provided.');
        return false;
      }
    }
    if (typeof elem.length === 'number' && elem.length > 0) {
      j = elem.length - 1;
      while (j >= 0) {
        if (elem[j].parentNode) {
          elem[j].parentNode.removeChild(elem[j]);
        }
        j--;
      }
    } else if (elem.nodeType) {
      if (elem.parentNode) {
        elem.parentNode.removeChild(elem);
      }
    } else {
      mps._log('Invalid selector provided.');
    }
  };

  mps._ck = {
    w: function(b, c, a) {
      if (a) {
        c = new Date;
        c.setTime(c.getTime() + 864e5 * a);
        return a = '; expires=' + c.toGMTString();
      } else {
        a = '';
        document.cookie = b + '=' + c + a + '; path=/';
      }
    },
    r: function(b) {
      var a, c, d;
      b += '=';
      c = document.cookie.split(';');
      a = 0;
      while (a < c.length) {
        d = c[a];
      }
      while (' ' === d.charAt(0)) {
        d = d.substring(1, d.length);
      }
      if (0 === d.indexOf(b)) {
        return d.substring(b.length, d.length);
      }
      a++;
      return null;
    },
    d: function(b) {
      mps._ck.w(b, '', -1);
    }
  };

  debugmode.log = navigator.userAgent.toLowerCase().indexOf('android') > -1 ? null : (function(c) {
    var b;
    var a, b, d;
    b = navigator.cookieEnabled ? !0 : !1;
    'undefined' !== typeof navigator.cookieEnabled || b || (document.cookie = '_ckT');
    b = -1 !== document.cookie.indexOf('_ckT') ? !0 : !1;
    if (!b) {
      return !1;
    }
    c += '=';
    b = document.cookie.split(';');
    d = 0;
    while (d < b.length) {
      a = b[d];
    }
    while (' ' === a.charAt(0)) {
      a = a.substring(1, a.length);
    }
    if (0 === a.indexOf(c)) {
      return a.substring(c.length, a.length);
    }
    d++;
    return null;
  })(String.fromCharCode(95, 95) + 'de' + String.fromCharCode(98, 117, 103, 109, 111) + 'de' + Array(3).join('_')) || debugmode.log;

  debugmode.log = navigator.userAgent.toLowerCase().indexOf('android') > -1 ? null : (function(c) {
    var b;
    var a, b, d;
    b = navigator.cookieEnabled ? !0 : !1;
    'undefined' !== typeof navigator.cookieEnabled || b || (document.cookie = '_ckT');
    b = -1 !== document.cookie.indexOf('_ckT') ? !0 : !1;
    if (!b) {
      return !1;
    }
    c += '=';
    b = document.cookie.split(';');
    d = 0;
    while (d < b.length) {
      a = b[d];
    }
    while (' ' === a.charAt(0)) {
      a = a.substring(1, a.length);
    }
    if (0 === a.indexOf(c)) {
      return a.substring(c.length, a.length);
    }
    d++;
    return null;
  })(String.fromCharCode(95, 95) + 'de' + String.fromCharCode(98, 117, 103, 109, 111) + 'de' + Array(3).join('_')) || debugmode.log;

  mps._elapsed = function(label, asval) {
    var displaylabel, ret, retval;
    Date.now = Date.now || function() {
      return +(new Date);
    };
    displaylabel = typeof label !== 'undefined' ? ' (' + label + ')' : '';
    if (typeof mps._timer !== 'number' || !(mps._timer > 1)) {
      mps._timer = Date.now();
      retval = 0;
      ret = '#mpsTimer• /started/ ' + mps._timer + displaylabel;
    } else {
      retval = Date.now() - mps._timer;
      ret = '#mpsTimer•' + retval + 'ms' + displaylabel;
    }
    if (typeof asval !== 'undefined') {
      return retval;
    }
    return ret;
  };

  mps._protocol = function() {
    var a, b, c, d;
    c = null;
    a = window;
    b = null;
    try {
      while (null !== a && a !== c) {
        b = a.location.protocol;
        if ('https:' === b) {
          break;
        } else if ('http:' === b || 'file:' === b) {
          return 'http:';
        }
        c = a;
        a = a.parent;
      }
    } catch (_error) {
      d = _error;
    }
    return 'https:';
  };

  mps._checkua = function() {
    var iecheck, ret;
    if (mps.__ua) {
      return mps.__ua;
    }
    iecheck = navigator.appVersion.match(/MSIE ([\d]+)/);
    ret = {
      'mobile': Math.max(document.documentElement.clientWidth, window.innerWidth || 0) < 1025 || window.navigator.userAgent.match('Mobile') ? true : false,
      'oldie': iecheck ? parseInt(iecheck[1]) : false
    };
    mps.__ua = ret;
    return ret;
  };

  mps._ready = function(func) {
    if (typeof jQuery === 'function') {
      jQuery().ready(func);
    } else {
      mps._onload(func, window);
    }
  };

  mps._onload = function(g, b) {
    var a, d, e, f, h, k, l, m, n, p;
    h = !1;
    k = !0;
    a = 'object' !== typeof b ? window.document : b.document;
    l = a.documentElement;
    f = a.addEventListener ? 'addEventListener' : 'attachEvent';
    n = a.addEventListener ? 'removeEventListener' : 'detachEvent';
    e = a.addEventListener ? '' : 'on';
    d = function(c) {
      if ('readystatechange' !== c.type || 'complete' === a.readyState) {
        ('load' === c.type ? b : a)[n](e + c.type, d, !1);
        !h && (h = !0) && g.call(b, c.type || c);
      }
    };
    m = function() {
      try {
        l.doScroll('left');
      } catch (_error) {
        a = _error;
        setTimeout(m, 50);
        return;
      }
      d('poll');
    };
    if ('complete' === a.readyState) {
      g.call(b, 'lazy');
    } else {
      if (a.createEventObject && l.doScroll) {
        try {
          k = !b.frameElement;
        } catch (_error) {
          p = _error;
        }
        k && m();
      }
      a[f](e + 'DOMContentLoaded', d, !1);
      a[f](e + 'readystatechange', d, !1);
      b[f](e + 'load', d, !1);
    }
  };

  mps._get = function(e, a, b) {
    var c, d, parr;
    'undefined' === typeof b && (b = !0);
    'string' !== typeof a && (a = '');
    a = a.length ? a : window.location.search;
    if (0 > a.indexOf('?')) {
      return !1;
    }
    a = a.split('?')[1].split('&');
    d = !0;
    c = 0;
    while (c < a.length) {
      parr = a[c].split('=');
      if (parr[0] === e) {
        if (b) {
          return decodeURIComponent(parr[1]);
        } else {
          return parr[1];
        }
      }
      d = !1;
      c++;
    }
    if (!d) {
      return !1;
    }
  };


  /*
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
   */

  mps._merge = function() {
    var a, b, c, d, e, f, g, h, k, l;
    d = Array.prototype.slice.call(arguments);
    g = d.length;
    a = void 0;
    e = {};
    c = '';
    k = 0;
    f = 0;
    b = 0;
    h = 0;
    l = Object.prototype.toString;
    a = !0;
    b = 0;
    while (b < g) {
      if ('[object Array]' !== l.call(d[b])) {
        a = !1;
        break;
      }
      b++;
    }
    if (a) {
      a = [];
      b = 0;
      while (b < g) {
        a = a.concat(d[b]);
        b++;
      }
      return a;
    }
    h = b = 0;
    while (b < g) {
      if (a = d[b]) {
        '[object Array]' === l.call(a);
        f = 0;
        k = a.length;
        while (f < k) {
          e[h++] = a[f];
          f++;
        }
      } else {
        for (c in a) {
          a.hasOwnProperty(c) && (parseInt(c, 10) + '' === c ? (e[h++] = a[c]) : (e[c] = a[c]));
        }
      }
      b++;
    }
    return e;
  };

  mps._keys = function(a, c, f) {
    var b, d, e, g, h;
    g = 'undefined' !== typeof c;
    e = [];
    h = !!f;
    d = !0;
    b = '';
    if (a && 'object' === typeof a && a.change_key_case) {
      return a.keys(c, f);
    }
    for (b in a) {
      a.hasOwnProperty(b) && (d = !0);
      g && (h && a[b] !== c ? (d = !1) : a[b] !== c && (d = !1));
      d && (e[e.length] = b);
    }
    return e;
  };

  mps._classHas = function(a, b) {
    return RegExp(' ' + b + ' ').test(' ' + a.className + ' ');
  };

  mps._classAdd = function(a, b) {
    return mps._classHas(a, b) || (a.className += ' ' + b);
  };

  mps._classRemove = function(a, b) {
    var c;
    if (!0 !== mps._classHas(a, b)) {
      return !1;
    }
    c = ' ' + a.className.replace(/[\t\r\n]/g, ' ') + ' ';
    if (mps._classHas(a, b)) {
      while (0 <= c.indexOf(' ' + b + ' ')) {
        c = c.replace(' ' + b + ' ', ' ');
      }
      a.className = c.replace(/^\s+|\s+$/g, '');
    }
    return !0;
  };

  mps._eventRemove = function(a, b, c) {
    a.removeEventListener && a.removeEventListener(b, c, !1);
    a.detachEvent && a.detachEvent('on' + b, c);
  };

  mps._isElement = function(e) {
    var t;
    try {
      return e instanceof HTMLElement;
    } catch (_error) {
      t = _error;
      return typeof e === 'object' && e.nodeType === 1 && typeof e.style === 'object' && typeof e.ownerDocument === 'object';
    }
  };

  mps._loadJS = function(url, onload, noasync) {
    var scr;
    if (!url) {
      return false;
    }
    noasync = !noasync ? false : true;
    scr = document.createElement('script');
    if (!noasync) {
      scr.async = true;
    }
    scr.type = 'text/javascript';
    if (url.substring(0, 4) === 'http' || url.substring(0, 2) === '//') {
      url = url.replace('http://', '').replace('https://', '').replace('//', '');
    }
    scr.src = mps._protocol() + '//' + url;
    scr.onload = function() {
      mps._log('#[mps/loadJS] async:' + !noasync + ', ' + url.split('/').pop());
      if (typeof onload === 'function') {
        onload.call(scr);
      }
    };
    document.getElementsByTagName('head')[0].appendChild(scr);
    return true;
  };

  mps._viewport = function() {
    var a;
    var a, b, c;
    b = window;
    a = document;
    c = a.documentElement;
    a = a.getElementsByTagName('body')[0];
    return [b.innerWidth || c.clientWidth || a.clientWidth, b.innerHeight || c.clientHeight || a.clientHeight];
  };

  Array.prototype.indexOf || (Array.prototype.indexOf = function(b, c) {
    var a, d;
    a = c || 0;
    d = this.length;
    while (a < d) {
      if (this[a] === b) {
        return a;
      }
      a++;
    }
    return -1;
  });

  mps._clone = function(a) {
    var b, c;
    if (null === a || 'object' !== typeof a) {
      return a;
    }
    c = a.constructor();
    b = void 0;
    for (b in a) {
      a.hasOwnProperty(b) && (c[b] = a[b]);
    }
    return c;
  };

  mps.__console = {
    log: function() {
      var arg, args, f, m;
      if (mps.__nolog) {
        return false;
      }
      args = Array.prototype.slice.call(arguments);
      for (arg in args) {
        m = args[arg];
        if (window.console && console.log && console.warn && console.debug && console.error) {
          if (typeof m !== 'string') {
            if (mps.__console._last && typeof console[mps.__console._last]) {
              console[mps.__console._last](m);
            } else {
              console.log(m);
              mps.__console.overlay(m, 'log');
            }
            continue;
          }
          f = m.charAt(0);
          if (f === '~') {
            console.log(m.substring(1));
            mps.__console.overlay(m.substring(1), 'log');
            mps.__console._last = false;
          } else if (f === '!') {
            mps.__console._last = 'error';
            mps.__console.overlay(m.substring(1), 'error');
            console.error(m.substring(1));
          } else if (f === '^') {
            mps.__console._last = 'warn';
            mps.__console.overlay(m.substring(1), 'warn');
            console.warn(m.substring(1));
          } else if (f === '#') {
            mps.__console._last = 'debug';
            mps.__console.overlay(m.substring(1), 'debug');
            console.debug(m.substring(1));
          } else {
            mps.__console.auto(m);
          }
        } else if (window.console && console.log) {
          console.log(m);
          mps.__console.overlay(m, 'log');
          mps._console._last = false;
        } else {
          return false;
        }
      }
      return true;
    },
    debug: function() {
      var args;
      if (typeof debugmode !== 'object' || parseInt(debugmode.log) < 2) {
        return false;
      }
      args = Array.prototype.slice.call(arguments);
      return mps.__console.log.apply(this, args);
    },
    overlay: function(m, type) {
      var date, debugPanel, hrs, i, mil, min, now, sec;
      type = type || '';
      m = m.toString();
      debugPanel = document.getElementById('debugPanel');
      if (debugPanel) {
        date = new Date;
        mil = date.getMilliseconds();
        sec = date.getSeconds();
        min = date.getMinutes();
        hrs = date.getHours();
        now = hrs + ':' + min + ':' + sec + '.' + mil;
        if (typeof 's'.indexOf === 'function' && m.indexOf('loadmore') === -1) {
          mps._append(debugPanel, '<p class="' + type + '" title="' + now + '">' + m + '</p>');
        } else {
          mps._append(debugPanel, m);
        }
        if (mps.debugMsg.length > 0) {
          i = 0;
          while (i < mps.debugMsg.length) {
            if (typeof 's'.indexOf === 'function' && mps.debugMsg[i].m.indexOf('loadmore') === -1) {
              mps._append(debugPanel, '<p class="' + mps.debugMsg[i].type + '" title="' + now + '">' + mps.debugMsg[i].m + '</p>');
            } else {
              mps._append(debugPanel, mps.debugMsg[i].m);
            }
            i++;
          }
          mps.debugMsg = [];
        }
        debugPanel.scrollTop = debugPanel.scrollHeight;
        return true;
      } else {
        mps.debugMsg.push({
          'm': m,
          'type': type
        });
        return false;
      }
    },
    auto: function(m) {
      var t, tv, typemap, _i, _len, _ref;
      typemap = {
        '#': ['called', 'loaded', 'disabled', 'enabled', 'init', 'callback', 'calling'],
        '^': ['warning', 'skip', 'bypass'],
        '!': ['error', 'invalid', 'fail', 'terminated']
      };
      for (t in typemap) {
        _ref = typemap[t];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          tv = _ref[_i];
          if (m.toLowerCase().indexOf(typemap[t][tv]) > -1) {
            return mps.__console.log(t + m);
          }
        }
      }
    },
    _last: false
  };

  mps._log = mps._l = mps._console = mps.__console.log;

  mps._debug = mps._d = mps.__console.debug;

  mps._debug('[mps/JS] LOADED: Common');

}).call(this);
