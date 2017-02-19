jQuery(function(a){"use strict";if(!Modernizr.touch){paraxify(".paraxify")}a("[data-scroll]").on("click",function(b){b.preventDefault(),console.log(a(this).data("scroll")),a("html, body").animate({scrollTop:a(a(this).data("scroll")).offset().top},700)}),function(b){/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(b)||/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(b.substr(0,4))||a("#text-rotating").length&&a("#text-rotating").Morphext({animation:"bounceIn",separator:",",speed:4e3})}(navigator.userAgent||navigator.vendor||window.opera),a("#particles").length&&a("#particles").particleground({dotColor:"rgba(255,255,255,0.5)",lineColor:"rgba(255,255,255,0.2)",density:1e4})}),!function(){"use strict";function a(a,b){if(!(a instanceof b))throw new TypeError("Cannot call a class as a function")}var b=function(){function a(a,b){for(var c=0;c<b.length;c++){var d=b[c];d.enumerable=d.enumerable||!1,d.configurable=!0,"value"in d&&(d.writable=!0),Object.defineProperty(a,d.key,d)}}return function(b,c,d){return c&&a(b.prototype,c),d&&a(b,d),b}}();!function(){var c=Object.create(null);c.current=null,c.OFFSET=80,c.initialScrollPos=-1,c.initialTouchPos=-1;var d=function(){return document.documentElement.clientWidth},e=function(){return document.documentElement.clientHeight},f=function(a){var b=a.getBoundingClientRect(),c=document.documentElement,d=window;return{top:b.top+d.pageYOffset-c.clientTop,left:b.left+d.pageXOffset-c.clientLeft}},g=function(a,b,c){var d=function a(d){d.target.removeEventListener(b,a),c()};a.addEventListener(b,d)};c.setup=function(){for(var a=document.querySelectorAll("img[data-action='zoom']"),b=0;b<a.length;b++)a[b].addEventListener("click",c.prepareZoom)},c.prepareZoom=function(a){return document.body.classList.contains("zoom-overlay-open")?void 0:a.metaKey||a.ctrlKey?void window.open(a.target.getAttribute("data-original")||a.target.src,"_blank"):void(a.target.width>=d()-c.OFFSET||(c.closeCurrent(!0),c.current=new i(a.target),c.current.zoom(),c.addCloseListeners()))},c.closeCurrent=function(a){null!=c.current&&(a?c.current.dispose():c.current.close(),c.removeCloseListeners(),c.current=null)},c.addCloseListeners=function(){document.addEventListener("scroll",c.handleScroll),document.addEventListener("keyup",c.handleKeyup),document.addEventListener("touchstart",c.handleTouchStart),document.addEventListener("click",c.handleClick,!0)},c.removeCloseListeners=function(){document.removeEventListener("scroll",c.handleScroll),document.removeEventListener("keyup",c.handleKeyup),document.removeEventListener("touchstart",c.handleTouchStart),document.removeEventListener("click",c.handleClick,!0)},c.handleScroll=function(){-1==c.initialScrollPos&&(c.initialScrollPos=window.pageYOffset);var a=Math.abs(c.initialScrollPos-window.pageYOffset);a>=40&&c.closeCurrent()},c.handleKeyup=function(a){27==a.keyCode&&c.closeCurrent()},c.handleTouchStart=function(a){var b=a.touches[0];null!=b&&(c.initialTouchPos=b.pageY,a.target.addEventListener("touchmove",c.handleTouchMove))},c.handleTouchMove=function(a){var b=a.touches[0];null!=b&&Math.abs(b.pageY-c.initialTouchPos)>10&&(c.closeCurrent(),a.target.removeEventListener("touchmove",c.handleTouchMove))},c.handleClick=function(){c.closeCurrent()};var h=function b(c,d){a(this,b),this.w=c,this.h=d},i=function(){function i(b){a(this,i),this.img=b,this.preservedTransform=b.style.transform,this.wrap=null,this.overlay=null}return b(i,[{key:"forceRepaint",value:function(){this.img.offsetWidth}},{key:"zoom",value:function(){var a=new h(this.img.naturalWidth,this.img.naturalHeight);this.wrap=document.createElement("div"),this.wrap.classList.add("zoom-img-wrap"),this.img.parentNode.insertBefore(this.wrap,this.img),this.wrap.appendChild(this.img),this.img.classList.add("zoom-img"),this.img.setAttribute("data-action","zoom-out"),this.overlay=document.createElement("div"),this.overlay.classList.add("zoom-overlay"),document.body.appendChild(this.overlay),this.forceRepaint();var b=this.calculateScale(a);this.forceRepaint(),this.animate(b),document.body.classList.add("zoom-overlay-open")}},{key:"calculateScale",value:function(a){var b=a.w/this.img.width,f=d()-c.OFFSET,g=e()-c.OFFSET,h=a.w/a.h,i=f/g;return a.w<f&&a.h<g?b:i>h?g/a.h*b:f/a.w*b}},{key:"animate",value:function(a){var b=f(this.img),c=window.pageYOffset,g=d()/2,h=c+e()/2,i=b.left+this.img.width/2,j=b.top+this.img.height/2,k=g-i,l=h-j,m=0,n="scale("+a+")",o="translate3d("+k+"px, "+l+"px, "+m+"px)";this.img.style.transform=n,this.wrap.style.transform=o}},{key:"dispose",value:function(){null!=this.wrap&&null!=this.wrap.parentNode&&(this.img.classList.remove("zoom-img"),this.img.setAttribute("data-action","zoom"),this.wrap.parentNode.insertBefore(this.img,this.wrap),this.wrap.parentNode.removeChild(this.wrap),document.body.removeChild(this.overlay),document.body.classList.remove("zoom-overlay-transitioning"))}},{key:"close",value:function(){var a=this;document.body.classList.add("zoom-overlay-transitioning"),this.img.style.transform=this.preservedTransform,0===this.img.style.length&&this.img.removeAttribute("style"),this.wrap.style.transform="none",g(this.img,"transitionend",function(){a.dispose(),document.body.classList.remove("zoom-overlay-open")})}}]),i}();document.addEventListener("DOMContentLoaded",function(){c.setup()})}()}();

