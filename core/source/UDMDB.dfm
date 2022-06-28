object DMDB: TDMDB
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 176
  Width = 243
  object Connection: TADOConnection
    ConnectionString = 
      'Provider=SQLOLEDB.1;Password=sql2019!;Persist Security Info=True' +
      ';User ID=sa;Initial Catalog=HM1.0;Data Source=.\SQL2019'
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 40
    Top = 24
  end
end
