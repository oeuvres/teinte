/**
 * © 2009, 2012 frederic.glorieux@algone.net
 *
 * This program is a free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License 
 * http://www.gnu.org/licenses/lgpl.html
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of 
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

var Suggest = {
  /** All suggests registered */
  input: [],
  /** Array for datas */
  data: [],
  /** Default max height for a suggestion list */
  height : 20,

  create: function (id, src) {
    var input=document.getElementById(id);
    if (!input) return alert(id + " : no element with this identifier");
    if (!src) src=input.src;
    if (!src) return alert(id + " : no data source found (provide an uri in the @src attribute of the <input>)");
    if (typeof(src) == 'string') {
      input.uri=src;
      input.data=null;
    }
    else {
      input.data=src;
      input.uri=null;
    }
    // behaviors
    input.setAttribute('autocomplete', 'off');
    // attach a list to input
    Suggest.list(input);
    input.onkeydown  = function(e) {return Suggest.keydown(this, e);}
    input.onkeyup  = function(e) {return Suggest.keyup(this, e);}
    // input.onkeypress = function(e) {if (!e) e = window.event; if (e.keyCode == 13 ) return false;}
    // o.ondblclick = function() {Suggest_ShowDropdown(this.id);}
    // éviter de refermer la liste
    input.onclick  = function(e) {if (!e) e = window.event; e.cancelBubble = true; e.returnValue = false;}
    this.input[id]=input;
    // close all suggest windows by click outside page

    if (document.addEventListener) {
      document.addEventListener('click', Suggest.hideAll, false);
    } else if (document.attachEvent) {
      document.attachEvent('onclick', Suggest.hideAll, false);
    }
    return "Suggest "+ id +" created";
  },

  /**
   * Attach list to an input
   *
   * @param input ! the form control
   */
  list: function (input) {
    if (input.suggest) Suggest.hide(input);
    var left  = El.left(input);
    var top   = El.top(input) + input.offsetHeight;
    var width = input.offsetWidth;
    // Bug IE6 sur les transparences
    if (/MSIE 8/i.test(navigator.userAgent)); // rien
    else if (/MSIE 7/i.test(navigator.userAgent)); // rien
    else if (/MSIE 6/i.test(navigator.userAgent)) {
      var iframe = document.createElement('iframe');
      iframe.id = id +'_iframe';
      iframe.style.position = 'absolute';
      input.iframe.style.width = '0px';
      iframe.style.height = '0px';
      iframe.style.zIndex = '98';
      iframe.style.visibility = 'hidden';
      input.parentNode.appendChild(iframe);
      input.iframe=iframe;
    }
    var list=document.createElement('div');
    list.style.visibility = 'hidden';
    list.className = 'suggest';
    // insert list just after input (OK ?)
    input.parentNode.appendChild(document.createTextNode("\n"));
    input.parentNode.appendChild(list);
    // absolute position
    list.style.left  = left + 'px';
    list.style.width    = width + 'px';
    list.style.zIndex   = '99';
    list.style.position='absolute';
    list.style.overflow='auto';
    // behaviors
    // list.onmouseover = Suggest.over; // prefers CSS :hover
    list.onclick   = function(e) {
      Suggest.set(this.input, e);
      Suggest.hide(this.input, e);
      if (this.input.form.onsubmit()) this.input.form.submit();
    }
    // convenient handlers
    list.id=input.id+"_list";
    list.input=input;
    input.suggest=list;
  },

  /**
   * Press a key
   */
  keydown: function (input) {
    if (arguments[1] != null) event = arguments[1];
    var keyCode = event.keyCode;
    switch (keyCode) {
      // Return/Enter, what shall we do ?
      case 13:
        // si valeur sélectionnée, remplir l'input et ne pas partir
        // return pas trop invasif, ne pas sélectionner une valeur
        if (Suggest.set(input)) {
          Suggest.hide(input);
          /*
          event.returnValue = false;
          event.cancelBubble = true;
          return false;
          */
        }
        // laisser partir le formulaire si le suggest est caché
        else {
          return true;
        }
        break;
      // Escape
      case 27:
        Suggest.hide(input);
        event.returnValue = false;
        event.cancelBubble = true;
        break;

      // Up arrow
      case 38:
        if (!input.visible) {
          Suggest.show(input);
        }
        Suggest.move(input, -1);
        return false;
        break;

      // Tab
      case 9:
        if (input.visible) {
          Suggest.hide(input);
        }
        return;
      // bas
      case 40:
        if (!input.visible) {
          Suggest.show(input);
        }
        Suggest.move(input, 1);
        return false;
        break;
    }
  },

  keyup: function (input) {
    if (arguments[1] != null) event = arguments[1];
    if (!event) return;
    var keyCode = event.keyCode;
    switch (keyCode) {
      // return
      case 13:
        event.returnValue = false;
        event.cancelBubble = true;
        break;
      // Esc
      case 27:
        Suggest.hide(input);
        event.returnValue = false;
        event.cancelBubble = true;
        break;
      // up/down go out
      case 38:
      case 40:
        return false;
        break;
      // Backspace
      case 8:
        // close suggestion list on last char
        if (!input.value && input.visible) {
          Suggest.hide(input);
          break;
        }
      // open on keypress
      default:
        Suggest.show(input);
        break;
    }
  },

  /**
   * Cacher la liste
   */
  hide: function(input) {
    input=El.get(input);
    if (input.iframe) input.iframe.style.visibility = 'hidden';
    if (input.suggest) {
      input.suggest.style.visibility = 'hidden';
      input.suggest.hi = null;
    }
    input.visible   = false;
  },
  /**
   * Cacher tous les suggest enregistrés
   */
  hideAll: function() {
    for (input in Suggest.input) {
      Suggest.hide(input);
    }
  },

  /**
   * Display suggestion list
   */
  show: function(input) {
    input.visible=true;
    if (input.uri) {
      Suggest.jsonp(input.uri+input.value+'&.js'); // .js for old flavours of IE
      return;
    }
    /* local data, historic
    else if (input.data) {
      var i=Suggest.search(input.data, input.value);
      var max=(i+Suggest.height < input.data.length)?i+Suggest.height:input.data.length;
      // a fast string concat
      var html=[];
      for (;i<max;i++){
        if (input.data[i][1]) html.push("\n<div>"+input.data[i][1]+"</div>");
        else html.push("<div>"+input.data[i][0]+"</div>");
      }
      Suggest.ins(input, html.join('\n'));
    } 
    */
    else {
      // problème
    }
  },

  /**
   * Insert Html in the scrolling list
   *
   * @param id    ! list identifier
   * @param html  ! items as html
   * @param count ? number of items, to adjust height
   */
  ins: function (input, html, count) {
    input=El.get(input);;
    // let output error if wrong call
    var list=input.suggest;
    list.innerHTML=html;
    // close ?
    // +"\n"+'<a class="close" href="#" onclick="return Suggest.close(\''+input.id+'\')">X</a>'; 
    // 0 items, hide
    if (count == 0 || !html.length) {
      Suggest.hide(input);
      return;
    };
    // try to count items to choose a height
    if (!count && html.match(/<div/g)) count=html.match(/<div/g).length;
    if (!count && html.match(/<a/g)) count=html.match(/<a/g).length;
    // too much items, keep height
    if (count > 10) {
      list.style.height= ""+ 20 + "em";
    }
    else list.style.height="auto";
    // IE6, sous iFrame
    if (input.iframe) {
      // iframe.style.top  = list.style.top;
      // iframe.style.left   = list.style.left;
      input.iframe.style.width  = input.suggest.offsetWidth + 'px';
      input.iframe.style.height = input.suggest.offsetHeight + 'px';
      input.iframe.style.visibility = 'visible';
    }
    // rendre visible ?? TODO à voir
    if (input.suggest.style.visibility != 'visible') input.suggest.style.visibility = 'visible';
    input.visible=true;
    // do not hilite first item by default, maybe not the one we like
    /*
    div=El.first(list);
    if (div) Suggest.hi(div);
    */
  },


  /**
   * Select an item by up/down arrow keys
   * @param element input  l'input
   * @param int  index +/- 1
   */
  move: function(input, move) {
    var list=input.suggest;
    // which item to select ?
    var div;
    if (!move);
    // go down from an item already selected
    else if (list.hi && move > 0) {
      div=El.next(list.hi, "DIV");
      // pas de suivant, fermer
      if (!div) {
        if (list.hi) list.hi.className=list.hi.oldClass;
        Suggest.hide(input);
      }
    }
    // go up from an item already selected
    else if (list.hi && move < 0) {
      div=El.prev(list.hi, "DIV");
      // pas de précédent, fermer
      if (!div) {
        if (list.hi) list.hi.className=list.hi.oldClass;
        Suggest.hide(input);
      }
    }
    // go start
    else if (move > 0) {
      div=El.first(list, "DIV");
    }
    // go end
    else if (move < 0) {
      div=El.last(list, "DIV");
    }
    // on devrait toujours avoir un élément
    if (!div) return true;
    Suggest.hi(div);
  },
  /**
   * Hilite a selected div in a list
   */
  hi: function (div) {
    if (!div || div.nodeName.toLowerCase() != "div") return true;
    if (div.className != "hi") div.oldClass=div.className;
    div.className="hi";
    list=div.parentNode;
    if (!list) return;
    // unselect last item
    if(list.hi && list.hi != div) {
      list.hi.className=list.hi.oldClass;
      /*
      if (div.parentNode.hi == div) {
        div.parentNode.hi=null;
        return;
      } */
      list.hi=null;
    }
    list.hi=div;
    // scroll up
    if ( (list.hi.offsetTop - list.scrollTop) < 0) {
      list.scrollTop= list.hi.offsetTop - list.offsetHeight + 30;
    }
    // scroll down
    else if ((list.hi.offsetTop - list.scrollTop) > (list.offsetHeight - 15) ) {
      list.scrollTop= list.hi.offsetTop - 15 ;
    }
  },
  /**
   * Take text from a selected item to put in input
   * TODO, find a more generic way to configure what we want here
   */
  set: function (input) {
    var div = input.suggest.hi;
    if (!div) return false;
    var text = div.innerText || div.textContent;
    // [FG] retirer le score
    // text=text.replace(/\s*\([0-9]+\)\s*$/g, "");
    input.value = text;
    return true;
  },
  /**
   * Close selection list
   */
  close: function (input) {
    input=El.get(input);
    if (!input) return true; // faire courir l'événement
    if (input.suggest && input.suggest.parentNode) input.suggest.parentNode.removeChild(input.suggest);
    if (input.iframe && input.iframe.parentNode) input.iframe.parentNode.removeChild(input.iframe);
    input.data=null;
    input.uri=null;
    // retirer les évènements
    input.onkeydown=null;
    input.onkeyup=null;
    input.onclick=null;
    return false;
  },
  /**
   * Binary search in a key:value array
   */
  search: function (map, key) {
    var low = 0, high = map.length - 1, i;
    while (high - low > 1) {
      i = low + high >> 1; // fast binary division
      if (key.toLowerCase() > map[i][0].toLowerCase()) low = i+1 ; // compare ignore case
      else high = i - 1 ;
    }
    return low;
  },
  /**
   * load data and an event trigger from server
   */
  jsonp: function (src) {
    var js = document.createElement('script');
    // js.type = 'text/javascript';
    js.src = src;
    var head = document.getElementsByTagName('head')[0];
    head.appendChild(js);
  },
  /**
   * Hilite hover on the list. Obsolet
   */
  over: function (e) {
    e=e||event;
    if (!e) return true;
    var div=e.srcElement||e.target;
    // remonter jusqu'à tenir le div de l'item de liste
    while (div && div.parentNode != this) {
      div=div.parentNode;
    }
    Suggest.hi(div);
  }

}

