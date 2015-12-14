(function(){this.NANO={INTERACTIVE:2,UPDATE:1,DISABLED:0}}).call(this),function(){var t=function(t,n){return function(){return t.apply(n,arguments)}};this.Handlers=function(){function n(n,i){this.bus=n,this.fragment=null!=i?i:document,this.handleLinks=t(this.handleLinks,this),this.updateLinks=t(this.updateLinks,this),this.updateStatus=t(this.updateStatus,this),this.bus.on("rendered",this.updateStatus),this.bus.on("rendered",this.updateLinks),this.bus.on("rendered",this.handleLinks),this.bus.on("rendered",this.handleClose),this.bus.on("rendered",this.handleMini)}return n.prototype.updateStatus=function(t){var n;n=this.fragment.queryAll(".statusicon"),n.forEach(function(n){var i;switch(n.className=n.className.replace(/good|bad|average/g,""),t.config.status){case NANO.INTERACTIVE:i="good";break;case NANO.UPDATE:i="average";break;default:i="bad"}n.classList.add(i)})},n.prototype.updateLinks=function(t){var n;n=this.fragment.queryAll(".link"),t.config.status!==NANO.INTERACTIVE&&n.forEach(function(t){t.className="link disabled"})},n.prototype.handleLinks=function(t){var n;n=function(n){var i,e;i=this.data("action"),e=JSON.parse(this.data("params")),null!=i&&null!=e&&t.config.status===NANO.INTERACTIVE&&(this.classList.add("pending"),nanoui.bycall(i,e))},this.fragment.queryAll(".link.active").forEach(function(t){t.on("click",n)})},n.prototype.handleClose=function(t){var n,i;i=function(t){return nanoui.close()},n=document.queryAll(".close"),n.forEach(function(t){t.on("click",i)})},n.prototype.handleMini=function(t){var n,i;i=function(t){return nanoui.winset("is-minimized","true")},n=document.queryAll(".minimize"),n.forEach(function(t){t.on("click",i)})},n}()}.call(this),function(){this.helpers={link:function(t,n,i,e,a,s){return null==t&&(t=""),null==n&&(n=""),null==i&&(i=""),null==e&&(e={}),null==a&&(a=""),null==s&&(s=""),e=JSON.stringify(e),n&&(n="<i class='pending fa fa-fw fa-spinner fa-pulse'></i><i class='main fa fa-fw fa-"+n+"'></i>",s+=" iconed"),a?"<div unselectable='on' class='link inactive "+a+" "+s+"'>"+n+t+"</div>":"<div unselectable='on' class='link active "+s+"' data-action='"+i+"' data-params='"+e+"'>"+n+t+"</div>"},bar:function(t,n,i,e,a){var s;return null==t&&(t=0),null==n&&(n=0),null==i&&(i=100),null==e&&(e=""),null==a&&(a=""),i>n?n>t?t=n:t>i&&(t=i):t>n?t=n:i>t&&(t=i),s=Math.round((t-n)/(i-n)*100),"<div class='bar'> <span class='barFill "+e+"' style='width: "+s+"%;'></span> <span class='barText'>"+a+"</span> </div>"},round:function(t){return Math.round(t)},fixed:function(t,n){return null==n&&(n=1),Number(Math.round(t+"e"+n)+"e-"+n)},floor:function(t){return Math.floor(t)},ceil:function(t){return Math.ceil(t)}}}.call(this),function(){document.when("ready",function(t){return function(){var n;n={},t.nanoui=new t.NanoUI(n,document),t.handlers=new t.Handlers(n,document),n.emit("memes"),t.NanoBus=n}}(this))}.call(this),function(){var t=function(t,n){return function(){return t.apply(n,arguments)}};this.NanoUI=function(){function n(n,i){return this.bus=n,this.fragment=null!=i?i:document,this.winset=t(this.winset,this),this.close=t(this.close,this),this.bycall=t(this.bycall,this),this.render=t(this.render,this),this.update=t(this.update,this),this.serverUpdate=t(this.serverUpdate,this),this.bus.on("serverUpdate",this.serverUpdate),this.bus.on("update",this.update),this.bus.on("render",this.render),this.bus.on("memes",this.render),this.initialized=!1,this.layoutRendered=!1,this.contentRendered=!1,this.data={},this.initialData=JSON.parse(this.fragment.query("#data").data("initial")),null==this.initialData&&("data"in this.initialData||"config"in this.initalData)?void this.bus.emit("error","Initial data did not load correctly."):void 0}return n.prototype.serverUpdate=function(t){var n,i,e;try{n=JSON.parse(t)}catch(e){return i=e,void NanoBus.emit("error",i.fileName+":"+i.lineNumber+" "+i.message)}this.bus.emit("update",n)},n.prototype.update=function(t){null==t.data&&(null!=this.data.data?t.data=this.data.data:t.data={}),this.data=t,this.initialized&&this.bus.emit("render",this.data),this.bus.emit("updated")},n.prototype.render=function(t){var n,i,e,a;this.initialized||(t=this.initialData);try{(!this.layoutRendered||t.config.autoUpdateLayout)&&(a=this.fragment.query("#layout"),a.innerHTML=TMPL[t.config.templates.layout](t.data,t.config,helpers),this.layoutRendered=!0,this.bus.emit("layoutRendered")),(!this.contentRendered||t.config.autoUpdateContent)&&(n=this.fragment.query("#content"),n.innerHTML=TMPL[t.config.templates.content](t.data,t.config,helpers),this.contentRendered=!0,this.bus.emit("contentRendered"))}catch(e){return i=e,void this.bus.emit("error",i.fileName+":"+i.lineNumber+" "+i.message)}this.bus.emit("rendered",t),this.initialized||(this.initialized=!0,this.bus.emit("initialized"))},n.prototype.bycall=function(t,n){return null==n&&(n={}),n.src=this.data.config.ref,n.nano=t,location.href=util.href(null,n)},n.prototype.close=function(t){return null==t&&(t={}),t.command="nanoclose "+this.data.config.ref,this.winset("is-visible","false"),location.href=util.href("winset",t)},n.prototype.winset=function(t,n,i){return null==i&&(i={}),i[this.data.config.window.ref+"."+t]=n,location.href=util.href("winset",i)},n.prototype.setPos=function(t,n){return this.winset("pos",t+","+n)},n.prototype.setSize=function(t,n){return this.winset("size",t+","+n)},n}()}.call(this),function(){this.util={extend:function(t,n){return Object.keys(n).forEach(function(i){var e;e=n[i],e&&"[object Object]"===Object.prototype.toString.call(e)?(t[i]=t[i]||{},util.extend(t[i],e)):t[i]=e}),t},href:function(t,n){return null==t&&(t=""),null==n&&(n={}),t=new Url("byond://"+t),util.extend(t.query,n),t}}}.call(this);