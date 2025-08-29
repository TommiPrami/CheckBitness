unit CBUnit.CheckBitness;

interface

uses
  Winapi.Windows, System.Classes, System.SysUtils;

type
  TPEImageArchitecture = (piaSupported, piaX86, piaX64);

  function GetPEImageArchitecture(const APEImageFileName: string): TPEImageArchitecture;

implementation

procedure RaiseInvalidExecutable;
begin
  raise Exception.Create('Invalid executable');
end;

function InternalGetPEImageArchitecture(const AStream: TStream): TPEImageArchitecture;
var
  LDOSHeader: TImageDosHeader;
  LImageNtHeaders: TImageNtHeaders;
begin
  if AStream.Read(LDOSHeader, SizeOf(TImageDosHeader)) <> SizeOf(TImageDosHeader) then
    RaiseInvalidExecutable;

  if (LDOSHeader.e_magic <> IMAGE_DOS_SIGNATURE) or (LDOSHeader._lfanew = 0) then
    RaiseInvalidExecutable;

  if AStream.Size < LDOSHeader._lfanew then
    RaiseInvalidExecutable;

  AStream.Position := LDOSHeader._lfanew;
  if AStream.Read(LImageNtHeaders, SizeOf(TImageNtHeaders)) <> SizeOf(TImageNtHeaders) then
    RaiseInvalidExecutable;

  if LImageNtHeaders.Signature <> IMAGE_NT_SIGNATURE then
    RaiseInvalidExecutable;

  if LImageNtHeaders.FileHeader.Machine = IMAGE_FILE_MACHINE_AMD64 then
    Result := piaX64
  else if LImageNtHeaders.FileHeader.Machine = IMAGE_FILE_MACHINE_I386 then
    Result := piaX86
  else
    Result := piaSupported;
end;

function GetPEImageArchitecture(const APEImageFileName: string): TPEImageArchitecture;
var
  LPEImageStream: TBufferedFileStream;
begin
  LPEImageStream := TBufferedFileStream.Create(APEImageFileName, fmOpenRead);
  try
    Result := InternalGetPEImageArchitecture(LPEImageStream);
  finally
    LPEImageStream.Free;
  end;
end;

end.
