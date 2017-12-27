local limit_conn = require 'resty.limit.conn'
local limit_req = require 'resty.limit.req'
local limit_traffic = require 'resty.limit.traffic'

local lim1, err = limit_req.new('shm_req_limit_store', 10, 0)
local lim2, err = limit_conn.new('shm_conn_limit_store', 10, 0, 0.5)

assert(lim1, err)
assert(lim2, err)


local host = ngx.var.host
local client = ngx.var.binary_remote_addr
local keys = {host, client}
local limiters = {lim1, lim2}

local states = {}
local delay, err = limit_traffic.combine(limiters, keys, states)

if not delay then
    if err == 'rejected' then
        ngx.log(ngx.ERR, "reach limit, rejected")
        return ngx.exit(503)
    end
    ngx.log(ngx.ERR, 'failed to limit traffic:', err)
    return ngx.exit(500)
end


if lim2:is_committed() then
    local ctx = ngx.ctx
    ctx.limit_conn = lim2
    ctx.limit_conn_key = keys[2]
end


print("sleeping", delay, " sec, states:", table.concat(states,", "))


