program DocVariantTest;

{$APPTYPE CONSOLE}
{$I SynDprUses.inc}
{$I Synopse.inc}

uses
  {$I SynDprUses.inc}
  SysUtils,
  Windows,
  Classes,
  Variants,
  VarUtils,
  SynCommons,
  uDocVariantTest in 'uDocVariantTest.pas';

begin
  System.ReportMemoryLeaksOnShutdown := True;
  try
    test;
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
  Writeln('press <ENTER> to eixt...');
  Readln;
end.
