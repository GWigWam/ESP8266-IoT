print("Init 'util.lua'")

function tablePrint(tIn)
    for i = 1, #tIn, 1 do
        print('At ['..i..']: '..tIn[i])
    end
end

function tableMedian(tIn)
    table.sort(tIn)
    indx = math.floor(#tIn / 2) + 1
    return tIn[indx];
end

function utilTmrCreate(mode, delayMs, func)
    local ltmr = tmr.create()
    ltmr:register(delayMs, mode, func)
    ltmr:start()
    return ltmr
end

function tmrDelay(delayMs, func) return utilTmrCreate(tmr.ALARM_SINGLE, delayMs, func) end
function tmrSemi(delayMs, func) return utilTmrCreate(tmr.ALARM_SEMI, delayMs, func) end
function tmrRepeat(delayMs, func) return utilTmrCreate(tmr.ALARM_AUTO, delayMs, func) end