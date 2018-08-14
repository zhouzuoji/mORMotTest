unit main;
{$I Synopse.inc}
{$I HPPas.inc}
interface
uses
  SysUtils, Classes, Math, Variants, TypInfo,
{$ifdef MSWINDOWS}
  Windows,
{$endif}
  SynCommons, HPPas, HppMagic, HppTypeCast, HppSysUtils, HppScript,
  ParseNumberTest, JSONTest, DynamicInvokeTest, uDocVariantTest, uTestSplitString;

procedure ConsoleMain;

implementation

procedure TestStringHeader;
var
  s: string;
{$if SizeOf(Char)=1}
  s2: UTF16String;
{$else }
  s2: RawByteString;
{$ifend}
{$ifdef MSWINDOWS}
  bs: WideString;
{$endif}
begin
  Writeln('------- StringHeader test -------');
  while True do
  begin
    Writeln('enter any string(for back, enter <break>) :');
    Readln(s);
    if SameText(SysUtils.Trim(s), 'break') then Break;
    if SameText(SysUtils.Trim(s), '') then Continue;
    Writeln('length: ', LengthOf(s));
    Writeln('detail: ', StringInfo(s));
    {$ifdef MSWINDOWS}
    bs := WideString(s);
    Writeln('Rtl.Length(bs): ', Length(bs));
    Writeln('LengthOf(bs): ', LengthOf(bs));
    {$endif}
    {$if SizeOf(Char)=1}
    s2 := UTF16String(s);
    Writeln('LengthOf(UTF16str): ', LengthOf(s2));
    Writeln('detail(UTF16str): ', StringInfo(s2));
    {$else }
    s2 := RawByteString(s);
    Writeln('LengthOf(AnsiStr): ', LengthOf(s2));
    Writeln('detail(AnsiStr): ', StringInfo(s2));
    {$ifend}
  end;
end;

type
  T3BytesRecord = packed record
    a: Byte;
    b: Word;
  end;

  T4BytesRecord = packed record
    a: Word;
    b: Word;
  end;

  TPointerRecord = packed record
    a: Pointer;
  end;

  TStringRecord = packed record
    a: string;
    b: Integer;
  end;

  TVariantRecord = packed record
    a: Variant;
  end;

  TStringArray = array [0..8] of array [Boolean] of TStringRecord;

function TestRecord3(_1: Integer; _2: T3BytesRecord; const _3: T3BytesRecord;
  var _4: T3BytesRecord): T3BytesRecord;
begin
  Result.a := _2.a + _3.a + _4.a;
  Result.b := _2.b + _3.b + _4.b;
end;

function TestRecord4(_1: Integer; _2: T4BytesRecord; const _3: T4BytesRecord;
  var _4: T4BytesRecord): T4BytesRecord;
begin
  Result.a := _2.a + _3.a + _4.a;
  Result.b := _2.b + _3.b + _4.b;
end;

function TestPointerRecord(_1: Integer; _2: TPointerRecord; const _3: TPointerRecord;
  var _4: TPointerRecord): TPointerRecord;
begin
  PtrInt(Result.a) := PtrInt(_2.a) + PtrInt(_3.a) + PtrInt(_4.a);
end;

function TestStringRecord(_1: Integer; _2: TStringRecord; const _3: TStringRecord;
  var _4: TStringRecord): TStringRecord;
begin
  Result.a := _2.a + _3.a + _4.a;
end;

function TestVariantRecord(_1: Integer; _2: TVariantRecord; const _3: TVariantRecord;
  var _4: TVariantRecord): TVariantRecord;
begin
  Result.a := _2.a + _3.a + _4.a;
end;

function GetArrayTypeDesc(ATypeInfo: PTypeInfo): string;
var
  ptd: PArrayTypeData;
