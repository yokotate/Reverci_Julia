include("./main.jl")
using .Reverci
ReverciData = Reverci.reset(8)
InputText = ""
println("　開　始　")
while !(Reverci.end_check(ReverciData))
    for color in [ReverciData._White,ReverciData._Black]
        println(color)
        Enable = Reverci.enable(ReverciData,color)
        if length(Enable) > 0
            InputFlag = false
            while !(InputFlag)
                if color == ReverciData._White
                    println("●のターン")
                elseif color == ReverciData._Black
                    println("○のターン")
                end
                Reverci.print_cells(ReverciData)
                println("番号を入力して下さい(xでゲーム終了)")
                println(Enable)
                print(">>>")

                # 入力値判定
                InputText = readline()
                if InputText == "x"
                    exit()
                end
                try
                    action = parse(Int,InputText)
                    if action in Enable
                        InputFlag = true
                        println("石を置きます ⇒ ",action)
                        global ReverciData = Reverci.update(ReverciData,action,color)
                    end
                catch
                    continue
                end
            end
        else
            println("PASS!!")
        end
    end
end
println("　終　了　！")
Reverci.print_cells(ReverciData)
WinColor = Reverci.win_check(ReverciData)
if WinColor == ReverciData._White
    println("●の勝ち")
elseif WinColor == ReverciData._Black
    println("○の勝ち")
else
    plintln("引き分け")
end