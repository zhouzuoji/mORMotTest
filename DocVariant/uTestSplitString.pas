unit uTestSplitString;
{$I Synopse.inc}
{$I HPPas.inc}
interface
uses
  SysUtils,
  Math,
{$ifdef MSWINDOWS}
  Windows,
{$endif}
  Variants,
  Classes,
  SynCommons,
  HPPas,
  HppTypeCast,
  HppSysUtils,
  HppStrs,
  HppVariants,
  HppJSONParser;

procedure TestSplitString;

implementation

procedure TestSplitString;
var
  s, sep: string;
  res: THppArray<TStringView>;
  i: Integer;
begin
  Writeln('------- SplitString test -------');
  while True do
  begin
    Writeln('enter any string(for back, enter <break>) :');
    Readln(s);
    if SameText(SysUtils.Trim(s), 'break') then Break;
    Writeln('enter separators(for back, enter <break>) :');
    Readln(sep);
    if SameText(SysUtils.Trim(s), 'break') then Break;
    if (s='') then Continue;
    res := HppStrs.split(s, sep);
    for i := 0 to res.length - 1 do
      Writeln(i, ': ', res.items(i).ToUTF16String());
  end;
end;

end.
