local ctx = ngx.ctx
local lim = ctx.limit_conn
if lim then
    local latency = tonumber(ngx.var.request_time)
    local key = ctx.limit_conn_key
    assert(key)
    local conn, err = lim:leaving(key, latency)
    if not conn then
        ngx.log(ngx.ERR, 'Failed to record the connection leavine', 'request:', err)
    end
end
