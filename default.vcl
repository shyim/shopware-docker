vcl 4.0;

import std;

backend default {
    .host = "app_shopware";
    .port = "80";
}

# ACL for purgers IP.
# Provide here IP addresses that are allowed to send PURGE requests.
# PURGE requests will be sent by the backend.
acl purgers {
    "127.0.0.1";
    "localhost";
    "::1";
}

sub vcl_recv {
    # Mitigate httpoxy application vulnerability, see: https://httpoxy.org/
    unset req.http.Proxy;

    # Strip query strings only needed by browser javascript. Customize to used tags.
    if (req.url ~ "(\?|&)(pk_campaign|piwik_campaign|pk_kwd|piwik_kwd|pk_keyword|pixelId|kwid|kw|adid|chl|dv|nk|pa|camid|adgid|cx|ie|cof|siteurl|utm_[a-z]+|_ga|gclid)=") {
        # see rfc3986#section-2.3 "Unreserved Characters" for regex
        set req.url = regsuball(req.url, "(pk_campaign|piwik_campaign|pk_kwd|piwik_kwd|pk_keyword|pixelId|kwid|kw|adid|chl|dv|nk|pa|camid|adgid|cx|ie|cof|siteurl|utm_[a-z]+|_ga|gclid)=[A-Za-z0-9\-\_\.\~]+&?", "");
    }
    set req.url = regsub(req.url, "(\?|\?&|&)$", "");

    # Normalize query arguments
    set req.url = std.querysort(req.url);

    # Set a header announcing Surrogate Capability to the origin
    set req.http.Surrogate-Capability = "shopware=ESI/1.0";

    # Make sure that the client ip is forward to the client.
    if (req.http.x-forwarded-for) {
        set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
    } else {
        set req.http.X-Forwarded-For = client.ip;
    }

    # Handle PURGE
    if (req.method == "PURGE") {
        if (!client.ip ~ purgers) {
            return (synth(405, "Method not allowed"));
        }

        return (purge);
    }

    # Handle BAN
    if (req.method == "BAN") {
        if (!client.ip ~ purgers) {
            return (synth(405, "Method not allowed"));
        }

        if (req.http.X-Shopware-Invalidates) {
            ban("obj.http.X-Shopware-Cache-Id ~ " + ";" + req.http.X-Shopware-Invalidates + ";");
            return (synth(200, "BAN of content connected to the X-Shopware-Cache-Id (" + req.http.X-Shopware-Invalidates + ") done."));
        } else {
            ban("req.url ~ "+req.url);
            return (synth(200, "BAN URLs containing (" + req.url + ") done."));
        }
    }

    # Normalize Accept-Encoding header
    # straight from the manual: https://www.varnish-cache.org/docs/3.0/tutorial/vary.html
    if (req.http.Accept-Encoding) {
        if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
            # No point in compressing these
            unset req.http.Accept-Encoding;
        } elsif (req.http.Accept-Encoding ~ "gzip") {
            set req.http.Accept-Encoding = "gzip";
        } elsif (req.http.Accept-Encoding ~ "deflate") {
            set req.http.Accept-Encoding = "deflate";
        } else {
            # unkown algorithm
            unset req.http.Accept-Encoding;
        }
    }

    # Fix ConflictingHeadersException with opera mini
    # https://github.com/contao/standard-edition/issues/45
    if (req.http.Forwarded) {
        unset req.http.Forwarded;
    }

    if (req.method != "GET" &&
        req.method != "HEAD" &&
        req.method != "PUT" &&
        req.method != "POST" &&
        req.method != "TRACE" &&
        req.method != "OPTIONS" &&
        req.method != "DELETE") {
        /* Non-RFC2616 or CONNECT which is weird. */
        return (pipe);
    }

    # We only deal with GET and HEAD by default
    if (req.method != "GET" && req.method != "HEAD") {
        return (pass);
    }

    # Don't cache Authenticate & Authorization
    if (req.http.Authenticate || req.http.Authorization) {
        return (pass);
    }

    # Don't cache selfhealing-redirect
    if (req.http.Cookie ~ "ShopwarePluginsCoreSelfHealingRedirect") {
        return (pass);
    }

    # Always pass these paths directly to php without caching
    # Note: virtual URLs might bypass this rule (e.g. /en/checkout)
    if (req.url ~ "^/(checkout|account|backend)(/.*)?$") {
        return (pass);
    }
    
    # Workaround for Basket Widget Caching and Compare. Will be fixed with https://issues.shopware.com/issues/SW-23673
    if (req.url ~ "^/\?module=widgets&controller=checkout&action=info$" || req.url ~ "^/\?module=widgets&controller=compare$") {
        return (pass);
    }

    return (hash);
}

