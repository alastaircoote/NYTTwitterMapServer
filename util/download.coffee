http = require "http"
https = require "https"
url = require "url"
querystring = require "querystring"


module.exports = (options,cb) ->
    protocol = if options.protocol == "https" then https else http
    parsedUrl = url.parse options.url

    if options.method == "GET" && options.data
        parsedUrl.path += "?" + querystring.stringify(options.data)
    parsedUrl.method = options.method

    req = protocol.request parsedUrl, (res) ->
        dataArray = []
        
        res.on "data", (data) ->
            dataArray.push data

        res.on "end", () ->
            cb(dataArray.join(""))
    if options.method == "POST" && options.data
        req.write querystring.stringify(options.data)

    req.end()