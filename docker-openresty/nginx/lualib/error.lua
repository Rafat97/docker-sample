local cjson = require("cjson")


ngx.header.content_type = 'application/json'
ngx.say(cjson.encode(
    {
        status = ngx.status, 
        message = "Unknown error!!"
    }
))

return ngx.exit(ngx.status)