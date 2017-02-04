
wifi.setmode(wifi.STATION)
wifi.sta.config("","")
print(wifi.sta.getip())
led1 = 5
led2 = 2
led3 = 1
status = 0
StaCnt = 0
gpio.mode(led1, gpio.OUTPUT)
gpio.mode(led2, gpio.OUTPUT)
gpio.mode(led3, gpio.OUTPUT)
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = "";
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        buf = buf.."<h1> ESP8266 Web Server</h1>";
        buf = buf.."<p>GPIO0 <a href=\"?pin=ON1\"><button>ON</button></a> <a href=\"?pin=OFF1\"><button>OFF</button></a></p>";
        buf = buf.."<p>GPIO2 <a href=\"?pin=ON2\"><button>ON</button></a> <a href=\"?pin=OFF2\"><button>OFF</button></a></p>";
        buf = buf.."<p>GPIO3 <a href=\"?pin=ON3\"><button>ON</button></a> <a href=\"?pin=OFF3\"><button>OFF</button></a></p>";        
        local _on,_off = "",""
        if(_GET.pin == "ON1")then
              status = 1          --gpio.write(led1, gpio.HIGH);
        elseif(_GET.pin == "OFF1")then
              gpio.write(led1, gpio.LOW);
        elseif(_GET.pin == "ON2")then
              status = 2          --gpio.write(led2, gpio.HIGH);
        elseif(_GET.pin == "OFF2")then
              gpio.write(led2, gpio.LOW);
        elseif(_GET.pin == "ON3")then
              status = 3          --gpio.write(led3, gpio.HIGH);
        elseif(_GET.pin == "OFF3")then
              gpio.write(led3, gpio.LOW); 
        end           
        client:send(buf);
        client:close();
        collectgarbage();
    end)
end)
function StatusMachine()
    if (status == 0) then
        gpio.write(led1, gpio.LOW)
        gpio.write(led2, gpio.LOW)
        gpio.write(led3, gpio.LOW)              
        status = 0
        StaCnt = 0
    end
    if (status == 1) then
        gpio.write(led1, gpio.HIGH)
        if (StaCnt >= 1) then               
            status = 4
            StaCnt = 0
        else    
            StaCnt = StaCnt + 1
        end
    end
    if (status == 2) then
        gpio.write(led2, gpio.HIGH)
        if (StaCnt >= 1) then               
            status = 5
            StaCnt = 0
        else    
            StaCnt = StaCnt + 1
        end
    end
    if (status == 3) then
        gpio.write(led3, gpio.HIGH)
        if (StaCnt >= 1) then               
            status = 6
            StaCnt = 0
        else    
            StaCnt = StaCnt + 1
        end
    end 
    if (status == 4) then
        gpio.write(led1, gpio.LOW)  
        if (StaCnt >= 20) then              
            status = 3
            StaCnt = 0
        else    
            StaCnt = StaCnt + 1
        end
    end
    if (status == 5) then
        gpio.write(led2, gpio.LOW)  
        if (StaCnt >= 30) then              
            status = 3
            StaCnt = 0
        else    
            StaCnt = StaCnt + 1
        end
    end
     if (status == 6) then
        gpio.write(led3, gpio.LOW)  
        if (StaCnt >= 1) then              
            status = 0
            StaCnt = 0
        else    
            StaCnt = StaCnt + 1
        end
    end
end
tmr.alarm(1,500,tmr.ALARM_AUTO,function() StatusMachine() end) 
