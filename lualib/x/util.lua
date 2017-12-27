local _M = {
}

function _M.cookie_string(name, value, expire) 
    if expire == nil then
        expire = 86400
    end
    return name .. '=' .. value .. ';path=/;expires=' .. ngx.cookie_time(os.time()+expire) .. ';domain=' .. ngx.var.host
end

function _M.set_cookie(name, value, expire) 
    if not value then
        return ''
    end

    -- 设置响应cookie
    local cookie_type = type(ngx.header["Set-cookie"])
    local cookie_header
    if cookie_type == 'nil' then
        cookie_header = {}
    elseif cookie_type == 'table' then
        cookie_header =  ngx.header['Set-cookie']
    else 
        cookie_header = {ngx.header['Set-cookie']}
    end
    
    table.insert(cookie_header, _M.cookie_string(name, value, expire))
    
    ngx.header['Set-cookie'] = cookie_header

    -- 设置请求cookie
    -- TODO 考虑cookie name重复设置的问题
    local cookie = (ngx.var.http_cookie and ngx.var.http_cookie) or ''
    local n, err
    cookie, n , err = ngx.re.gsub(cookie, "(^|;[\\s\\t]*)" .. name .. "([^;]+)", function(m)
        return ''
    end)
    cookie = cookie .. (cookie=='' and '' or ';') .. name .. '=' .. value 
    ngx.req.set_header('Cookie', cookie)
end

function _M.on_error() 
    ngx.log(ngx.ERR, debug.traceback())
end

function _M.write_log(level, msg) 
    local log_file = io.open("/tmp/lua.log", "a")
    log_file:write('['..level..'] '..msg..'\n')
    log_file:close()
end

return _M
