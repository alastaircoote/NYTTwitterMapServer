twitter = require "twitter"
config = require "./config"
http = require "http"
async = require "async"

twit = new twitter(config.twitter)

class TwitterMonitor
    start: (@received) =>
        twit.stream 'statuses/filter', {track:"nytimes"}, (stream) =>
            @stream = stream
            stream.on "data", @receiveData
    receiveData: (data) =>
        if data.user.location == ''
            return

        async.parallel data.entities.urls.map((u) =>
            (cb) =>
                if !u.expanded_url
                    cb(null,"")
                @followUrl u.expanded_url, (finalUrl) ->
                    cb(null,finalUrl)

        ), (err,results) =>
            nytUrls = results.filter (url) ->
               # if url.indexOf "mobile.nytimes.com" > -1
               #     url = url.replace("mobile.nytimes.com","nytimes.com").replace(".xml",".htm")
                return url.indexOf("nytimes.com/") > -1
            if nytUrls.length > 0
                @received data, nytUrls
    stop: () =>
        @stream.destroy()
    followUrl:(url,cb) =>
        console.log "Fetching " + url
        http.get url, (res) =>
            res.on "end", () =>
                if res.statusCode == 302 || res.statusCode == 301
                    if res.headers.location
                        @followUrl res.headers.location, cb
                    else
                        cb("")
                else
                    cb(url)

module.exports = TwitterMonitor