unit UCoreTypes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, System.Actions, Vcl.ActnList,
  Data.DB, Data.Win.ADODB;

type

  TSysLog = record
    Data: TDateTime;
    Descrizione: String;
    User: String;
  end;

  TUser = record
    Nome: String;
    AccessCode: String;
    IsLogged: Boolean;
    UserType: Integer;
    function IsEmpty: Boolean;
  end;

  function GetDarkerColor(AColor: TColor; APercent: Integer): TColor;
  procedure MakeRounded(Control: TWinControl; ARadius: Integer);
  function PopulateSysLog(ADescrizione, AUser: String): TSysLog;


implementation

function GetDarkerColor(AColor: TColor; APercent: Integer): TColor;
var
  R, G, B: Integer;
begin
  R := GetRValue(AColor);
  G := GetGValue(AColor);
  B := GetBValue(AColor);

  R := R - muldiv(R, APercent, 100);
  G := G - muldiv(G, APercent, 100);
  B := B - muldiv(B, APercent, 100);

  Result := RGB(R, G, B);
end;

procedure MakeRounded(Control: TWinControl; ARadius: Integer);
var
  R: TRect;
  Rgn: HRGN;
begin
  with Control do
  begin
    R := ClientRect;
    rgn := CreateRoundRectRgn(R.Left, R.Top, R.Right, R.Bottom, ARadius, ARadius);
    Perform(EM_GETRECT, 0, lParam(@r));
    InflateRect(r, - 5, - 5);
    Perform(EM_SETRECTNP, 0, lParam(@r));
    SetWindowRgn(Handle, rgn, True);
    Invalidate;
  end;
end;

function PopulateSysLog(ADescrizione, AUser: String): TSysLog;
begin
  Result.Data := Now;
  Result.Descrizione := ADescrizione;
  Result.User := AUser;
end;

{ TUser }

function TUser.IsEmpty: Boolean;
begin
  Result := (Nome = '') and (AccessCode = '');
end;

end.