sub vcl_hash {
    ## normalize shop and currency cookie in hash to improve hitrate
    if (req.http.cookie ~ "shop=") {
        hash_data("+shop=" + regsub(req.http.cookie, "^.*?shop=([^;]*);*.*$", "\1"));
    } else {
        hash_data("+shop=1");
    }

    if (req.http.cookie ~ "currency=") {
        hash_data("+currency=" + regsub(req.http.cookie, "^.*?currency=([^;]*);*.*$", "\1"));
    } else {
        hash_data("+currency=1");
    }

    if (req.http.cookie ~ "x-cache-context-hash=") {
        hash_data("+context=" + regsub(req.http.cookie, "^.*?x-cache-context-hash=([^;]*);*.*$", "\1"));
    }
}

sub vcl_hit {
    if (obj.http.X-Shopware-Allow-Nocache && req.http.cookie ~ "nocache=") {
        if (obj.http.X-Shopware-Allow-Nocache && req.http.cookie ~ "slt=") {
            set req.http.X-Cookie-Nocache = regsub(req.http.Cookie, "^.*?nocache=([^;]*);*.*$", "\1, slt");
        } else {
            set req.http.X-Cookie-Nocache = regsub(req.http.Cookie, "^.*?nocache=([^;]*);*.*$", "\1");
        }
        if (std.strstr(req.http.X-Cookie-Nocache, obj.http.X-Shopware-Allow-Nocache)) {
            return (pass);
        }
    }
}

sub vcl_backend_response {
    # Fix Vary Header in some cases
    # https://www.varnish-cache.org/trac/wiki/VCLExampleFixupVary
    if (beresp.http.Vary ~ "User-Agent") {
        set beresp.http.Vary = regsub(beresp.http.Vary, ",? *User-Agent *", "");
        set beresp.http.Vary = regsub(beresp.http.Vary, "^, *", "");
        if (beresp.http.Vary == "") {
            unset beresp.http.Vary;
        }
    }

    # Enable ESI only if the backend responds with an ESI header
    # Unset the Surrogate Control header and do ESI
    if (beresp.http.Surrogate-Control ~ "ESI/1.0") {
        unset beresp.http.Surrogate-Control;
        set beresp.do_esi = true;
        return (deliver);
    }

    # Respect the Cache-Control=private header from the backend
    if (
        beresp.http.Pragma        ~ "no-cache" ||
        beresp.http.Cache-Control ~ "no-cache" ||
        beresp.http.Cache-Control ~ "private"
    ) {
        set beresp.ttl = 0s;
        set beresp.http.X-Cacheable = "NO:Cache-Control=private";
        # set beresp.ttl = 120s;
        set beresp.uncacheable = true;
        return (deliver);
    }

    # strip the cookie before the image is inserted into cache.
    if (bereq.url ~ "\.(png|gif|jpg|swf|css|js)$") {
        unset beresp.http.set-cookie;
    }

    # Allow items to be stale if needed.
    set beresp.grace = 6h;

    # Save the bereq.url so bans work efficiently
    set beresp.http.x-url = bereq.url;
    set beresp.http.X-Cacheable = "YES";

    return (deliver);
}

sub vcl_deliver {
    ## we don't want the client to cache
    set resp.http.Cache-Control = "max-age=0, private";

    ## unset the headers, thus remove them from the response the client sees
    unset resp.http.X-Shopware-Allow-Nocache;
    unset resp.http.X-Shopware-Cache-Id;
    
    # remove link header, if session is already started to save client resources
    if (req.http.cookie ~ "session-") {
        unset resp.http.Link;
    }

    # Set a cache header to allow us to inspect the response headers during testing
    if (obj.hits > 0) {
        unset resp.http.set-cookie;
        set resp.http.X-Cache = "HIT";
    }  else {
        set resp.http.X-Cache = "MISS";
    }

    set resp.http.X-Cache-Hits = obj.hits;
}