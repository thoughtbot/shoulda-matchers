(function() {
  $(document).ready(function() {
    var animateElementsInView;
    if ($('.animate').length > 0) {
      animateElementsInView = function() {
        return $('.animate').each(function() {
          var element;
          element = $(this);
          if (element.visible(true, true)) {
            return element.addClass('animated');
          } else {
            return element.removeClass('animated');
          }
        });
      };
      animateElementsInView();
      return $(window).scroll(animateElementsInView);
    }
  });

}).call(this);
(function(e){e.fn.visible=function(t,n,r){var i=e(this).eq(0),s=i.get(0),o=e(window),u=o.scrollTop(),a=u+o.height(),f=o.scrollLeft(),l=f+o.width(),c=i.offset().top,h=c+i.height(),p=i.offset().left,d=p+i.width(),v=t===true?h:c,m=t===true?c:h,g=t===true?d:p,y=t===true?p:d,b=n===true?s.offsetWidth*s.offsetHeight:true,r=r?r:"both";if(r==="both")return!!b&&m<=a&&v>=u&&y<=l&&g>=f;else if(r==="vertical")return!!b&&m<=a&&v>=u;else if(r==="horizontal")return!!b&&y<=l&&g>=f}})(jQuery)
;
(function() {
  var buildEventNames, findEventId;

  buildEventNames = function(eventType) {
    var capitalizedEventType, eventNames;
    capitalizedEventType = eventType[0].toUpperCase() + eventType.slice(1);
    eventNames = ["" + eventType + "end", "o" + capitalizedEventType + "End", "webkit" + capitalizedEventType + "End", "ms" + capitalizedEventType + "End"];
    return eventNames.join(' ');
  };

  findEventId = function(event, eventType) {
    var _ref;
    return (_ref = event["" + eventType + "Name"]) != null ? _ref : event.originalEvent["" + eventType + "Name"];
  };

  $.fn.listenToEndOf = function(eventType, expectedEventId, callback) {
    var eventNames;
    eventNames = buildEventNames(eventType);
    return this.on(eventNames, function(event) {
      var actualEventId;
      actualEventId = findEventId(event, eventType);
      if (actualEventId === expectedEventId) {
        return callback();
      }
    });
  };

  $.fn.stopListeningToEndOf = function(eventType) {
    var eventNames;
    eventNames = buildEventNames(eventType);
    return this.off(eventNames);
  };

}).call(this);
(function() {
  var findLastElementToFinishAnimating, loopAnimation, playAnimation, presentation, restartAnimation, restartAnimationWhenFinished, stopAnimation;

  presentation = [][0];

  stopAnimation = function() {
    return presentation.removeClass('running').addClass('paused');
  };

  playAnimation = function() {
    return presentation.addClass('running').removeClass('paused');
  };

  findLastElementToFinishAnimating = function() {
    return presentation.find('.animation-two');
  };

  restartAnimationWhenFinished = function() {
    return findLastElementToFinishAnimating().stopListeningToEndOf('animation').listenToEndOf('animation', 'fadeOut', restartAnimation);
  };

  restartAnimation = function() {
    stopAnimation();
    return setTimeout(loopAnimation, 1000);
  };

  loopAnimation = function() {
    playAnimation();
    return restartAnimationWhenFinished();
  };

  $(document).ready(function() {
    presentation = $('.presentation');
    return setTimeout(loopAnimation, 300);
  });

}).call(this);
/* http://prismjs.com/download.html?themes=prism-twilight&languages=clike+ruby */

