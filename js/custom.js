
jQuery(function ($) {
    'use strict';
    /*============================================
     Page Preloader
     ==============================================*/
    $(window).on('load', function () {
        $('#page-loader').fadeOut(500);
    });
    /*============================================
	Accordion
     ==============================================*/
    function toggleIcon(e) {
        $(e.target)
        .prev('.panel-heading')
        .find(".more-less")
        .toggleClass('ti-minus ti-plus');
    }
    $('.panel-group').on('hidden.bs.collapse', toggleIcon);
    $('.panel-group').on('shown.bs.collapse', toggleIcon);
    
    /*============================================
	FAQ
     ==============================================*/
    
    $('.faq-categories a').on('click', function(event) {
        event.preventDefault();

        $('html, body').animate({
            scrollTop: $($.attr(this, 'href')).offset().top
        }, 500);
        $('.faq-categories li').removeClass('active');
        $(this).parent().addClass('active');
    });
     /*============================================
	PARALLAX
     ==============================================*/
    if (!Modernizr.touch) {
        var myParaxify = paraxify('.paraxify');
    }
     /*============================================
	BACK TO TOP
     ==============================================*/

    $('[data-scroll]').on('click', function (e) {
        e.preventDefault();
        console.log($(this).data('scroll'));
        $('html, body').animate({
            scrollTop: $($(this).data('scroll')).offset().top
        }, 700);
    });
    /*============================================
	Counter
     ==============================================*/
    if ($('.count').length)
    {
        $('.count').counterUp({
            delay: 10,
            time: 1000
        });
    }
    /*============================================
     MAGNIFIC POPUP
     ==============================================*/
    $(document).ready(function () {
        if ($('.zoom').length) {
            $('.zoom').magnificPopup({
                disableOn: 100,
                type: 'image',
                mainClass: 'mfp-fade',
                removalDelay: 360,
                preloader: true,
                fixedContentPos: false
            });
        }

    });
    /*============================================
     OWL CAROUSAL
     ==============================================*/
    if ($('#about-slider').length)
    {
        $("#about-slider").owlCarousel({
            navigation: false, // Show next and prev buttons
            slideSpeed: 300,
            paginationSpeed: 400,
            singleItem: true
        });
    }
    /*============================================
     BACKGROUND SLIDER
     ==============================================*/
    if ($('.slider-bg').length){
        $(function() {
            $('body').vegas({
                slides: [
                    { src: 'images/blog-1.jpg' },
                    { src: 'images/blog-2.jpg' },
                    { src: 'images/blog-3.jpg' },
                    { src: 'images/blog-4.jpg' }
                ]
            });
        });
    }
    /*============================================
     TEXT ROTATOR
     ==============================================*/
    if($('#text-rotating').length){
        $("#text-rotating").Morphext({
            // The [in] animation type. Refer to Animate.css for a list of available animations.
            animation: "bounceIn",
            // An array of phrases to rotate are created based on this separator. Change it if you wish to separate the phrases differently (e.g. So Simple | Very Doge | Much Wow | Such Cool).
            separator: ",",
            // The delay between the changing of each phrase in milliseconds.
            speed: 4000
        });
    }
    /*============================================
     PARTICLE EFFECTS
     ==============================================*/
    if($('#particles').length) {
        $('#particles').particleground({
            dotColor: 'rgba(255,255,255,0.5)',
            lineColor: 'rgba(255,255,255,0.2)',
            density: 10000
        });
    }
});

/**
 * Pure JavaScript-only implementation of zoom.js.
 *
 * Original preamble:
 * zoom.js - It's the best way to zoom an image
 * @version v0.0.2
 * @link https://github.com/fat/zoom.js
 * @license MIT
 *
 * Needs a related CSS file to work. See the README at
 * https://github.com/nishanths/zoom.js for more info.
 *
 * The MIT License. Copyright © 2016 Nishanth Shanmugham.
 */
