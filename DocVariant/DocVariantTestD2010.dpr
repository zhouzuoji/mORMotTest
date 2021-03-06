program DocVariantTestD2010;
{$APPTYPE CONSOLE}
{$I Synopse.inc}

uses
  SysUtils,
  SynCommons,
  Windows,
  Clipbrd,
  uDocVariantTest in 'uDocVariantTest.pas',
  ParseNumberTest in 'ParseNumberTest.pas',
  main in 'main.pas';

begin
  System.ReportMemoryLeaksOnShutdown := True;
  RandSeed := GetTickCount;
  Randomize;
  try
    ConsoleMain;
  except
    on E: Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
  Writeln('press <ENTER> to eixt...');
  Readln;
end.
