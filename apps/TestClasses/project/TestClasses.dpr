program TestClasses;

uses
  Vcl.Forms,
  UHMTypes in '..\source\UHMTypes.pas',
  UTestForm in '..\source\UTestForm.pas' {Form1},
  UCoreConsts in '..\..\..\core\source\UCoreConsts.pas',
  UCoreTypes in '..\..\..\core\source\UCoreTypes.pas',
  UDMDB in '..\..\..\core\source\UDMDB.pas' {DMDB: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDMDB, DMDB);
  Application.Run;
end.
