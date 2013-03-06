socketio = require "socket.io"
NYTArticles = require "./nyt-article"
TwitterMonitor = require "./twitter-monitor"
config = require "./config"
geocode = require "./geocoder"
async = require "async"

nyt = new NYTArticles(config.nyt)

io = socketio.listen(8100)
io.set( 'origins', '*:*' )

receive = (tweet,nytUrls) ->
    async.parallel [
        (cb) =>
            nyt.articleByUrl nytUrls[0], (articleData) ->
                console.log "callback for " + nytUrls[0]
                if !articleData
                    console.log nytUrls[0]
                    return cb(null,null)
                if !articleData.geo_facet
                    console.log "No location for article"
                    return cb(null, {article:articleData,location:{lat:40.75587, lng: -73.99048}})
                else
                    console.log "Getting location"
                    nyt.locationByName articleData.geo_facet[0], (locationData) ->
                        location = null
                        if !locationData
                            console.log "No geocode info for " + articleData.geo_facet[0]
                        else
                            location = {lat: locationData.geocode.latitude, lng: locationData.geocode.longitude}
                        return cb(null, {article:articleData, location: location})
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
                to: results[1]
            })
    #console.log tweet, nytUrls



monitor = new TwitterMonitor()
monitor.start(receive)


#nyt.articleByUrl "http://www.nytimes.com/2012/11/20/world/middleeast/hamas-strengthens-as-palestinian-authority-weakens.html", (data) ->
 #   console.log data
  #  nyt.locationByName data.geo_facet[0], (data) ->
   #     console.log data



