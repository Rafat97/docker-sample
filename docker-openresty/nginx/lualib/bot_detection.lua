local redis = require "redis"
local cjson = require "cjson"

local function log_bot_activity(ip, user_agent)
    local red = redis:client()

    local bot_data = {
        ip = ip,
        user_agent = user_agent,
        timestamp = ngx.time()
    }

    local bot_data_json = cjson.encode(bot_data)
    red:rpush("bot_activity", bot_data_json)
end

local function is_bot(user_agent)
    local bot_patterns = {
        "bot", "crawler", "spider", "slurp", "robot", "crawling", "postmanruntime"
    }

    for _, pattern in ipairs(bot_patterns) do
        if user_agent:lower():find(pattern) then
            return true
        end
    end

    return false
end

local user_agent = ngx.var.http_user_agent or ""
local remote_addr = ngx.var.remote_addr or ""

if is_bot(user_agent) then
    log_bot_activity(remote_addr, user_agent)
    ngx.log(ngx.INFO, "Bot detected: ", user_agent, " from IP: ", remote_addr)
    ngx.say(cjson.encode(
        {
            status = ngx.HTTP_FORBIDDEN, 
            message = "Error!! Bot detected",
            error = {
                user_agent = user_agent, 
                remote_addr = remote_addr
            }
        }
    ))
    ngx.exit(ngx.HTTP_FORBIDDEN)
end