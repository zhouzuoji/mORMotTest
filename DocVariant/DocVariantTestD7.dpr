program DocVariantTestD7;

{$APPTYPE CONSOLE}

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
  try
    test;
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
  Writeln('press <ENTER> to eixt...');
  Readln;
end.
