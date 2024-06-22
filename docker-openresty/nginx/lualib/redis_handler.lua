-- openresty/conf/lua/redis_handler.lua
local redis = require "redis"
-- local utils = require "utils"
-- local cjson = require("cjson")

local red = redis:client()

-- get the test key
-- local res, err = red:get("test_key")
-- if not res then
--     ngx.say("failed to get test key from Redis: ", err)
--     return
-- end

-- if res == ngx.null then
--     ngx.say("test key not found")
--     return
-- end

-- local ret, err = red:incr("inc_key")
-- if not ret then
--     ngx.log(ngx.ERR, "failed to incr: ", err)
--     -- take some other action here to handle the error...
-- end
-- local res2, err = red:get("inc_key")

-- ngx.sleep(2)

local worker_pid = ngx.worker.pid()
local now = ngx.now
local var = ngx.var
local fmt = string.format
local to_hex = require "resty.string".to_hex
local uuid = require "uuid".uuid
local time = require "time"

local function set_proxy_headers()
    ngx.header.content_type = 'application/json'
    ngx.header.Host = var.host
    ngx.header.X_Real_IP = var.remote_addr
    ngx.header.X_Forwarded_Proto = var.scheme
    ngx.header.X_Forwarded_For = var.proxy_add_x_forwarded_for
    ngx.header.Server = 'oss'
    ngx.header.X_Request_Id = var.request_id
    ngx.header.X_Tracker_Id = fmt("%s-%s-%s-%d-%s-%s-%s",
        fmt("%s",now() * 1000),
        var.server_addr,
        var.server_port,
        worker_pid,
        var.connection, 
        var.connection_requests, 
        var.request_id
    )
end

-- ngx.say(cjson.encode(
--     {
--         uuidg = uuid(),
--         res = res, 
--         res2 = res2,
--         worker_pid = worker_pid,
--         now = now(),
--         time = ngx.time(),
--         get_now_ms = time.get_now_ms(),
--         get_updated_now_ms = time.get_updated_now_ms(),
--         server_port = var.server_port,
--         connection = var.connection, -- connection serial number
--         connection_requests = var.connection_requests, -- current number of requests made through a connection
--         request_id = var.request_id ,
--         host = ngx.var.host,
--         request_uri = ngx.var.request_uri,
--         scheme = ngx.var.scheme,
--         request_length = ngx.var.request_length,
--         trs = ngx.header.X_Tracker_Id
--     }
-- ))

-- ngx.exit(ngx.OK)
set_proxy_headers()
ngx.var.target = "http://httpbin.org:80"
-- ngx.var.target = "http://global.api.konghq.com/examples/stock/piper:80"
ngx.exec("@http")
-- ngx.say("test key: ", res, res2)