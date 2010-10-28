unit utils;

interface

Uses
  Registry, Windows;

  function GetRegistryData(RootKey: HKEY; const Key, Value: string): variant;
  procedure SetRegistryData(RootKey: HKEY; const Key, Value: string;
                            RegDataType: TRegDataType; Data: variant);
  procedure RegDeleteKey(RootKey: HKEY; const Key: string);

implementation

function GetRegistryData(RootKey: HKEY; const Key, Value: string): variant;
var
  Reg: TRegistry;
  RegDataType: TRegDataType;
  DataSize, Len: integer;
  s: string;

begin
  Reg := nil;
  try
    Reg := TRegistry.Create(KEY_QUERY_VALUE);
    Reg.RootKey := RootKey;
    if Reg.OpenKeyReadOnly(Key) then
    begin
      try
        RegDataType := Reg.GetDataType(Value);
        if (RegDataType = rdString) or
           (RegDataType = rdExpandString) then
          Result := Reg.ReadString(Value)
        else if RegDataType = rdInteger then
          Result := Reg.ReadInteger(Value)
        else if RegDataType = rdBinary then
        begin
          DataSize := Reg.GetDataSize(Value);
          if DataSize <> -1 then
          begin
            SetLength(s, DataSize);
            Len := Reg.ReadBinaryData(Value, PChar(s)^, DataSize);
            if Len = DataSize then
              Result := s;
          end;
        end;
      except
        s := ''; // Deallocates memory if allocated
        Reg.CloseKey;
        raise;
      end;
      Reg.CloseKey;
    end;
    //else
      //raise Exception.Create('Key not found.');
  except
    Reg.Free;
    raise;
  end;
  Reg.Free;
end;

procedure SetRegistryData(RootKey: HKEY; const Key, Value: string;
  RegDataType: TRegDataType; Data: variant);
var
  Reg: TRegistry;
  s: string;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := RootKey;
    if Reg.OpenKey(Key, True) then begin
      try
        if RegDataType = rdUnknown then
          RegDataType := Reg.GetDataType(Value);
        if RegDataType = rdString then
          Reg.WriteString(Value, Data)
        else if RegDataType = rdExpandString then
          Reg.WriteExpandString(Value, Data)
        else if RegDataType = rdInteger then
          Reg.WriteInteger(Value, Data)
        else if RegDataType = rdBinary then begin
          s := Data;
          Reg.WriteBinaryData(Value, PChar(s)^, Length(s));
        end
        //else
          //raise Exception.Create(SysErrorMessage(ERROR_CANTWRITE));
      except
        Reg.CloseKey;
        raise;
      end;
      Reg.CloseKey;
    end
    //else
      //raise Exception.Create(SysErrorMessage(GetLastError));
  finally
    Reg.Free;
  end;
end;

procedure RegDeleteKey(RootKey: HKEY; const Key: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := RootKey;
    if Reg.OpenKey(Key, True) then begin
      try
        Reg.DeleteKey(Key);
      except
        Reg.CloseKey;
      end;
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

end.
