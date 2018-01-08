program DocVariantTestD7;

{$APPTYPE CONSOLE}

{$I Synopse.inc}

uses
  {$I SynDprUses.inc}
  SysUtils,
  main;

begin
  try
    ConsoleMain;
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
  Writeln('press <ENTER> to eixt...');
  Readln;
end.
