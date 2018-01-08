program DocVariantTestDXE10;

{$APPTYPE CONSOLE}

{$I Synopse.inc}

uses
  SysUtils,
  main in 'main.pas';

begin
  System.ReportMemoryLeaksOnShutdown := True;
  try
    ConsoleMain;
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
  Writeln('press <ENTER> to eixt...');
  Readln;
end.
