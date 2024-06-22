local redis = require "redis"
local cjson = require "cjson"
local time = require "time"

local function log_request(premature, ip, user_agent, status, bytes_sent, request, http_referer)
    if premature then
        return
    end

    local red = redis:client()
    local current_time = time.get_updated_now_ms()

    local data = {
        ip = ip,
        user_agent = user_agent,
        status = status,
        bytes_sent = bytes_sent,
        timestamp = current_time,
        request = request,
        http_referer = http_referer
    }

    local data_json = cjson.encode(data)
    red:rpush("analytics_log", data_json)
end

local ip = ngx.var.remote_addr
local user_agent = ngx.var.http_user_agent
local status = ngx.var.status
local bytes_sent = ngx.var.body_bytes_sent
local request = ngx.var.request
local http_referer = ngx.var.http_referer

local ok, err = ngx.timer.at(0, log_request, ip, user_agent, status, bytes_sent, request, http_referer)
if not ok then
    ngx.log(ngx.ERR, "failed to create timer: ", err)
end