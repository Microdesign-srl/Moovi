// Versione per il Cache Busting degli script
var cacheVersion = (new Date()).getTime();

// Injection dello script nell'head
function injectScript(src) {
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.src = src + "?v=" + cacheVersion;
    document.head.appendChild(script);
}

// Injection del link nell'head
function injectStyle(src) {
    var link = document.createElement("link");
    link.href = src + "?v=" + cacheVersion;
    link.rel = "stylesheet";
    document.head.appendChild(link);
}