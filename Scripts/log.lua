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

function logWrite(file)
  file.open(file)
  table.foreach(lLog,function(k,v)file.writeline(v)end)
  file.close()
end

log("Initialized 'log.lua'. Max log size=" .. lLogSize)
