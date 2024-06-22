-- openresty/conf/lua/redis_handler.lua
local redis = require "resty.redis"
local utils = require "utils"
local cjson = require("cjson")

local red = redis:new()

red:set_timeout(1000)  -- 1 second timeout

-- connect to Redis server
-- local ok, err = red:connect("172.24.0.3", 6379)
-- local ok, err = red:connect("127.0.0.1", 6379)
local ok, err = red:connect("redis", 6379)
if not ok then
    ngx.say("failed to connect to Redis: ", err)
    return
end

-- get the test key
local res, err = red:get("test_key")
if not res then
    ngx.say("failed to get test key from Redis: ", err)
    return
end

if res == ngx.null then
    ngx.say("test key not found")
    return
end

local ret, err = red:incr("inc_key")
if not ret then
    ngx.log(ngx.ERR, "failed to incr: ", err)
    -- take some other action here to handle the error...
end
local res2, err = red:get("inc_key")

ngx.sleep(2)

local worker_pid = ngx.worker.pid()
local now = ngx.now
local var = ngx.var
local fmt = string.format
local to_hex = require "resty.string".to_hex
local uuid = require "uuid".uuid
local time = require "time"

ngx.header.content_type = 'application/json'
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

ngx.say(cjson.encode(
    {
        uuidg = uuid(),
        res = res, 
        res2 = res2,
        worker_pid = worker_pid,
        now = now(),
        time = ngx.time(),
        get_now_ms = time.get_now_ms(),
        get_updated_now_ms = time.get_updated_now_ms(),
        server_port = var.server_port,
        connection = var.connection, -- connection serial number
        connection_requests = var.connection_requests, -- current number of requests made through a connection
        request_id = var.request_id ,
        trs = ngx.header.X_Tracker_Id
    }
))


-- ngx.say("test key: ", res, res2)