/**
   Provide the XMLHttpRequest constructor for Internet Explorer 5.x-6.x:
   Other browsers (including Internet Explorer 7.x-9.x) do not redefine
   XMLHttpRequest if it already exists.
 
   This example is based on findings at:
   http://blogs.msdn.com/xmlteam/archive/2006/10/23/using-the-right-version-of-msxml-in-internet-explorer.aspx
*/
if (typeof XMLHttpRequest === "undefined") {
  XMLHttpRequest = function () {
    try { return new ActiveXObject("Msxml2.XMLHTTP.6.0"); }
    catch (e) {}
    try { return new ActiveXObject("Msxml2.XMLHTTP.3.0"); }
    catch (e) {}
    try { return new ActiveXObject("Microsoft.XMLHTTP"); }
    catch (e) {}
    throw new Error("This browser does not support XMLHttpRequest.");
  };
}
/**
Generic properties of HTML elements
 */
var El= {
  /**
   * Coordonnée gauche absolue d'un élément
   * <http://www.quirksmode.org/js/findpos.html>
   *
   * @param object element
   */
  left: function(node) {
    var left  = 0;
    left += node.offsetLeft;
    /* on dirait que cette boucle déconne ?
    do {
      // alert(node.tagName +":"+node.offsetLeft);
      left += node.offsetLeft;
      node = node.offsetParent;
    } while(node && node.tagName.toLowerCase() != 'body');
    */
    return left;
  },


 /**
  * Get an absolute y coordinate for an object 
  * [FG] : buggy with absolute object
  * <http://www.quirksmode.org/js/findpos.html>
  *
  * @param object element
  */
  top: function(node) {
    var top  = 0;
    do {
      top += node.offsetTop;
      node = node.offsetParent;
    } while(node && node.tagName.toLowerCase() != 'body');
    return top;
  },

  /**
   * Cross browser ScrollTop
   */
  scrollY: function(node) {
    node=El.get(node);
    if (node) return node.scrollTop;
    if (typeof(window.pageYOffset) != "undefined") return window.pageYOffset;
    if (document.body && typeof(document.body.scrollTop) != "undefined") return document.body.scrollTop;
    if (document.documentElement && typeof(document.documentElement.scrollTop) != "undefined") return document.documentElement.scrollTop;
  },

  /**
   * get style property of an element
   * node.style refers to inline style only and not CSS set properties
   */
  style: function (el, name) {
    if (el.style[name]) return el.style[name];
    else if (el.currentStyle) return el.currentStyle[name];
    else if (document.defaultView && document.defaultView.getComputedStyle) {
        name = name.replace(/([A-Z])/g, "-$1");
        name = name.toLowerCase();
        s = document.defaultView.getComputedStyle(el, "");
        return s && s.getPropertyValue(name);
    } 
    else return null;
  },

  /**
   * Get next brother element, maybe by name and/or class
   */
  next: function (node, nodeName, className) {
    while (node=node.nextSibling) if (El.match(node, nodeName, className))  break;
    return node;
  },

  /**
   * Get previous brother element, maybe by name and/or class
   */
  prev: function (node, nodeName, className) {
    while (node=node.previousSibling) if (El.match(node, nodeName, className))  break;
    return node;
  },

  /**
   * get first element of a parent (and not firstChild, which could be text, comment), maybe filtered by name
   */
  first: function (parent, nodeName, className) {
    if (!parent || !parent.firstChild) return false;
    node=parent.firstChild;
    while(node && !El.match(node, nodeName, className)) node=node.nextSibling;
    return node;
  },

  /**
   * Give last element, maybe by name (but not last node, which could be only text)
   */
  last: function (parent, nodeName, className) {
    if (!parent || !parent.lastChild) return false;
    node=parent.lastChild;
    while(node && !El.match(node, nodeName, className)) node=node.previousSibling;
    return node;
  },

  focus: function(o) {
    o=El.get(o);
    if (!o || !o.focus) return false;
    o.focus();
  },

  /**
   * Get an element by id or reference
   */
  get: function (id) {
    if (!id) return id;
    if (id.nodeType == 1) return id;
    return document.getElementById(id);
  },
  /**
   * Test if a node is an element, with possible filters on name and class
   * Used by previous and next searches
   */
  match: function(node, nodeName, className) {
    if (node.nodeType != 1) return false;
    if (className && nodeName) return (
      (node.className.toLowerCase() == className.toLowerCase())
      && (node.nodeName.toLowerCase() == nodeName.toLowerCase())
    );
    if (className) return (node.className.toLowerCase() == className.toLowerCase());
    if (nodeName)  return (node.nodeName.toLowerCase() == nodeName.toLowerCase());
    return (node.nodeType == 1);
  },
  /**
   * Toggle on a className
   */
  toggle : function (o, className, toggle) {
    if (!o) o=this;
    if(!o) return false;
    if(!className) className=o.toggle;
    if(!className) className="hi";
    pattern=new RegExp("\\s*"+ className,"gim");
    if (toggle) return o.className=(o.className.replace(pattern, "") + " "+className);
    if(toggle == false) return o.className=(o.className.replace(pattern, ""));
    if (!o.className || o.className.search(pattern) < 0 ) return o.className = (o.className + " "+className);
    else return o.className=(o.className.replace(pattern, ""));
  },
  /**
   * Debug
   */
  props: function(o) {
    tmp='';
    for (x in o) tmp += x + "  " ;// ": " + o[x] + "\n";
    alert (tmp);
  },

  /**
   * Add event listener
   */
  addEvent: function(el, evType, fn, useCapture) {
    if (el.addEventListener) {
      el.addEventListener(evType, fn, useCapture);
      return true;
    }
    else if (el.attachEvent){
      el["e"+evType+fn] = fn;
      el[evType+fn] = function() { el["e"+evType+fn]( window.event ); }
      return el.attachEvent( "on"+evType, obj[evType+fn] );
    }
    return false;
  }

}

