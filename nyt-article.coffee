download = require "./util/download"

module.exports = class NYTArticleLookup
    constructor: (@config) ->
    cachedArticles: []
    articleByUrl: (url,cb) =>
        url = url.split("?")[0]
        if url.indexOf("http://nytim.es") == 0
            console.log "Shortened"
        if @cachedArticles[url]
            return cb(@cachedArticles[url])

        if url.indexOf("www.nytimes.com/") != -1
            cb(null)
        download
            "url": "http://api.nytimes.com/svc/news/v3/content.json"
            "method":"GET"
            "data":
                "api-key": @config.newswire
                "url":url
        , (data) =>
            parsed = JSON.parse(data)
            cb(parsed.results[0])
            @cachedArticles[url] = parsed.results[0]

    locationByName: (name,cb) =>
        download
            "url": "http://api.nytimes.com/svc/semantic/v2/geocodes/query.json"
            "method":"GET"
            "data":
                "api-key": @config.geo
                "name":name
        , (data) ->
            parsed = JSON.parse(data)
            cb(parsed.results[0])
