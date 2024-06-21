local redis = require "redis"
local red = redis:client()

-- Log request data
local key = "analytics:" .. ngx.var.remote_addr
red:incr(key)

-- Pass request to the next handler
ngx.exec("@backend")