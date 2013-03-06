socketio = require "socket.io"
NYTArticles = require "./nyt-article"
TwitterMonitor = require "./twitter-monitor"

geocode = require "./geocoder"
async = require "async"
express = require "express"
http = require "http"

app = express()
config = require("./config")

nyt = new NYTArticles(config.nyt)

happ = http.createServer(app)

app.use("/",express.static(__dirname+"/web"))




io = socketio.listen(happ).set("log level", 2)

happ.listen(6060)
#io.set( 'origins', '*:*' )

receive = (tweet,nytUrls) ->
    async.parallel [
        (cb) =>
            nyt.articleByUrl nytUrls[0], (articleData) ->
                console.log "callback for " + nytUrls[0]
                if !articleData
                    cb(null,{article:{},location:{lat:40.75587, lng: -73.99048}})
                    return
                if !articleData.geo_facet
                    console.log "No location for article"
                    return cb(null, {article:articleData,location:{lat:40.75587, lng: -73.99048}})
                else
                    console.log "Getting location"
                    geocode articleData.geo_facet[0], (loc) ->
                        location = {lat:40.75587, lng: -73.99048}
                        if loc && loc.results?.length > 0
                            location = loc.results[0].geometry.location
                        else
                            console.log "No geocode info for " + articleData.geo_facet[0]
                        cb(null, {article:articleData, location: location})
        ,
        (cb) =>
            console.log "got to callback?"
            geocode tweet.user.location, (loc) =>
                retLoc = null
                if loc && loc.results?.length > 0
                    retLoc = loc.results[0].geometry.location
                else "No geocode for " + tweet.user.location
                cb(null,retLoc)
    ], (err,results) =>
        console.log "done"
        if results[0] && results[0].article && results[1]
            console.log "Sending..."
            io.sockets.emit("tweet", {
                from: results[0].location
                to: results[1],
                tweet: tweet,
                article: results[0].article
            })
        else
            console.log "FAILED", results
    #console.log tweet, nytUrls



monitor = new TwitterMonitor()
#monitor.start(receive)

activeClients = 0

io.sockets.on 'connection', (socket) ->
    if activeClients == 0
        console.log "Receiving tweets"
        monitor.start(receive)
    activeClients++
    console.log "#{activeClients} active clients"

    socket.on "disconnect", () ->
        activeClients--
        console.log "#{activeClients} active clients"
        if activeClients == 0 
            console.log "Disconnecting stream"
            monitor.stop()





#nyt.articleByUrl "http://www.nytimes.com/2012/11/20/world/middleeast/hamas-strengthens-as-palestinian-authority-weakens.html", (data) ->
 #   console.log data
  #  nyt.locationByName data.geo_facet[0], (data) ->
   #     console.log data



