lLog = {}
lLogSize = 50

function log(line)
  print(line)
  table.insert(lLog, line)

  while #lLog > lLogSize do
    table.remove(lLog, 1)
  end
end

function logPrint()table.foreach(lLog,function(k,v)print(v)end)end

function logWrite(path)
  file.open(path,'w')
  table.foreach(lLog,function(k,v)file.writeline(v)end)
  file.close()
end

function startLogBackup()
    tmrRepeat(1000*60*30,function() logWrite('log.txt') end)
    log('log backup started')
end

log("Initialized 'log.lua'. Max log size=" .. lLogSize)
