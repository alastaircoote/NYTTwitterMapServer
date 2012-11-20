download = require "./util/download"

module.exports = (address,cb) ->
    download
        url: "http://maps.googleapis.com/maps/api/geocode/json"
        method:"GET"
        data:
            address: address
            sensor:false
    ,(data) ->
        cb JSON.parse(data)