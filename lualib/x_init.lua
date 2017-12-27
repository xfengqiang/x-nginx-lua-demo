-- 演示定时通过http获取配置文件，并更新到本地的共享内存
-- 需要重点考虑锁的使用，请求超时等异常情况


-- 记录日志，不能作为线上环境使用，如果用于生产环境，需要缓存打开的文件句柄，并考虑文件定时切割
local function init_write_log(level, msg)
    local log_file = io.open("/tmp/lua.log", "a")
    log_file:write('['..level..'] '..msg..'\n')
    log_file:close()
end

-- 更新配置
local function do_update_config() 
    local config = ngx.shared.shm_data
    local lock = config:get('update_config_lock')
    local last_uptime = config:get('update_config_time')

    last_uptime = last_uptime~=nil and last_uptime or 0

    if (os.time()-last_uptime) < 15 then
        if lock == 1 then 
            init_write_log('info', 'update config locked.value:'..lock)
            return 
        end 
        init_write_log('info', 'recent has update. last up time:'..last_uptime)
        return 
    end

    config:set('update_config_lock', 1)
    init_write_log('info', 'update config file')

    local http = require "resty.http"
    local json = require 'json'
    local httpc = http.new()
    httpc:set_timeout(1000)    

    --local uri = 'http://127.0.0.1/get_config'    
    local uri = 'http://127.0.0.1/config.php'    
    local res, err = httpc:request_uri(uri, {
                        method = "GET",
                        body = "",
                        headers = {
                            ["HOST"] = "lua.x.vm",
                        }
                    })

    init_write_log('tarce', "http res:"..res.body.." status:"..res.status)
    if res and res.status==200 then
        xpcall(function() 
            local cfg_data = json.decode(res.body)
            config:set('config_data', cfg_data)
            config:set('update_config_time', os.time())
            init_write_log('info', "update config file ok. time: "..os.time().." res:"..res.body)
        end, 
        function()
            init_write_log('error', "invalid config response:"..res.body.." status:"..res.status)
        end)
    else 
        if res then 
           init_write_log('error', "get config file failed. http status:"..res.status.."res["..res.body.."] ")
        else
           init_write_log('error', "get config file failed. err:"..err)
        end
    end
    
    config:set('update_config_lock', 0)
end

local function on_update_error() 
    local config = ngx.shared.shm_data
    config:set('update_config_lock', 0)
    init_write_log('error', 'update config file error')
    ngx.log(ngx.ERR, debug.traceback())
end

local function update_config(premature, uri, args, status) 
    xpcall(do_update_config, on_update_error)
end

local ok ,err = ngx.timer.every(5, update_config)
if not ok then 
    init_write_log('error', 'timer start failed '..err)
else
   init_write_log('INFO', 'timer start ok')
end
