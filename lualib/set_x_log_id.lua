-- 在cookie中添加X_LOG_ID

local x_util = require "x.util"

local function set_x_log_id() 
    local cookie = ngx.var.http_cookie and ngx.var.http_cookie or ''

    if string.find(cookie, "X_LOG_ID") ~= nil then
        return  
    end    


    local ftime = os.time()
    local log_id = ngx.md5(ngx.var.remote_addr .. ftime .. math.random(100000, 999999))
    x_util.set_cookie("X_LOG_ID", log_id)
end


xpcall(set_x_log_id, x_util.on_error)
