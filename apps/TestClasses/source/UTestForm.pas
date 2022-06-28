unit UTestForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    EditGuest: TEdit;
    EditRoom: TEdit;
    Button1: TButton;
    EditCheckIn: TEdit;
    PanelStatus: TPanel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  UHMTypes;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  LReservation: ThmReservation;
begin
  LReservation := ThmReservation.Create;
  LReservation.GuestID := StrToInt(EditGuest.Text);
  LReservation.RoomID  := StrToInt(EditRoom.Text);

  LReservation.DoReservation;
  PanelStatus.Caption := LReservation.Messages.Text;
end;

end.
