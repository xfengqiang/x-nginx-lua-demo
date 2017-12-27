# x-nginx-lua-demo
Nginx Lua 插件开发demo，内容包括定时任务，http请求配置文件，共享内存使用，流量控制  
代码仅作为demo，如果用于生产环境还需要进一步完善

## 文件说明
- nginx.conf nginx配置文件
- vhost/lua.conf nginx lua 配置
- lualib 目录 lua插件演示脚本
- lualib/json.lua Json解析库
- lualib/resty/http.lua lualib/resty/http_headers.lua  [lua-resty-http](https://github.com/pintsized/lua-resty-http)  
- lualib/resty/limit 流量控制库 [lua-resty-limit-traffic](https://github.com/openresty/lua-resty-limit-traffic)
