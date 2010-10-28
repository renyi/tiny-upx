program tinyupx;

uses
  Windows,
  Forms,
  main in 'main.pas' {frmMain},
  utils in 'utils.pas';

{$R *.res}

var
  resMtx : longword;

begin
  // Create mutex to ensure, single instance
  AppMutex := CreateMutex(nil,false,'tiny-upx');
  resMtx := GetLastError;
  if (resMtx = ERROR_ALREADY_EXISTS) or
     (resMtx = ERROR_ACCESS_DENIED) then
  begin
    Halt(0);
  end;

  Application.Initialize;
  Application.Title := 'tiny-upx';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
