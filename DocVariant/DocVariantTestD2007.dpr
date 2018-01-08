program DocVariantTestD2007;

{$APPTYPE CONSOLE}
{$I Synopse.inc}

uses
  {$I SynDprUses.inc}
  SysUtils,
  SynCommons,
  ParseNumberTest,
  main,
  uDocVariantTest in 'uDocVariantTest.pas';

begin
  System.ReportMemoryLeaksOnShutdown := True;
  try
    test1;
    NumberParsingBenchmark;
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
  Writeln('press <ENTER> to eixt...');
  Readln;
end.
