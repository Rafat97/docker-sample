local redis = require "resty.redis"

local function get_service_info(service_name)
    local red = redis:new()
    red:set_timeout(1000) -- 1 second

    -- Connect to Redis server
    local ok, err = red:connect("redis", 6379)
    if not ok then
        ngx.log(ngx.ERR, "failed to connect to Redis: ", err)
        return nil
    end

    -- Get service host and port from Redis
    local host, err = red:get(service_name .. "_host")
    if not host or host == ngx.null then
        ngx.log(ngx.ERR, "failed to get host for ", service_name, ": ", err)
        return nil
    end

    local port, err = red:get(service_name .. "_port")
    if not port or port == ngx.null then
        ngx.log(ngx.ERR, "failed to get port for ", service_name, ": ", err)
        return nil
    end

    return { host = host, port = port }
end

local function get_server_name()
    local red = redis:new()
    red:set_timeout(1000) -- 1 second

    -- Connect to Redis server
    local ok, err = red:connect("redis", 6379)
    if not ok then
        ngx.log(ngx.ERR, "failed to connect to Redis: ", err)
        return nil
    end

    -- Get server name from Redis
    local server_name, err = red:get("server_name")
    if not server_name or server_name == ngx.null then
        ngx.log(ngx.ERR, "failed to get server name: ", err)
        return nil
    end

    return server_name
end

local function set_proxy_headers()
    ngx.req.set_header("Host", ngx.var.host)
    ngx.req.set_header("X-Real-IP", ngx.var.remote_addr)
    ngx.req.set_header("X-Forwarded-For", ngx.var.proxy_add_x_forwarded_for)
    ngx.req.set_header("X-Forwarded-Proto", ngx.var.scheme)
end

local function is_grpc_request()
    local content_type = ngx.var.content_type or ""
    return ngx.req.get_method() == "POST" and content_type:find("application/grpc")
end

local function is_websocket_request()
    local upgrade = ngx.var.http_upgrade or ""
    return upgrade:lower() == "websocket"
end

-- Fetch and set the server name
local server_name = get_server_name()
if server_name then
    ngx.var.server_name = server_name
else
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

if is_grpc_request() then
    local grpc_info = get_service_info("grpc_service")
    if grpc_info then
        ngx.var.target_host = grpc_info.host
        ngx.var.target_port = grpc_info.port
        set_proxy_headers()
        ngx.exec("@grpc")
    else
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
elseif is_websocket_request() then
    local ws_info = get_service_info("websocket_service")
    if ws_info then
        ngx.var.target_host = ws_info.host
        ngx.var.target_port = ws_info.port
        set_proxy_headers()
        ngx.exec("@websocket")
    else
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
else
    local http_info = get_service_info("backend_service")
    if http_info then
        ngx.var.target_host = http_info.host
        ngx.var.target_port = http_info.port
        set_proxy_headers()
        ngx.exec("@http")
    else
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end
end