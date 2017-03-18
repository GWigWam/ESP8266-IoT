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
