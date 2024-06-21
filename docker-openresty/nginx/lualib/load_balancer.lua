
local backends = {
    { host = "backend1", port = 80 },
    { host = "backend2", port = 80 },
}

-- Simple round-robin load balancing
local counter = ngx.shared.counter
local current = counter:get("current") or 0
current = (current % #backends) + 1
counter:set("current", current)

local backend = backends[current]
ngx.var.target_host = backend.host
ngx.var.target_port = backend.port

ngx.exec("@proxy")