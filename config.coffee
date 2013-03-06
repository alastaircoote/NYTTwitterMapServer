if process.env.NODE_ENV == "production" 
    console.log "Using production config"
    module.exports = require "./config/prod.json"
else
    console.log "Using dev config"
    module.exports = require "./config/dev.json"