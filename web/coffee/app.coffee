requirejs.config
    baseUrl: "/"
    shim:
        "jslib/leaflet":
            deps: ["jquery"]
            exports: "L"
        "jslib/jsbezier":
            exports: "jsBezier"
    paths:
        "jquery":"//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min"
        "socketio":"/socket.io/socket.io"
 
requirejs ["./js/map/mapdisplay","jquery"], (MapDisplay) ->
    map = new MapDisplay $("#map")
    require ["socketio"], () ->
        socket = io.connect('http://' + window.location.hostname + ':' + window.location.port)
        socket.on "connect", () ->
            $("#liConnecting").html("<a>Connected, awaiting tweets</a>")
        socket.on "tweet", (tweet) ->
            $("#liConnecting").remove()
            map.drawLine tweet.from, tweet.to 
            title = "Could not trace to article"
            li = $("<li><a href='#{tweet.tweet.entities.urls[0].expanded_url}' target='_blank'>#{tweet.tweet.text}<p></p></a></li>")
            from = tweet.article?.geo_facet?[0] || "NYC (assumed)"
            location = tweet.tweet.geo || tweet.tweet.user.location
            $("p",li).html("<p>#{from} -> #{location}")
            li.insertAfter($("#header"))
