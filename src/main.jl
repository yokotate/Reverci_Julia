module Reverci
    export update,enable,print_cells,end_check
    # 型の作成
    mutable struct Reverci_Data
        # 石の色
        _Blank
        _White
        _Black
        # 盤の大きさ
        _BoardSize
        # 盤の内容
        _Cells
        # 行動可能選択肢
        _EnableList
    end
    # 盤面の初期化
    function reset(size)
        # 固定値の設定
        _Blank = 0
        _White = 1
        _Black = 2
        _BoardSize = size
        _Cells = zeros(Int64,_BoardSize,_BoardSize)
        _EnableList = collect(1:1:_BoardSize^2)
        # 石の初期配置
        _Cells[4,4] = _White
        _Cells[4,5] = _Black
        _Cells[5,4] = _Black
        _Cells[5,5] = _White
        return Reverci_Data(_Blank,_White,_Black,_BoardSize,_Cells,_EnableList)
    end
    # 盤面の表示
    function print_cells(self::Reverci_Data)
        for i in 1:self._BoardSize
            gyou = ""
            for j in 1:self._BoardSize
                color = self._Cells[i,j]
                if color == self._White
                    gyou = string(gyou,"  ●")
                elseif color == self._Black
                    gyou = string(gyou,"  ○")
                else
                    gyou = string(gyou,lpad(string((i-1) * self._BoardSize + j),3))
                end
            end
            println(gyou)
        end
    end
    # セルの値を取得
    function get_cell_value(self::Reverci_Data,action::Int64)
        x = Int(floor(action/self._BoardSize)) + if action%self._BoardSize==0 0 else 1 end
        y = Int(if action%self._BoardSize==0 8 else action%self._BoardSize end)
        return self._Cells[x,y]
    end
    # セルの値を変更
    function set_cell_value(self::Reverci_Data,action::Int64,color::Int64)
        x = Int(floor(action/self._BoardSize)) + if action%self._BoardSize==0 0 else 1 end
        y = Int(if action%self._BoardSize==0 8 else action%self._BoardSize end)
        self._Cells[x,y] = color
        return self
    end
    # ひっくり返す石の判定及びひっくり返す
    function put_cell(self::Reverci_Data,action::Int64,color::Int64,change)
        size = self._BoardSize
        # 指定位置が空かどうかチェック
        if get_cell_value(self,action) != self._Blank
            return self,false
        end
        # 設定値
        # l：ひっくり返る石のリスト
        # xd,yd：盤面の端迄の距離
        ChangeLists = []
        x = Int(floor(action/self._BoardSize)) + if action%self._BoardSize==0 0 else 1 end
        y = Int(if action%self._BoardSize==0 8 else action%self._BoardSize end)
        xd = size - x
        yd = size - y
        t = false
        # 石が置かれた位置の周囲を探索する
        # -9 -8 -7
        # -1  0 +1
        # +7 +8 +9
        # 一次元配列にした際には上のような位置関係になる
        for (i,deep) in zip([(size+1)*-1,size*-1,(size-1)*-1,-1,+1,size-1,size,size+1],[min(x-1,y-1),x-1,min(x-1,yd),y-1,yd,min(xd,y-1),xd,min(xd,yd)])
            EList,EListVal,ChangeCells=[],[],[]
            kazu = 0
            # 影響範囲を取得
            for lenge in 1:deep
                append!(EList,action + (i * lenge))
                append!(EListVal,get_cell_value(self,action + (i * lenge)))
            end
            # 置いた際の動きについて記憶
            for cell in EListVal
                if Int(cell) == self._Blank
                    break
                elseif Int(cell) == color
                    append!(ChangeLists,ChangeCells)
                    t += kazu
                    break
                else
                    append!(ChangeCells,EList[kazu + 1])
                end
                kazu += 1
            end
        end
        # 対象となる石が一個もなかった場合
        if t == 0
            return self,false
        end
        # 変更をする場合
        if change
            for i in ChangeLists
                self = set_cell_value(self,i,color)
            end
            self = set_cell_value(self,action,color)
        end
        # 結果返し
        return self,true
    end
    # 行動可能リスト作成
    function enable(self::Reverci_Data,color::Int64)
        result = []
        for action in self._EnableList
            if get_cell_value(self,action) == self._Blank
                self,check = put_cell(self,action,color,false)
                if check
                    append!(result,action)
                end
            end
        end
        return result
    end
    # 更新処理
    function update(self::Reverci_Data,action::Int64,color::Int64)
        self,n = put_cell(self,action,color,false)
        if n
            self,n = put_cell(self,action,color,true)
        end
        return self
    end
    # スコア取得
    function get_score(self::Reverci_Data,color::Int64)
        score = 0
        for action in self._EnableList
            if get_cell_value(self,action) == color
                score += 1
            end
        end
        return score
    end
    # 勝敗判定
    function win_check(self::Reverci_Data)
        BScore = get_score(self,self._Black)
        WScore = get_score(self,self._White)
        if BScore < WScore
            return self._White
        elseif BScore > WScore
            return self._Black
        else
            return self._Blank
        end
    end
    # 終了判定
    function end_check(self::Reverci_Data)
        b = enable(self,self._Black)
        w = enable(self,self._White)
        if length(b) == 0 && length(w) == 0
            return true
        end
        return false
    end
end