begin
  ptd := PArrayTypeData(GetTypeData(ATypeInfo));
  Result := string(ATypeInfo.Name) + ' Size: ' +
  {$if defined(FPC) and defined(VER2_6)}
  IntToStr(ptd^.Size * ptd^.ElCount)
  {$else}
  IntToStr(ptd^.Size)
  {$ifend}
    + ', ElCount: ' + IntToStr(ptd^.ElCount) + ', ElType: ' + string(GetElementType(ptd^.ElType).Name)
  {$ifdef ISDELPHI2010_OR_FPC_NEWRTTI}
  + ', DimCount: ' + IntToStr(ptd^.DimCount)
  {$endif}
end;

procedure aa;
var
  rec3: T3BytesRecord;
  rec4: T4BytesRecord;
  ptrrec: TPointerRecord;
  str: TStringRecord;
  v: TVariantRecord;
  sarr1, sarr2: TStringArray;
begin
  rec3.a := 1;
  rec3.b := 2;
  rec3 := TestRecord3(2, rec3, rec3, rec3);
  Writeln(rec3.a, ' ', rec3.b);

  rec4.a := 1;
  rec4.b := 2;
  rec4 := TestRecord4(2, rec4, rec4, rec4);
  Writeln(rec4.a, ' ', rec4.b);

  PtrInt(ptrrec.a) := 1;
  ptrrec := TestPointerRecord(2, ptrrec, ptrrec, ptrrec);
  Writeln(PtrInt(ptrrec.a));

  str.a := 'str ';
  str := TestStringRecord(2, str, str, str);
  Writeln(str.a);

  Writeln('SizeOfType(TStringRecord): ', SizeOfType(TypeInfo(TStringRecord)));
  Writeln('SizeOfType(TVariantRecord): ', SizeOfType(TypeInfo(TVariantRecord)));
  Writeln('SizeOfType(TStringArray): ', SizeOfType(TypeInfo(TStringArray)));
  Writeln(PTypeInfo(TypeInfo(TStringRecord))^.name);
  Writeln(PTypeInfo(TypeInfo(TVariantRecord))^.name);
  Writeln(PTypeInfo(TypeInfo(TStringArray))^.name);
  Writeln(GetArrayTypeDesc(PTypeInfo(TypeInfo(TStringArray))));

  sarr2 := sarr1;

  v.a := 'str ';
  v := TestVariantRecord(2, v, v, v);
  Writeln(str.a);
  //pti := TypeInfo(T3BytesRecord);
  //Writeln(Ord(pti^.Kind), ' ', pti^.Name);
end;

procedure ShowHelp;
begin
  Writeln('enter corresponding index to select an command');
  Writeln('  0: show this help');
  Writeln('  1: test [HppTypeCast.ParseNumber]');
  Writeln('  2: benchmark [number parsing]');
  Writeln('  3: test [HppJSONParse] ');
  Writeln('  4: test [integer +-/*]');
  Writeln('  5: test [invoke with array of const parameters]');
  Writeln('  6: test [invoke with array of Rtti.TValue parameters]');
  Writeln('  7: test [split string]');
end;

procedure ConsoleMain;
var
  s: string;
  number: TNumber;
begin
  RandSeed := Integer(GetTickCount64);
  Randomize;
  aa;
  //TestStringHeader;
  //PrintSizeOf;
  test3;
  test4;
  //HppVariantsTest;
  //TestRttiSerialize;
  //TestSmartString;
  //FunctionTest_SynTypeCast_ParseNumber;
  //IntegerTest;
  //TestInt64NegOperation;
  Writeln('*************** test and benchmark ***************');
  ShowHelp;
  while True do
  begin
    Write('<: ');
    Readln(s);
    s := SysUtils.Trim(s);
    if (s = '') or (s = 'exit') then
      Break;
    ParseNumber(s, number.data, [scoStrict, scoIntegerOnly]);
    if not number.IsInteger then
    begin
      Writeln('invalid command');
      Continue;
    end;

    case number.ToInt32 of
      0: ShowHelp;
      1: FunctionTest_HppTypeCast_ParseNumber;
      2: NumberParsingBenchmark;
      3: FunctionTest_HppJSONParser;
      4: IntegerTest;
      5: TestInvokeWithArrayOfConst;
      6: TestInvokeWithArrayOfRttiValue;
      7: TestSplitString;
    else
      Writeln('invalid command');
    end;
  end;
end;

end.

