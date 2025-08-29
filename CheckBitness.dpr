program CheckBitness;

{$APPTYPE CONSOLE}

// Disable the "new" RTTI to make exe smaller
{$WEAKLINKRTTI ON}

{$IF DECLARED(TVisibilityClasses)}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$ENDIF}

{$R *.res}

uses
  System.SysUtils,
  CBUnit.CheckBitness in 'CBUnit.CheckBitness.pas';

procedure PrintUsage;
var
  LExeName: string;
begin
  LExeName := ExtractFileName(ParamStr(0));

  WriteLn(LExeName + ' (version 0.2)');
  WriteLn('');
  WriteLn('  Usage:');
  WriteLn('    ' + LExeName + ' [path and filename]');
end;

const
  EXIT_CODE_FILE_NOT_FOUND = 1;
  EXIT_CODE_FILE_NOT_GIVEN = 2;
  EXIT_CODE_UNKNOWN_OR_UNSUPPORTED_CPU_ARCHITECTURE = 3;
  EXIT_CODE_EXCEPTION = 4;
var
  LPeFileToCheck: string;
begin
  try
    if ParamCount >= 1 then
      LPeFileToCheck := ParamStr(1);

    if not FileExists(LPeFileToCheck)  then
    begin
      PrintUsage;

      if LPeFileToCheck.IsEmpty then
        ExitCode := EXIT_CODE_FILE_NOT_GIVEN
      else
        ExitCode := EXIT_CODE_FILE_NOT_FOUND;

      Exit;
    end;

    case GetPEImageArchitecture(LPeFileToCheck) of
      piaSupported:
        begin
          WriteLn('Unknown or unsupported CPU architecture');
          ExitCode := EXIT_CODE_UNKNOWN_OR_UNSUPPORTED_CPU_ARCHITECTURE;
        end;
      piaX86: WriteLn('x86');
      piaX64: WriteLn('x64');
    end;

    {$IFDEF DEBUG}
    Readln;
    {$ENDIF}
  except
    on E: Exception do
    begin
      Writeln('');
      Writeln('Exception while checking file: ');
      Writeln('  ' + E.ClassName + ': ' + E.Message);
      ExitCode := EXIT_CODE_EXCEPTION;
    end;
  end;
end.
