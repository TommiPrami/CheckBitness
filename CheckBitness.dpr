program CheckBitness;

{$APPTYPE CONSOLE}

// Disable the "new" RTTI to make exe smaller
{$WEAKLINKRTTI ON}

{$IF DECLARED(TVisibilityClasses)}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$ENDIF}

{$R *.res}

uses
  System.Classes,
  System.SysUtils,
  Winapi.Windows;


procedure RaiseInvalidExecutrable;
begin
  raise Exception.Create('Invalid executable');
end;

function Isx64PEImage(const AStrm: TStream): Boolean; overload;
var
  LDOSHeader: TImageDosHeader;
  LImageNtHeaders: TImageNtHeaders;
begin
  if AStrm.Read(LDOSHeader, SizeOf(TImageDosHeader)) <> SizeOf(TImageDosHeader) then
    RaiseInvalidExecutrable;

  if (LDOSHeader.e_magic <> IMAGE_DOS_SIGNATURE) or (LDOSHeader._lfanew = 0) then
    RaiseInvalidExecutrable;

  if AStrm.Size < LDOSHeader._lfanew then
    RaiseInvalidExecutrable;

  AStrm.Position := LDOSHeader._lfanew;
  if AStrm.Read(LImageNtHeaders, SizeOf(TImageNtHeaders)) <> SizeOf(TImageNtHeaders) then
    RaiseInvalidExecutrable;

  if LImageNtHeaders.Signature <> IMAGE_NT_SIGNATURE then
    RaiseInvalidExecutrable;

  Result := LImageNtHeaders.FileHeader.Machine <> IMAGE_FILE_MACHINE_I386;
end;

function Isx64PEImage(const APEImageFileName: string): Boolean; overload;
var
  LPEImageSream: TBufferedFileStream;
begin
  LPEImageSream := TBufferedFileStream.Create(APEImageFileName, fmOpenRead);
  try
    Result := Isx64PEImage(LPEImageSream);
  finally
    LPEImageSream.Free;
  end;
end;

procedure PrintUsage;
var
  LExeName: string;
begin
  LExeName := ExtractFileName(ParamStr(0));

  WriteLn(LExeName + ' (version 0.1)');
  WriteLn('');
  WriteLn('  Usage:');
  WriteLn('    ' + LExeName + ' [path and filename]');
end;

var
  LPeFileToCheck: string;
begin
  try
    if ParamCount >= 1 then
      LPeFileToCheck := ParamStr(1);

    if not FileExists(LPeFileToCheck)  then
    begin
      PrintUsage;
      ExitCode := 1;
      Exit;
    end;

    if Isx64PEImage(LPeFileToCheck) then
      WriteLn('x64')
    else
      WriteLn('x86');

    {$IFDEF DEBUG}
    Readln;
    {$ENDIF}
  except
    on E: Exception do
    begin
      Writeln('');
      Writeln('Exception while checking file: ');
      Writeln('  ' + E.ClassName + ': ' + E.Message);
      ExitCode := 2;
    end;
  end;
end.
