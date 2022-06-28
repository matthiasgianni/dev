unit UDMDB;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, System.IniFiles, UCoreTypes, UCoreConsts;

type
  TDMDB = class(TDataModule)
    Connection: TADOConnection;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    SessionUser: TUser;

    procedure AddLog(ALog: TSysLog);

    // Funzioni generiche DB
    procedure NewSetting; overload;  // default
    procedure NewSetting(ASetting: String; AValue: Variant); overload;
    procedure EditSetting(ASetting: String; AValue: Variant);

    function GetSetting(ASetting: String; varType: Word): Variant;
    function GetQuery(SQL: string; const Args: array of const): TADOQuery;
    function GetFieldValue(Table, Field, Where: String): Variant;

    // Gestione accesso
    procedure Logout;
    function GetLogin(AccessCode: String): Boolean;
    function GetLoggedUser: TUser;
  end;

var
  DMDB: TDMDB;

implementation

{$R *.dfm}

procedure TDMDB.DataModuleCreate(Sender: TObject);
begin
  if not Connection.Connected and (Connection.ConnectionString <> '') then
    Connection.Connected := True;

  NewSetting;
end;

procedure TDMDB.DataModuleDestroy(Sender: TObject);
begin
  //Logout;
end;

function TDMDB.GetFieldValue(Table, Field, Where: String): Variant;
var
  SQL: String;
  Q: TADOQuery;
begin
  Q := GetQuery(
    'select %s from %s where %s', [Field, Table, Where]);
  try
    Q.Open;
    Result := Q.Fields[0].AsVariant;
  finally
    Q.Free;
  end;
end;

function TDMDB.GetQuery(SQL: string; const Args: array of const): TADOQuery;
begin
  Result := TADOQuery.Create(nil);
  Result.Connection := Connection;
  Result.AutoCalcFields := False;
  Result.DisableControls;

  if Length(Args) > 0 then
    Result.SQL.Text := Format(SQL, Args)
  else
    Result.SQL.Text := SQL;
end;

procedure TDMDB.AddLog(ALog: TSysLog);
var
  Q: TADOQuery;
begin
  Q := GetQuery(
    'insert into Log (Data, Descrizione, Utente) ' +
    'values (%s, %s, %s)',
    [QuotedStr(DateTimeToStr(ALog.Data)),
     QuotedStr(ALog.Descrizione),
     QuotedStr(ALog.User)]);
  try
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TDMDB.NewSetting;
begin
  {Settaggi default}
end;

procedure TDMDB.NewSetting(ASetting: String; AValue: Variant);
begin
  // Nuovo settaggio se non esistente
  with GetQuery(
    'select * from Settings',
    [QuotedStr(ASetting)]) do
  begin
    try
      Open;
      // Se la chiave esiste già skippo altrimenti la creo
      if Locate('Descrizione', ASetting, []) then
        Exit
      else
      begin
        Append;
        FieldByName('Descrizione').Value := ASetting;
        FieldByName('Valore').Value      := AValue;
        Post;
      end;
    finally
      Free;
    end;
  end;
end;

// Modificare un settaggio
procedure TDMDB.EditSetting(ASetting: String; AValue: Variant);
begin
  with GetQuery(
    'select * from Settings where Descrizione = %s',
    [QuotedStr(ASetting)]) do
  begin
    try
      Open;
      // Se la chiave non esiste raiso, altrimento la modifico
      if not Locate('Descrizione', ASetting, []) then
        raise Exception.Create(Format('Settaggio "%s" inesistente', [ASetting]))
      else
      begin
        Edit;
        FieldByName('Valore').Value := AValue;
        Post;
      end;
    finally
      Free;
    end;
  end;
end;

function TDMDB.GetSetting(ASetting: String; varType: Word): Variant;
begin
  with GetQuery(
    'select * from Settings where Descrizione = %s',
    [QuotedStr(ASetting)]) do
  begin
    try
      Open;
      if Locate('Descrizione', ASetting, []) then
      begin
        if varType = varInteger then
          Result := FieldByName('Valore').AsInteger;
        if varType = varString then
          Result := FieldByName('Valore').AsString;
        if varType = varBoolean then
          Result := FieldByName('Valore').AsBoolean;
      end;
    finally
      Free;
    end;
  end;
end;

function TDMDB.GetLoggedUser: TUser;
var
  Q: TADOQuery;
begin
  Q := GetQuery(
    'select * from Utenti where IsLogged = 1', []);
  try
    Q.Open;
    if Q.RecordCount = 1 then
    begin
      Result.Nome       := Q.FieldByName('Nome').AsString;
      Result.AccessCode := Q.FieldByName('AccessCode').AsString;
      Result.IsLogged   := True;
    end;
  finally
    Q.Free;
  end;
end;

function TDMDB.GetLogin(AccessCode: String): Boolean;
var
  Q: TADOQuery;
begin
  Result := False;

  Q := GetQuery(
    'select * from Utenti where AccessCode = %s',
    [QuotedStr(AccessCode)]);
  try
    Q.Open;
    Result := Q.RecordCount > 0;
    if Result then
    begin
      Logout;
      // Chiudo e riapro la query dato che i valori cambiano
      Q.Close;
      Q.Open;

      Q.Edit;
      Q.FieldByName('IsLogged').Value := True;
      Q.Post;

      SessionUser := GetLoggedUser;
    end;
  finally
    Q.Free;
  end;
end;

procedure TDMDB.Logout;
var
  Q: TADOQuery;
begin
  Q := GetQuery(
    'update Utenti set IsLogged = 0', []);
  try
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

end.
