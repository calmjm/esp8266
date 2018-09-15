t=require('ds18b20')
t.setup(3)
addrs=t.addrs()
for i=1,table.getn(addrs) do print(t.read(addrs[i])) end
tmr.alarm(0, 1000, 1, function() print('*'); for i=1,table.getn(addrs) do print(t.read(addrs[i])) end end )