self="undefined"!=typeof window?window:"undefined"!=typeof WorkerGlobalScope&&self instanceof WorkerGlobalScope?self:{};var Prism=function(){var e=/\blang(?:uage)?-(?!\*)(\w+)\b/i,t=self.Prism={util:{encode:function(e){return e instanceof n?new n(e.type,t.util.encode(e.content),e.alias):"Array"===t.util.type(e)?e.map(t.util.encode):e.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/\u00a0/g," ")},type:function(e){return Object.prototype.toString.call(e).match(/\[object (\w+)\]/)[1]},clone:function(e){var n=t.util.type(e);switch(n){case"Object":var a={};for(var r in e)e.hasOwnProperty(r)&&(a[r]=t.util.clone(e[r]));return a;case"Array":return e.slice()}return e}},languages:{extend:function(e,n){var a=t.util.clone(t.languages[e]);for(var r in n)a[r]=n[r];return a},insertBefore:function(e,n,a,r){r=r||t.languages;var i=r[e],l={};for(var o in i)if(i.hasOwnProperty(o)){if(o==n)for(var s in a)a.hasOwnProperty(s)&&(l[s]=a[s]);l[o]=i[o]}return r[e]=l},DFS:function(e,n,a){for(var r in e)e.hasOwnProperty(r)&&(n.call(e,r,e[r],a||r),"Object"===t.util.type(e[r])?t.languages.DFS(e[r],n):"Array"===t.util.type(e[r])&&t.languages.DFS(e[r],n,r))}},highlightAll:function(e,n){for(var a,r=document.querySelectorAll('code[class*="language-"], [class*="language-"] code, code[class*="lang-"], [class*="lang-"] code'),i=0;a=r[i++];)t.highlightElement(a,e===!0,n)},highlightElement:function(a,r,i){for(var l,o,s=a;s&&!e.test(s.className);)s=s.parentNode;if(s&&(l=(s.className.match(e)||[,""])[1],o=t.languages[l]),o){a.className=a.className.replace(e,"").replace(/\s+/g," ")+" language-"+l,s=a.parentNode,/pre/i.test(s.nodeName)&&(s.className=s.className.replace(e,"").replace(/\s+/g," ")+" language-"+l);var c=a.textContent;if(c){var g={element:a,language:l,grammar:o,code:c};if(t.hooks.run("before-highlight",g),r&&self.Worker){var u=new Worker(t.filename);u.onmessage=function(e){g.highlightedCode=n.stringify(JSON.parse(e.data),l),t.hooks.run("before-insert",g),g.element.innerHTML=g.highlightedCode,i&&i.call(g.element),t.hooks.run("after-highlight",g)},u.postMessage(JSON.stringify({language:g.language,code:g.code}))}else g.highlightedCode=t.highlight(g.code,g.grammar,g.language),t.hooks.run("before-insert",g),g.element.innerHTML=g.highlightedCode,i&&i.call(a),t.hooks.run("after-highlight",g)}}},highlight:function(e,a,r){var i=t.tokenize(e,a);return n.stringify(t.util.encode(i),r)},tokenize:function(e,n){var a=t.Token,r=[e],i=n.rest;if(i){for(var l in i)n[l]=i[l];delete n.rest}e:for(var l in n)if(n.hasOwnProperty(l)&&n[l]){var o=n[l];o="Array"===t.util.type(o)?o:[o];for(var s=0;s<o.length;++s){var c=o[s],g=c.inside,u=!!c.lookbehind,f=0,h=c.alias;c=c.pattern||c;for(var p=0;p<r.length;p++){var d=r[p];if(r.length>e.length)break e;if(!(d instanceof a)){c.lastIndex=0;var m=c.exec(d);if(m){u&&(f=m[1].length);var y=m.index-1+f,m=m[0].slice(f),v=m.length,k=y+v,b=d.slice(0,y+1),w=d.slice(k+1),N=[p,1];b&&N.push(b);var O=new a(l,g?t.tokenize(m,g):m,h);N.push(O),w&&N.push(w),Array.prototype.splice.apply(r,N)}}}}}return r},hooks:{all:{},add:function(e,n){var a=t.hooks.all;a[e]=a[e]||[],a[e].push(n)},run:function(e,n){var a=t.hooks.all[e];if(a&&a.length)for(var r,i=0;r=a[i++];)r(n)}}},n=t.Token=function(e,t,n){this.type=e,this.content=t,this.alias=n};if(n.stringify=function(e,a,r){if("string"==typeof e)return e;if("[object Array]"==Object.prototype.toString.call(e))return e.map(function(t){return n.stringify(t,a,e)}).join("");var i={type:e.type,content:n.stringify(e.content,a,r),tag:"span",classes:["token",e.type],attributes:{},language:a,parent:r};if("comment"==i.type&&(i.attributes.spellcheck="true"),e.alias){var l="Array"===t.util.type(e.alias)?e.alias:[e.alias];Array.prototype.push.apply(i.classes,l)}t.hooks.run("wrap",i);var o="";for(var s in i.attributes)o+=s+'="'+(i.attributes[s]||"")+'"';return"<"+i.tag+' class="'+i.classes.join(" ")+'" '+o+">"+i.content+"</"+i.tag+">"},!self.document)return self.addEventListener?(self.addEventListener("message",function(e){var n=JSON.parse(e.data),a=n.language,r=n.code;self.postMessage(JSON.stringify(t.util.encode(t.tokenize(r,t.languages[a])))),self.close()},!1),self.Prism):self.Prism;var a=document.getElementsByTagName("script");return a=a[a.length-1],a&&(t.filename=a.src,document.addEventListener&&!a.hasAttribute("data-manual")&&document.addEventListener("DOMContentLoaded",t.highlightAll)),self.Prism}();"undefined"!=typeof module&&module.exports&&(module.exports=Prism);;
Prism.languages.clike={comment:[{pattern:/(^|[^\\])\/\*[\w\W]*?\*\//g,lookbehind:!0},{pattern:/(^|[^\\:])\/\/.*?(\r?\n|$)/g,lookbehind:!0}],string:/("|')(\\?.)*?\1/g,"class-name":{pattern:/((?:(?:class|interface|extends|implements|trait|instanceof|new)\s+)|(?:catch\s+\())[a-z0-9_\.\\]+/gi,lookbehind:!0,inside:{punctuation:/(\.|\\)/}},keyword:/\b(if|else|while|do|for|return|in|instanceof|function|new|try|throw|catch|finally|null|break|continue)\b/g,"boolean":/\b(true|false)\b/g,"function":{pattern:/[a-z0-9_]+\(/gi,inside:{punctuation:/\(/}},number:/\b-?(0x[\dA-Fa-f]+|\d*\.?\d+([Ee]-?\d+)?)\b/g,operator:/[-+]{1,2}|!|<=?|>=?|={1,3}|&{1,2}|\|?\||\?|\*|\/|\~|\^|\%/g,ignore:/&(lt|gt|amp);/gi,punctuation:/[{}[\];(),.:]/g};;
Prism.languages.ruby=Prism.languages.extend("clike",{comment:/#[^\r\n]*(\r?\n|$)/g,keyword:/\b(alias|and|BEGIN|begin|break|case|class|def|define_method|defined|do|each|else|elsif|END|end|ensure|false|for|if|in|module|new|next|nil|not|or|raise|redo|require|rescue|retry|return|self|super|then|throw|true|undef|unless|until|when|while|yield)\b/g,builtin:/\b(Array|Bignum|Binding|Class|Continuation|Dir|Exception|FalseClass|File|Stat|File|Fixnum|Fload|Hash|Integer|IO|MatchData|Method|Module|NilClass|Numeric|Object|Proc|Range|Regexp|String|Struct|TMS|Symbol|ThreadGroup|Thread|Time|TrueClass)\b/,constant:/\b[A-Z][a-zA-Z_0-9]*[?!]?\b/g}),Prism.languages.insertBefore("ruby","keyword",{regex:{pattern:/(^|[^/])\/(?!\/)(\[.+?]|\\.|[^/\r\n])+\/[gim]{0,3}(?=\s*($|[\r\n,.;})]))/g,lookbehind:!0},variable:/[@$]+\b[a-zA-Z_][a-zA-Z_0-9]*[?!]?\b/g,symbol:/:\b[a-zA-Z_][a-zA-Z_0-9]*[?!]?\b/g});;
(function() {
  $(document).ready(function() {
    var allAccordionTabs, allContentAreas, allSidebarTabs, allTabs, tabsContainer, whenTabClicked;
    tabsContainer = $('.js-vertical-tabs-container');
    allSidebarTabs = $('.js-vertical-tab');
    allAccordionTabs = $('.js-vertical-tab-accordion-heading');
    allTabs = $([]).add(allSidebarTabs).add(allAccordionTabs);
    allContentAreas = $('.js-vertical-tab-content');
    whenTabClicked = function(event) {
      var selectedContentArea, selectedTabs, tabName;
      if (!allAccordionTabs.is(':visible')) {
        event.preventDefault();
      }
      tabName = $(this).attr('href').slice(1);
      selectedContentArea = $("#" + tabName + " .js-vertical-tab-content");
      selectedTabs = $("[href='#" + tabName + "']");
      allContentAreas.removeClass('is-active');
      selectedContentArea.addClass('is-active');
      allTabs.removeClass('is-active');
      return selectedTabs.addClass('is-active');
    };
    return allTabs.on('click', whenTabClicked);
  });

}).call(this);