function timer(min, type, callback) {
    var timer_install = document.querySelector('[data-info="' + type + '"]');
    var timer_time = document.querySelector('[data-info="' + type + '"]');
    if (timer_install) {
        ti(timer_install, min);
    }
    else if (timer_time) {
        ti(timer_time, min);
    }
    function ti(time, min) {
        var sec = 0;
        var timer = setInterval(function () {
            if (sec < 0) {
                min--;
                sec = 59;
            }
            time.innerText =
                ((min < 10) ? '0' + min : min) +
                ':' +
                ((sec < 10) ? '0' + sec : sec);
            if (sec == 0 && min == 0) {
                callback(time);
                clearInterval(timer);
            }
            sec--;
        }, 1000);
    }
}

var ssh = document.querySelector('#ssh');
if (ssh) {
    ssh.addEventListener('click', req);
}

function req() {

    var self = this;

    if (document.querySelector('#req')) {
        self.removeEventListener('click', req);
        self.innerHTML = '<span class="fa fa-spinner fa-pulse fa-fw"></span>';
    }

    var domain, ip, root = '';

    var req_domain = document.querySelector('input[name="req_domain"]');
    if (req_domain && req_domain.value && /^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](?:\.[a-zA-Z]{2,})+$/.test(req_domain.value)){
        req_domain.style.background = '#fff';
        domain = req_domain.value.toLowerCase();
    }
    else {
        req_domain.style.background = '#f7d6d6';
    }

    var req_ip = document.querySelector('input[name="req_ip"]');
    if (req_ip && req_ip.value && /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(req_ip.value)) {
        req_ip.style.background = '#fff';
        ip = req_ip.value;
    }
    else {
        req_ip.style.background = '#f7d6d6';
    }

    var req_root = document.querySelector('input[name="req_root"]');
    if (req_root && req_root.value){
        req_root.style.background = '#fff';
        root = req_root.value;
    }
    else {
        req_root.style.background = '#f7d6d6';
    }

    if (!domain || !ip || !root) {
        self.addEventListener('click', req);
        self.innerHTML = 'Установить';
        return;
    }

    var pass = generate(7);
    var theme = 'drogo';

    var http = new XMLHttpRequest();
    var params =
        'domain=' + domain +
        '&ip=' + ip +
        '&root=' + root +
        '&theme=' + theme +
        '&pass=' + pass;
    http.open('POST', 'https://ssh.cinemapress.org', true);
    http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    http.onreadystatechange = function() {
        if (http.readyState == 4 && http.status == 200) {
            var info_block = document.querySelectorAll('.info_block');
            if (info_block) {
                for (var i = 0; i < info_block.length; i++) {
                    info_block[i].style.display = 'none';
                }
            }
            if (http.responseText == 'OK' || http.responseText == 'APACHE') {
                document.querySelector('#info_install').style.display = 'block';
                document.querySelector('#req').style.display = 'none';
                document.querySelector('#user').style.display = 'block';
                document.querySelector('input[name="login"]').value = domain;
                document.querySelector('input[name="password"]').value = pass;
                document.querySelector('#go').innerHTML = '<span class="fa fa-spinner fa-pulse fa-fw"></span> Сохраните этот пароль!';
                document.querySelector('#info_mess').innerHTML = '<span class="fa fa-plug"></span> <a href="/article/kak-soedinit-domen-s-serverom.html" target="_blank">Пропишите DNS</a><span class="hidden-xs">, пока устанавливается!</span>';
                timer(10, 'install', function (time) {
                    time.innerHTML = '<span class="text-success">OK</span>';
                    self.addEventListener('click', req);
                    document.querySelector('#go').setAttribute('href', 'http://' + domain + '/admin');
                    document.querySelector('#go').setAttribute('target', '_blank');
                    document.querySelector('#go').innerHTML = 'Перейти в админ-панель';
                });
                if (http.responseText == 'APACHE') {
                    setTimeout(function () {
                        document.querySelector('#info_mess').innerHTML = '<span class="fa fa-plug"></span> На сервере установлен Apache2, возможны проблемы!';
                    }, 60000);
                }
            }
            else if (http.responseText == 'DEBIAN') {
                document.querySelector('#info_debian').style.display = 'block';
                self.addEventListener('click', req);
                self.innerHTML = 'Установить';
            }
            else if (http.responseText == 'TIME') {
                document.querySelector('#info_time').style.display = 'block';
                timer(1, 'time', function () {
                    self.addEventListener('click', req);
                    self.innerHTML = 'Установить';
                });
            }
            else {
                document.querySelector('#info_connect').style.display = 'block';
                self.addEventListener('click', req);
                self.innerHTML = 'Установить';
            }
        }
    };
    http.send(params);
}
function generate(len)
{
    var ints = [0,1,2,3,4,5,6,7,8,9];
    var chars = ['na','bo','co','do','re','fe','ge','hi','ka','ko','mo','no','vo','po','so','si','to','wi','ya'];
    var out = '';
    for (var i = 0; i < len; i++){
        var ch = Math.random();
        if (ch < 0.5) {
            out += ints[Math.floor(Math.random()*ints.length)];
        }
        else{
            out += chars[Math.floor(Math.random()*chars.length)];
        }
    }
    return out;
}