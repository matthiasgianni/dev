unit UHMTypes;

interface

uses
  System.SysUtils, System.StrUtils, System.Classes,
  Data.DB, Data.Win.ADODB, UDMDB;

type
  ThmGuest = record
    GuestID: Integer;
  end;

  ThmRoomStatus = (Free, Busy, Inactive);
  ThmRoom = record
    RoomID: Integer;
    RoomType: Integer;
    Status: ThmRoomStatus;
  end;

  ThmReservationStatus = (GoodReservation, BadReservation);
  ThmReservation = class(TObject)
  private
    FGuestID: Integer;
    FRoomID: Integer;
    FCheckIn: TDateTime;
    FCheckOut: TDateTime;
    FMessages: TStringList;

    procedure FormatMessages;

    function GetRoomStatus(AStatus: Boolean): ThmRoomStatus;
    function GetBooleanRoomStatus(AStatus: ThmRoomStatus): Boolean;
  published
    property GuestID: Integer read FGuestID write FGuestID;
    property RoomID: Integer read FRoomID write FRoomID;
    property CheckIn: TDateTime read FCheckIn write FCheckIn;
    property CheckOut: TDateTime read FCheckOut write FCheckOut;

    property Messages: TStringList read FMessages write FMessages;
  public
    procedure ManageRoom(ARoomID: Integer; AStatus: ThmRoomStatus);

    function GetRoomInfo(ARoomID: Integer): ThmRoom;
    function DoReservation: ThmReservationStatus;
    function CheckReservation: Boolean;

    constructor Create; virtual;
  end;

implementation

{ ThmReservation }

constructor ThmReservation.Create;
begin
  inherited;
  FMessages := TStringList.Create;
end;

function ThmReservation.DoReservation: ThmReservationStatus;
var
  QReservation: TADOQuery;
begin
  if not CheckReservation then
  begin
    Free;
    Exit(BadReservation);
  end;

  // Creo la prenotazione
  QReservation := DMDB.GetQuery(
    'insert into Reservations ' +
    '(GuestID, RoomID) VALUES ' +
    '(%d, %d) ',
    [GuestID, RoomID]);
  try
    QReservation.ExecSQL;

    // Rendo non disponibile la camera per nuova prenotazione
    ManageRoom(RoomID, Busy);
  finally
    QReservation.Free;
  end;

  Result := GoodReservation;
end;

function ThmReservation.CheckReservation: Boolean;
var
  LRoom: ThmRoom;
begin
  Result := True;

  { CHECK PARAMETRI ... }
  if GuestID = 0 then
  begin
    Messages.Add('Ospite non valido');
    Result := False;
  end;
  if RoomID = 0 then
  begin
    Messages.Add('Camera non valida');
    Result := False;
  end;
  LRoom := GetRoomInfo(RoomID);
  if LRoom.Status = Busy then
  begin
    Messages.Add('Camera occupata');
    Result := False;
  end;

  FormatMessages;
end;

procedure ThmReservation.FormatMessages;
var
  I: Integer;
begin
  // Tolgo due dal ciclo in modo tale da evitare la formattazione per l'ultima frase
  for I := 0 to Messages.Count - 2 do
    Messages[I] := Messages[I] + (', ');

  Messages.Text := UpperCase(Messages.Text);
end;

procedure ThmReservation.ManageRoom(ARoomID: Integer; AStatus: ThmRoomStatus);
begin
  with DMDB.GetQuery(
    'select * from Rooms where RoomID = %d', [ARoomID]) do
  begin
    try
      Open;
      Edit;
      FieldByName('IsAvailable').Value := GetBooleanRoomStatus(AStatus);
      Post;
    finally
      Free;
    end;
  end;
end;

function ThmReservation.GetRoomInfo(ARoomID: Integer): ThmRoom;
begin
  with DMDB.GetQuery(
    'select * from Rooms where RoomID = %d', [ARoomID]) do
  begin
    try
      Open;
      if RecordCount = 0 then
      begin
        Result.Status := ThmRoomStatus.Inactive;
        Free; Exit;
      end;
      Result.RoomID   := FieldByName('RoomID').AsInteger;
      Result.RoomType := FieldByName('RoomType').AsInteger;
      Result.Status   := GetRoomStatus(FieldByName('IsAvailable').AsBoolean);
    finally
      Free;
    end;
  end;
end;

function ThmReservation.GetRoomStatus(AStatus: Boolean): ThmRoomStatus;
begin
  if AStatus then
    Result := ThmRoomStatus.Free
  else
    Result := ThmRoomStatus.Busy;
end;

function ThmReservation.GetBooleanRoomStatus(AStatus: ThmRoomStatus): Boolean;
begin
  if AStatus = ThmRoomStatus.Free then
    Result := True
  else
    Result := False;
end;

end.
