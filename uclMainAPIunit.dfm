object WebModule1: TWebModule1
  OldCreateOrder = False
  Actions = <
    item
      Name = 'WebActionItem1'
      PathInfo = '/authors'
      OnAction = WebModule1WebActionItem1Action
    end
    item
      Name = 'WebActionItem2'
      PathInfo = '/book'
      OnAction = WebModule1WebActionItem2Action
    end
    item
      Name = 'WebActionItem3'
      PathInfo = '/bookfilter'
      OnAction = WebModule1WebActionItem3Action
    end
    item
      Name = 'WebActionItem4'
      PathInfo = '/login'
      OnAction = WebModule1WebActionItem4Action
    end
    item
      Name = 'WebActionItem6'
      PathInfo = '/borrow'
      OnAction = WebModule1WebActionItem6Action
    end
    item
      Name = 'WebActionItem7'
      PathInfo = '/returnbook'
      OnAction = WebModule1WebActionItem7Action
    end
    item
      Name = 'WebActionItem8'
      PathInfo = '/category'
      OnAction = WebModule1WebActionItem8Action
    end
    item
      Name = 'GET_Transaction_history'
      PathInfo = '/transactionhistory'
      OnAction = WebModule1GET_Transaction_historyAction
    end
    item
      Name = 'GET_Edit_History'
      PathInfo = '/edithistory'
      OnAction = WebModule1GET_Edit_HistoryAction
    end>
  Left = 65526
  Top = 431
  Height = 1056
  Width = 1936
  object SDDatabase1: TSDDatabase
    ServerType = stSQLBase
    SessionName = 'Default'
    Left = 88
    Top = 16
  end
  object SDTable1: TSDTable
    Left = 168
    Top = 16
  end
end
