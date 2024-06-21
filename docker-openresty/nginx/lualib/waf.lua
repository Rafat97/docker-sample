-- openresty/conf/lua/waf.lua

-- Implement basic rules
local bad_ips = {
    ["1.2.3.4"] = true,
}

local ip = ngx.var.remote_addr
if bad_ips[ip] then
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

-- Pass request to the next handler
ngx.exec("@backend")