!function(){"use strict";function e(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}var t=function(){function e(e,t){for(var n=0;n<t.length;n++){var o=t[n];o.enumerable=o.enumerable||!1,o.configurable=!0,"value"in o&&(o.writable=!0),Object.defineProperty(e,o.key,o)}}return function(t,n,o){return n&&e(t.prototype,n),o&&e(t,o),t}}();!function(){var n=Object.create(null);n.current=null,n.OFFSET=80,n.initialScrollPos=-1,n.initialTouchPos=-1;var o=function(){return document.documentElement.clientWidth},i=function(){return document.documentElement.clientHeight},r=function(e){var t=e.getBoundingClientRect(),n=document.documentElement,o=window;return{top:t.top+o.pageYOffset-n.clientTop,left:t.left+o.pageXOffset-n.clientLeft}},a=function(e,t,n){var o=function e(o){o.target.removeEventListener(t,e),n()};e.addEventListener(t,o)};n.setup=function(){for(var e=document.querySelectorAll("img[data-action='zoom']"),t=0;t<e.length;t++)e[t].addEventListener("click",n.prepareZoom)},n.prepareZoom=function(e){return document.body.classList.contains("zoom-overlay-open")?void 0:e.metaKey||e.ctrlKey?void window.open(e.target.getAttribute("data-original")||e.target.src,"_blank"):void(e.target.width>=o()-n.OFFSET||(n.closeCurrent(!0),n.current=new l(e.target),n.current.zoom(),n.addCloseListeners()))},n.closeCurrent=function(e){null!=n.current&&(e?n.current.dispose():n.current.close(),n.removeCloseListeners(),n.current=null)},n.addCloseListeners=function(){document.addEventListener("scroll",n.handleScroll),document.addEventListener("keyup",n.handleKeyup),document.addEventListener("touchstart",n.handleTouchStart),document.addEventListener("click",n.handleClick,!0)},n.removeCloseListeners=function(){document.removeEventListener("scroll",n.handleScroll),document.removeEventListener("keyup",n.handleKeyup),document.removeEventListener("touchstart",n.handleTouchStart),document.removeEventListener("click",n.handleClick,!0)},n.handleScroll=function(){-1==n.initialScrollPos&&(n.initialScrollPos=window.pageYOffset);var e=Math.abs(n.initialScrollPos-window.pageYOffset);e>=40&&n.closeCurrent()},n.handleKeyup=function(e){27==e.keyCode&&n.closeCurrent()},n.handleTouchStart=function(e){var t=e.touches[0];null!=t&&(n.initialTouchPos=t.pageY,e.target.addEventListener("touchmove",n.handleTouchMove))},n.handleTouchMove=function(e){var t=e.touches[0];null!=t&&Math.abs(t.pageY-n.initialTouchPos)>10&&(n.closeCurrent(),e.target.removeEventListener("touchmove",n.handleTouchMove))},n.handleClick=function(){n.closeCurrent()};var s=function t(n,o){e(this,t),this.w=n,this.h=o},l=function(){function l(t){e(this,l),this.img=t,this.preservedTransform=t.style.transform,this.wrap=null,this.overlay=null}return t(l,[{key:"forceRepaint",value:function(){this.img.offsetWidth}},{key:"zoom",value:function(){var e=new s(this.img.naturalWidth,this.img.naturalHeight);this.wrap=document.createElement("div"),this.wrap.classList.add("zoom-img-wrap"),this.img.parentNode.insertBefore(this.wrap,this.img),this.wrap.appendChild(this.img),this.img.classList.add("zoom-img"),this.img.setAttribute("data-action","zoom-out"),this.overlay=document.createElement("div"),this.overlay.classList.add("zoom-overlay"),document.body.appendChild(this.overlay),this.forceRepaint();var t=this.calculateScale(e);this.forceRepaint(),this.animate(t),document.body.classList.add("zoom-overlay-open")}},{key:"calculateScale",value:function(e){var t=e.w/this.img.width,r=o()-n.OFFSET,a=i()-n.OFFSET,s=e.w/e.h,l=r/a;return e.w<r&&e.h<a?t:l>s?a/e.h*t:r/e.w*t}},{key:"animate",value:function(e){var t=r(this.img),n=window.pageYOffset,a=o()/2,s=n+i()/2,l=t.left+this.img.width/2,c=t.top+this.img.height/2,u=a-l,d=s-c,h=0,m="scale("+e+")",v="translate3d("+u+"px, "+d+"px, "+h+"px)";this.img.style.transform=m,this.wrap.style.transform=v}},{key:"dispose",value:function(){null!=this.wrap&&null!=this.wrap.parentNode&&(this.img.classList.remove("zoom-img"),this.img.setAttribute("data-action","zoom"),this.wrap.parentNode.insertBefore(this.img,this.wrap),this.wrap.parentNode.removeChild(this.wrap),document.body.removeChild(this.overlay),document.body.classList.remove("zoom-overlay-transitioning"))}},{key:"close",value:function(){var e=this;document.body.classList.add("zoom-overlay-transitioning"),this.img.style.transform=this.preservedTransform,0===this.img.style.length&&this.img.removeAttribute("style"),this.wrap.style.transform="none",a(this.img,"transitionend",function(){e.dispose(),document.body.classList.remove("zoom-overlay-open")})}}]),l}();document.addEventListener("DOMContentLoaded",function(){n.setup()})}()}();