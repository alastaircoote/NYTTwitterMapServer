twitter = require "mtwitter"
config = require "./config"
http = require "http"
https = require "https"
async = require "async"
console.log config
twit = new twitter(config.twitter)

class TwitterMonitor
    start: (@received) =>
        console.log "Starting stream"
        twit.stream 'statuses/filter', {follow:"807095", replies: true, track:"nytimes"}, (stream) =>
            @stream = stream
            stream.on "data", @receiveData
    receiveData: (data) =>
        console.log "Article received"
        if !data.user
            console.log data
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
        if !url
            cb("")
            return

        prot = http
        if url.indexOf("https://") > -1
            prot = https


        prot.get url, (res) =>
            res.on "end", () =>
                if res.statusCode == 302 || res.statusCode == 301
                    if res.headers.location
                        @followUrl res.headers.location, cb
                    else
                        cb("")
                else
                    cb(url)

module.exports = TwitterMonitor