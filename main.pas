{
  tiny-upx is a Windows gui frontend for upx.

  Download upx from http://upx.sourceforge.net.
  Make sure upx.exe in the same directory as upxgui.

  Author : Renyi
  Contact: renyi.ace@gmail.com
}
unit main;

interface

uses
  Windows, Messages, SysUtils, Forms, Menus, Classes, Controls, StdCtrls;

type
  TfrmMain = class(TForm)
    edtOutput: TMemo;
    PopupMenu1: TPopupMenu;
    Close1: TMenuItem;
    AddtoExplorerShell1: TMenuItem;
    procedure FormDestroy(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure AddtoExplorerShell1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure AcceptFiles( var msg : TMessage ); message WM_DROPFILES;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;
  AppMutex : THandle;

const
  _key_exe = '\dllfile\shell\pack with upx-gui';
  _key_dll = '\exefile\shell\pack with upx-gui';
  _key_cmd = '\Command';

implementation

{$R *.dfm}

uses
  ShellAPI, Utils, Registry;

procedure RunDosInMemo(const DosApp: String; AMemo:TMemo);
const
  ReadBuffer = 2400;
var
  Security : TSecurityAttributes;
  ReadPipe,WritePipe : THandle;
  start : TStartUpInfo;
  ProcessInfo : TProcessInformation;
  Buffer : PAnsiChar;
  BytesRead : DWord;
  Apprunning : DWord;

begin
  With Security do begin
    nlength := SizeOf(TSecurityAttributes) ;
    binherithandle := true;
    lpsecuritydescriptor := nil;
  end;

  if Createpipe (ReadPipe, WritePipe, @Security, 0) then
  begin
    Buffer := AllocMem(ReadBuffer + 1) ;
    FillChar(Start,Sizeof(Start),#0) ;
    start.cb := SizeOf(start) ;
    start.hStdOutput := WritePipe;
    start.hStdInput := ReadPipe;
    start.dwFlags := STARTF_USESTDHANDLES + STARTF_USESHOWWINDOW;
    start.wShowWindow := SW_HIDE;

    if CreateProcess(nil,
                     PChar(DosApp),
                     @Security,
                     @Security,
                     true,
                     NORMAL_PRIORITY_CLASS,
                     nil,
                     nil,
                     start,
                     ProcessInfo) then
    begin
      repeat
        Apprunning := WaitForSingleObject(ProcessInfo.hProcess,100);
        Application.ProcessMessages;
      until (Apprunning <> WAIT_TIMEOUT);

      Repeat
        BytesRead := 0;                 ReadFile(ReadPipe,Buffer[0], ReadBuffer,BytesRead,nil);
        Buffer[BytesRead]:= #0;
        OemToAnsi(Buffer, Buffer);
        AMemo.Text := AMemo.text + String(Buffer);
      until (BytesRead < ReadBuffer);
    end;

    FreeMem(Buffer) ;
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
    CloseHandle(ReadPipe);
    CloseHandle(WritePipe);
  end;
end;

procedure TfrmMain.AcceptFiles( var msg : TMessage );
const
  cnMaxFileNameLen = 255;
var
  i,
  nCount     : integer;
  acFileName : array [0..cnMaxFileNameLen] of char;
begin
  edtOutput.Clear;

  // find out how many files we're accepting
  nCount := DragQueryFile( msg.WParam,
                           $FFFFFFFF,
                           acFileName,
                           cnMaxFileNameLen );

  // query Windows one at a time for the file name
  for i := 0 to nCount-1 do
  begin
    DragQueryFile( msg.WParam, i,
                   acFileName, cnMaxFileNameLen );

    // do your thing with the acFileName
    RunDosInMemo(ExtractFilePath(Application.ExeName) + 'upx.exe "' + acFileName + '"', edtOutput);
  end;

  // let Windows know that you're done
  DragFinish( msg.WParam );
end;

procedure TfrmMain.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.AddtoExplorerShell1Click(Sender: TObject);
var
  value: String;
begin
  value := '"' + Application.ExeName + '"' + ' %1';

  if AddtoExplorerShell1.Checked then
  begin
    SetRegistryData(HKEY_CLASSES_ROOT, _key_exe + _key_cmd, '', rdString, value);
    SetRegistryData(HKEY_CLASSES_ROOT, _key_dll + _key_cmd, '', rdString, value);
  end
  else
  begin
    try
      RegDeleteKey(HKEY_CLASSES_ROOT, _key_exe + _key_cmd);
      RegDeleteKey(HKEY_CLASSES_ROOT, _key_dll + _key_cmd);
    finally
      RegDeleteKey(HKEY_CLASSES_ROOT, _key_exe);
      RegDeleteKey(HKEY_CLASSES_ROOT, _key_dll);
    end;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  value: String;
begin
  DragAcceptFiles(Handle, true);

  value := '"' + Application.ExeName + '"' + ' %1';

  if GetRegistryData(HKEY_CLASSES_ROOT, _key_exe + _key_cmd, '') = value then
    AddtoExplorerShell1.Checked := true;

  if ParamStr(1) <> '' then
    RunDosInMemo(ExtractFilePath(Application.ExeName) + 'upx.exe "' + ParamStr(1) + '"', edtOutput);
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if AppMutex <> 0 then
    CloseHAndle(AppMutex);
  AppMutex := 0;
end;

end.
