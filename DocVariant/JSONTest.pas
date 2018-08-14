unit JSONTest;
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
  HppStrs,
  HppTypeCast,
  HppSysUtils,
  HppVariants,
  HppJSONParser;

procedure FunctionTest_HppJSONParser;

implementation

procedure cmdhp_FunctionTest_HppJSONParser;
begin
  Writeln('valid commands ');
  Writeln('  help: show this help');
  Writeln('  break: quit current test');
  Writeln('  expr: show current json value');
  Writeln('  path <JsonPath>: access json property');
  Writeln('  loadfile <JsonFileName>: parsing a file');
  Writeln('  parse <JsonString>: parse a string');
end;

procedure FunctionTest_HppJSONParser;
var
  s: string;
  ss: THppArray<TStringView>;
  s1, s2: string;
  V: Variant;
  fileContent: UTF8String;
  endat: PAnsiChar;
begin
  writeln('------- function test DSLJsonParsing -------');
  cmdhp_FunctionTest_HppJSONParser;
  try
    while True do
    begin
      Write('command: ');
      Readln(s);
      s := SysUtils.Trim(s);
      if s = '' then  Continue;
      ss := HppStrs.split(s, [], [], 2);
      case ss.length of
        0: Continue;
        1: begin s1 := ss.items(0).ToUTF16String; s2 := ''; end;
      else begin s1 := ss.items(0).ToUTF16String; s2 := ss.items(1).ToUTF16String; end;
      end;
      s1 := SysUtils.Trim(s1);
      s2 := SysUtils.Trim(s2);
      if SameText(s1, 'break') then Break;
      if SameText(s1, 'help') then
        cmdhp_FunctionTest_HppJSONParser
      else if SameText(s1, 'expr') then
        Writeln(V)
      else if SameText(s1, 'path') then
      begin
        if s2 = '' then
        begin
          Writeln('path missed');
          Continue;
        end;
        if (TVarData(V).VType = JsonVarTypeID) and (TVariantContainerWrapper(V).ContainerType = vdtObject) then
          writeln(THppVariantObject(TVariantContainerWrapper(V).instance).ResolvePath(PAnsiChar(UTF8Encode(s2))))
        else writeln('not object');
      end
      else if SameText(s1, 'loadfile') then
      begin
        if s2 = '' then
        begin
          writeln('file name missed');
          Continue;
        end;

        if not FileExists(s2) then
        begin
          writeln('file not found');
          Continue;
        end;
        VarClear(V);
        fileContent := StringFromFile(s2);
        V := ParseJSON(PAnsiChar(Pointer(fileContent)), @endat);
        if endat^ <> #0 then
          writeln('end at: ', endat);
      end
      else if SameText(s1, 'parse') then
      begin
        if s2 = '' then
        begin
          writeln('json missed');
          Continue;
        end;
        VarClear(V);
        fileContent := UTF8Encode(s2);
        V := ParseJSON(PAnsiChar(Pointer(fileContent)), @endat);
        if endat^ <> #0 then
          writeln('end at: ', endat);
      end
      else
        writeln('bad command');
    end;
  finally
  end;
end;

end.
