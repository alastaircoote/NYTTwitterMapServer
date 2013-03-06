requirejs.config
    baseUrl: "/"
    shim:
        "jslib/leaflet":
            deps: ["jquery"]
            exports: "L"
        "jslib/jsbezier":
            exports: "jsBezier"
        "jslib/jq.color":
            deps: ["jquery"]
    paths:
        "jquery":"//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min"
        "socketio":"/socket.io/socket.io"
 
requirejs ["./js/map/mapdisplay","jquery"], (MapDisplay) ->
    map = new MapDisplay $("#map")
    require ["socketio"], () ->
        socket = io.connect('http://' + window.location.hostname + ':6060')
        socket.on "connect", () ->
            $("#liConnecting").html("<a>Connected, awaiting tweets</a>")
        socket.on "tweet", (tweet) ->
            $("#liConnecting").remove()
            baseHue = Math.floor(Math.random() * 30) * 12
            map.drawLine tweet.from, tweet.to, baseHue
            title = "Could not trace to article"
            li = $("<li><a href='#{tweet.tweet.entities.urls[0].expanded_url}' target='_blank'>#{tweet.tweet.text}<p></p></a><div style='clear:both'></div></li>")
            from = tweet.article?.geo_facet?[0] || "NYC (assumed)"

            if tweet.article && tweet.article.multimedia?.length
                images = tweet.article.multimedia.filter (m) -> m.type == "image"

                if images[0]
                    $("a",li).prepend("<img src='#{images[0].url}'/>")


            textcolor = $.Color({hue: baseHue, saturation: 0.26, lightness: 0.43, alpha: 1}).toHexString()
            li.append("<div class='colorbox' style='background:#{textcolor}'></div>")
            location = tweet.tweet.geo || tweet.tweet.user.location
            $("p",li).html("<p >#{from} -> #{location}")
            li.insertAfter($("#header"))
            if li.parent().children().length == 20
                li.parent().children().last().remove()
