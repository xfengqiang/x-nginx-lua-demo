-- 请求频率控制

local limit_req = require "resty.limit.req"
local lim, err = limit_req.new("shm_req_limit_store", 10, 0)
if not lim then
    ngx.log(ngx.ERR, "failed to initcialize resty limit plugin")
    return ngx.exit(500)
end


local key = ngx.var.binary_remote_addr
local delay, err = lim:incoming(key, true)
if not delay then
    if err == "rejected" then
        ngx.log(ngx.ERR, "reach req limit")
        return ngx.exit(503)
    end    
    ngx.log(ngx.ERR, "Failed to limit req:", err)
    return ngx.exit(500)
end


