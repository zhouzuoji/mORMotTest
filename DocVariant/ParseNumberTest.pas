unit ParseNumberTest;
{$I Synopse.inc}
{$I HPPas.inc}
interface
uses
  SysUtils, Classes, Math,
{$ifdef MSWINDOWS}
  Windows,
{$endif}
  SynCommons, HPPas, HppTypeCast, HppSysUtils;

procedure FunctionTest_HppTypeCast_ParseNumber;
procedure FunctionTest_HppTypeCast_ParseBool;
procedure NumberParsingBenchmark; overload;
procedure IntegerTest;
procedure TestInt64NegOperation(repeatCount: Integer = 100000000);

implementation

function PseudoInt(const s: string): TAny;
begin
  if SameText(s, 'High(UInt8)') then
    Result.setUInt32(High(UInt8))
  else if SameText(s, 'High(Int8)') then
    Result.setInt32(High(Int8))
  else if SameText(s, 'Low(Int8)') then
    Result.setInt32(Low(Int8))
  else if SameText(s, 'High(UInt16)') then
    Result.setUInt32(High(UInt16))
  else if SameText(s, 'High(Int16)') then
    Result.setInt32(High(Int16))
  else if SameText(s, 'Low(Int16)') then
    Result.setInt32(Low(Int16))
  else if SameText(s, 'High(UInt32)') then
    Result.setUInt32(High(UInt32))
  else if SameText(s, 'High(Int32)') then
    Result.setInt32(High(Int32))
  else if SameText(s, 'Low(Int32)') then
    Result.setInt32(Low(Int32))
  else if SameText(s, 'High(UInt64)') then
    Result.setUInt64(UInt64(-1))
  else if SameText(s, 'High(Int64)') then
    Result.setInt64(High(Int64))
  else if SameText(s, 'Low(Int64)') then
    Result.setInt64(Low(Int64))
  else
    Result.data.VType := vdtEmpty;
end;

function GetInputNumber(const s: string): TAny;
var
{$if SizeOf(Char)=1}
  endat: PAnsiChar;
{$else}
  endat: PWideChar;
{$ifend}
begin
{$if SizeOf(Char)=1}
  ParseNumber(PAnsiChar(Pointer(s)), Result.data, endat);
{$else}
  ParseNumber(PWideChar(Pointer(s)), Result.data, endat);
{$ifend}
  if Result.IsEmptyOrNull or (endat^ <> #0) then
    Result := PseudoInt(s);
end;

procedure FunctionTest_HppTypeCast_ParseNumber;
var
  s, trimeds: string;
  ansi: RawByteString;
  utf16: UTF16String;
  number: TAny;
  pAnsi, pEndAtAnsi: PAnsiChar;
  pUTF16, pEndAtUTF16: PWideChar;
begin
  Writeln('------- HppTypeCast.ParseNumber function test -------');
  Writeln('enter a number for parsing');
  Writeln('for back, enter <break>');
  while True do
  begin
    Write('enter a number for parsing: ');
    Readln(s);
    trimeds := SysUtils.Trim(s);
    if trimeds = '' then
      Continue;
    if SameText(trimeds, 'break') then
      Break;

    number := PseudoInt(trimeds);
    if not number.IsEmptyOrNull then
    begin
      ansi := number.ToRawBytes;
      utf16 := number.ToUTF16Str;
    end
    else begin
      ansi := RawByteString(s);
      utf16 := UTF16String(s);
    end;
    pAnsi := PAnsiChar(ansi);
    pUTF16 := PWideChar(utf16);

    parseNumber(pAnsi, number.data, pEndAtAnsi);
    Write('ParseNumber_Ansi: ', number.expr);
    if pEndAtAnsi^ <> #0 then
      Write(', parsing end at: ', pEndAtAnsi);
    Writeln;

    parseNumber(pAnsi, Length(ansi), number.data, pEndAtAnsi);
    Write('ParseNumberL_Ansi: ', number.expr);
    if pEndAtAnsi^ <> #0 then
      Write(', parsing end at: ', pEndAtAnsi);
    Writeln;

    parseNumber(pUTF16, number.data, pEndAtUTF16, []);
    Write('ParseNumber_UTF16: ', number.expr);
    if pEndAtUTF16^ <> #0 then
      Write(', parsing end at: ', pEndAtUTF16^);
    Writeln;

    parseNumber(pUTF16, Length(utf16), number.data, pEndAtUTF16);
    Write('ParseNumberL_UTF16: ', number.expr);
    if pEndAtUTF16^ <> #0 then
      Write(', parsing end at: ', pEndAtUTF16^);
    Writeln;
  end;
end;

procedure FunctionTest_HppTypeCast_ParseBool;
var
  s: string;
  ansi: RawByteString;
  utf16: UTF16String;
  value: TNullableBool;
  pAnsi, pEndAtAnsi: PAnsiChar;
  pUTF16, pEndAtUTF16: PWideChar;
begin
  Writeln('------- HppTypeCast.ParseBool function test -------');
  Writeln('enter a number for parsing');
  Writeln('for back, enter <break>');
  while True do
  begin
    Write('enter a number for parsing: ');
    Readln(s);
    if SameText(SysUtils.Trim(s), 'break') then
      Break;
    if SysUtils.Trim(s) = '' then
      Continue;
    if SameText(s, 'High(UInt32)') then
      s := IntToString( High(UInt32))
    else if SameText(s, 'High(Int32)') then
      s := IntToString( High(Int32))
    else if SameText(s, 'Low(Int32)') then
      s := IntToString( Low(Int32))
    else if SameText(s, 'High(Int64)') then
      s := IntToString( High(Int64))
    else if SameText(s, 'Low(Int64)') then
      s := IntToString( Low(Int64))
    else if SameText(s, 'High(UInt64)') then
      s := UInt64ToString( High(UInt64));
    ansi := RawByteString(s);
    utf16 := UTF16String(s);
    pAnsi := PAnsiChar(ansi);
    pUTF16 := PWideChar(utf16);

    value := ParseBool(pAnsi, pEndAtAnsi);
    Write('ParseBool_Ansi: ', value.ToString);
    if pEndAtAnsi^ <> #0 then
      Write(', parsing end at: ', pEndAtAnsi);
    Writeln;

    value := ParseBool(pAnsi, Length(ansi), pEndAtAnsi);
    Write('ParseBoolL_Ansi: ', value.ToString);
    if pEndAtAnsi^ <> #0 then
      Write(', parsing end at: ', pEndAtAnsi);
    Writeln;

    value := ParseBool(pUTF16, pEndAtUTF16, []);
    Write('ParseBool_UTF16: ', value.ToString);
    if pEndAtUTF16^ <> #0 then
      Write(', parsing end at: ', pEndAtUTF16^);
    Writeln;

    value := ParseBool(pUTF16, Length(utf16), pEndAtUTF16);
    Write('ParseBoolL_UTF16: ', value.ToString);
    if pEndAtUTF16^ <> #0 then
      Write(', parsing end at: ', pEndAtUTF16^);
    Writeln;
  end;
end;

procedure NumberParsingBenchmark(s: string; repeatCount: Integer = 10000000); overload;
var
  i, len, len2: Integer;
  tw: TStopWatch;
  errcode: Integer;
  number: TAny;
  p, pNum, pEndAt: PAnsiChar;
  rbs: RawByteString;
  us: UTF16String;
  pw, pNumw, pEndAtW (*, pErr*): PWideChar;
  sign: TNumberSign;
  buf: array [0 .. 127] of AnsiChar;
  bufw: array [0 .. 127] of WideChar;
  num: TAnyData;
  timeEllapsed: UInt32;
begin
  rbs := RawByteString(s);
  us := UTF16String(s);
  p := PAnsiChar(rbs);
  pw := PWideChar(us);
  len := Length(s);

  for i := 0 to len - 1 do
  begin
    buf[i] := p[i];
    bufw[i] := pw[i];
		end;
  buf[len] := #0;
  bufw[len] := #0;

  parseNumber(buf, num, pEndAt, [scoIntegerOnly]);
  parseNumber(buf, number.data, pEndAt, [scoIntegerOnly]);

  tw.start;
  for i := 1 to repeatCount do
    parseNumber(buf, num, pEndAt, [scoIntegerOnly]);
  Writeln('HppTypeCast.ParseInteger_ansi: ', tw.stop, ' ms');

  tw.start;
  for i := 1 to repeatCount do
    parseNumber(buf, number.data, pEndAt, [scoIntegerOnly]);
  timeEllapsed := tw.stop;
  Writeln('HppTypeCast.ParseInteger_ansi: ', timeEllapsed, ' ms, result ', number.expr);

  tw.start;
  for i := 1 to repeatCount do
    ParseNumber(buf, len, number.data, pEndAt, [scoIntegerOnly]);
  timeEllapsed := tw.stop;
  Writeln('HppTypeCast.ParseIntegerL_ansi: ', timeEllapsed, ' ms, result ', number.expr);

  tw.start;
  for i := 1 to repeatCount do
    ParseNumber(buf, number.data, pEndAt);
  timeEllapsed := tw.stop;
  Writeln('HppTypeCast.ParseNumber_ansi: ', timeEllapsed, ' ms, result ', number.expr);

  tw.start;
  for i := 1 to repeatCount do
    ParseNumber(buf, len, number.data, pEndAt);
  timeEllapsed := tw.stop;
  Writeln('HppTypeCast.ParseNumberL_ansi: ', timeEllapsed, ' ms, result ', number.expr);

  tw.start;
  for i := 1 to repeatCount do
    ParseNumber(pw, number.data, pEndAtW, [scoIntegerOnly]);
  timeEllapsed := tw.stop;
  Writeln('HppTypeCast.ParseInteger_wide: ', timeEllapsed, ' ms, result ', number.expr);

  tw.start;
  for i := 1 to repeatCount do
    ParseNumber(pw, len, number.data, pEndAtW, [scoIntegerOnly]);
  timeEllapsed := tw.stop;
  Writeln('HppTypeCast.ParseIntegerL_wide: ', timeEllapsed, ' ms, result ', number.expr);

  tw.start;
  for i := 1 to repeatCount do
    ParseNumber(pw, number.data, pEndAtW);
  timeEllapsed := tw.stop;
  Writeln('HppTypeCast.ParseNumber_wide: ', timeEllapsed, ' ms, result ', number.expr);

  tw.start;
  for i := 1 to repeatCount do
    ParseNumber(pw, len, number.data, pEndAtW);
  timeEllapsed := tw.stop;
  Writeln('HppTypeCast.ParseNumberL_wide: ', timeEllapsed, ' ms, result ', number.expr);

  if number.isInteger then
  begin
    sign := number.NumberSign;
    if sign = nsNegative then
    begin
      pNum := @buf[1];
      pNumw := @bufw[1];
      len2 := len - 1;
    end
    else
    begin
      pNum := buf;
      pNumw := bufw;
      len2 := len;
    end;
    tw.start;
    for i := 1 to repeatCount do
      CalcInt(sign, False, pNum, len2, number.data);
    timeEllapsed := tw.stop;
    Writeln('HppTypeCast.CalcInt: ', timeEllapsed, ' ms, result ', number.expr);

    tw.start;
    for i := 1 to repeatCount do
      CalcInt(sign, False, pNumw, len2, number.data);
    timeEllapsed := tw.stop;
    Writeln('HppTypeCast.CalcInt_utf16: ', timeEllapsed, ' ms, result ', number.expr);

    {$ifdef CPU64}
    tw.start;
    for i := 1 to repeatCount do
      CalcInt64(sign, False, pNum, len2, number.data);
    timeEllapsed := tw.stop;
    Writeln('HppTypeCast.CalcInt64: ', timeEllapsed, ' ms, result ', number.expr);

    tw.start;
    for i := 1 to repeatCount do
      CalcInt64(sign, False, pNumw, len2, number.data);
    timeEllapsed := tw.stop;
    Writeln('HppTypeCast.CalcInt64_utf16: ', timeEllapsed, ' ms, result ', number.expr);
    {$endif}
  end;

  if number.IsInteger and number.isPositive then
  begin
    if number.ToUInt64 <= UInt64(High(UInt32)) then
    begin
      tw.start;
      for i := 1 to repeatCount do
        Val(s, number.data.VUInt32, errcode);
      Writeln('rtl.StrToUInt32: ', tw.stop, ' ms, result ', number.data.VUInt32);
    end;

    {$ifdef HASINLINE}
    tw.start;
    for i := 1 to repeatCount do
      Val(s, number.data.VUInt64, errcode);
    Writeln('rtl.StrToUInt64: ', tw.stop, ' ms, result ', number.data.VUInt64);
    {$endif}

    if number.ToUInt64 <= High(Int32) then
    begin
      tw.start;
      for i := 1 to repeatCount do
        Val(s, number.data.VInt32, errcode);
      Writeln('rtl.StrToInt32: ', tw.stop, ' ms, result ', number.data.VInt32);

      {$ifndef CPU64}
      tw.start;
      for i := 1 to repeatCount do
        number.data.VInt32 := GetInteger(PUTF8Char(p), errcode);
      Writeln('SynCommons.GetInteger: ', tw.stop, ' ms, result ', number.data.VInt32);
      {$endif}
    end;

    if number.ToUInt64 <= High(Int64) then
    begin
      tw.start;
      for i := 1 to repeatCount do
        Val(s, number.data.VInt64, errcode);
      Writeln('rtl.StrToInt64: ', tw.stop, ' ms, result ', number.data.VInt64);

      {$ifdef CPU64}
      tw.start;
      for i := 1 to repeatCount do
        number.data.VInt64 := GetInteger(PUTF8Char(p), errcode);
      Writeln('SynCommons.GetInteger: ', tw.stop, ' ms, result ', number.data.VInt64);
      {$endif}
    end;
  end
  else if number.IsInteger and number.IsNegative then
  begin
    if (number.ToInt64 >= Low(Int32)) and (number.ToInt64 <= High(Int32)) then
    begin
      tw.start;
      for i := 1 to repeatCount do
        Val(s, number.data.VInt32, errcode);
      Writeln('rtl.StrToInt32: ', tw.stop, ' ms, result ', number.data.VInt32);

      {$ifndef CPU64}
      tw.start;
      for i := 1 to repeatCount do
        number.data.VInt32 := GetInteger(PUTF8Char(p), errcode);
      Writeln('SynCommons.GetInteger: ', tw.stop, ' ms, result ', number.data.VInt32);
      {$endif}
    end;

    {$ifdef CPU64}
    tw.start;
    for i := 1 to repeatCount do
      number.data.VInt64 := GetInteger(PUTF8Char(p), errcode);
    Writeln('SynCommons.GetInteger: ', tw.stop, ' ms, result ', number.data.VInt64);
    {$endif}

    tw.start;
    for i := 1 to repeatCount do
      Val(s, number.data.VInt64, errcode);
    Writeln('rtl.StrToInt64: ', tw.stop, ' ms, result ', number.data.VInt64);
  end;

  tw.start;
  for i := 1 to repeatCount do
    number.data.VInt64 := GetInt64(PUTF8Char(p), errcode);
  Writeln('SynCommons.GetInt64: ', tw.stop, ' ms, result ', number.data.VInt64);

  tw.start;
  for i := 1 to repeatCount do
    number.data.VUInt64 := UInt64(GetQWord(PUTF8Char(p), errcode));
  Writeln('SynCommons.GetUInt64: ', tw.stop, ' ms, result ', number.data.VUInt64);
  (*
    tw.start;
    for i := 1 to repeatCount do
    TextToFloat(PChar(s), flt, fvExtended);
    Writeln('rtl.TextToFloat: ', tw.stop, ' ms, result ', flt);

    tw.start;
    for i := 1 to repeatCount do
    flt := StrToFloat(s);
    Writeln('rtl.StrToFloat: ', tw.stop, ' ms, result ', flt);

  tw.start;
  for i := 1 to repeatCount do
    number.setExtended(HppTypeCast.parseFloat(p, @pNum));
  Writeln('HppTypeCast.parseFloat ansi: ', tw.stop, ' ms, result ', number.toExtended, ', end At: ', pNum);

  pErr := nil;
  tw.start;
  for i := 1 to repeatCount do
    number.setExtended(HppTypeCast.parseFloat(pw, @pErr));
  Writeln('HppTypeCast.parseFloat wide: ', tw.stop, ' ms, result ', number.toExtended, ', end At: ', pErr);
  *)
  tw.start;
  for i := 1 to repeatCount do
    number.setDouble(GetExtended(PUTF8Char(p)));
  Writeln('SynCommons.GetExtended: ', tw.stop, ' ms, result ', number.toExtended);
end;

procedure NumberParsingBenchmark; overload;
var
  s, trimed: string;
  number: TAny;
begin
  Writeln('------- string to number benckmark -------');
  while True do
  begin
    Write('enter a number for parsing(for back, enter <break>): ');
    Readln(s);
    trimed := SysUtils.Trim(s);
    if trimed = '' then
      Continue;
    if SameText(trimed, 'break') then
      Break;

    number := PseudoInt(trimed);
    if not number.IsEmptyOrNull then
    {$if SizeOf(Char)=1}
      s := number.ToRawBytes;
    {$else}
      s := number.ToUTF16Str;
    {$ifend}

    NumberParsingBenchmark(s);
  end;
end;

procedure IntegerTestWith(a, b: TAny; repeatCount: Integer);
var
  tw: TStopWatch;
  i: Integer;
  i32_1, i32_2, i32_r: Integer;
  i64_1, i64_2, i64_r: Int64;
begin
  i32_1 := a.ToInt32;
  i32_2 := b.ToInt32;
  i64_1 := a.ToInt64;
  i64_2 := b.ToInt64;
  i32_r := 0;
  i64_r := 0;
  tw.start;
  for i := 1 to repeatCount do
    i32_r := i32_1 + i32_2;
  Writeln('32 bit +: ', tw.stop, ' ms, result ', i32_r);

  tw.start;
  for i := 1 to repeatCount do
    i32_r := i32_1 - i32_2;
  Writeln('32 bit -: ', tw.stop, ' ms, result ', i32_r);

  tw.start;
  for i := 1 to repeatCount do
    i32_r := i32_1 * i32_2;
  Writeln('32 bit *: ', tw.stop, ' ms, result ', i32_r);

  tw.start;
  for i := 1 to repeatCount do
    i32_r := i32_1 * 10;
  Writeln('32 bit * 10: ', tw.stop, ' ms, result ', i32_r);

  tw.start;
  for i := 1 to repeatCount do
    i32_r := i32_1 * 100;
  Writeln('32 bit * 100: ', tw.stop, ' ms, result ', i32_r);

  tw.start;
  for i := 1 to repeatCount do
    i32_r := i32_1 div i32_2;
  Writeln('32 bit /: ', tw.stop, ' ms, result ', i32_r);

  tw.start;
  for i := 1 to repeatCount do
    i32_r := i32_1 div 10;
  Writeln('32 bit / 10: ', tw.stop, ' ms, result ', i32_r);

  tw.start;
  for i := 1 to repeatCount do
    i32_r := i32_1 div 100;
  Writeln('32 bit / 100: ', tw.stop, ' ms, result ', i32_r);

  tw.start;
  for i := 1 to repeatCount do
    i64_r := i64_1 + i64_2;
  Writeln('64 bit +: ', tw.stop, ' ms, result ', i64_r);

  tw.start;
  for i := 1 to repeatCount do
    i64_r := i64_1 - i64_2;
  Writeln('64 bit -: ', tw.stop, ' ms, result ', i64_r);

  tw.start;
  for i := 1 to repeatCount do
    i64_r := i64_1 * i64_2;
  Writeln('64 bit *: ', tw.stop, ' ms, result ', i64_r);

  tw.start;
  for i := 1 to repeatCount do
    i64_r := i64_1 * 10;
  Writeln('64 bit * 10: ', tw.stop, ' ms, result ', i64_r);

  tw.start;
  for i := 1 to repeatCount do
    i64_r := i64_1 * 100;
  Writeln('64 bit * 100: ', tw.stop, ' ms, result ', i64_r);

  tw.start;
  for i := 1 to repeatCount do
    i64_r := i64_1 div i64_2;
  Writeln('64 bit /: ', tw.stop, ' ms, result ', i64_r);

  tw.start;
  for i := 1 to repeatCount do
    i64_r := i64_1 div 10;
  Writeln('64 bit / 10: ', tw.stop, ' ms, result ', i64_r);

  tw.start;
  for i := 1 to repeatCount do
    i64_r := i64_1 div 100;
  Writeln('64 bit / 100: ', tw.stop, ' ms, result ', i64_r);
end;

procedure IntegerTest;
var
  s: string;
  a, b, c: TAny;
  strs: TStringList;
begin
  /// test shows:
  ///  in 32bit platform, 64bit */ is slower
  ///  in 64bit platform, 64bit / is slower
  Writeln('------- integer benckmark -------');
  strs := TStringList.Create;
  c.setInt32(100000000);
  while True do
  begin
    Write('enter two integer (for back, enter <break>) : ');
    Readln(s);
    s := SysUtils.Trim(s);
    if SameText(s, 'break') then
      Break;
    if s = '' then
      Continue;
    strs.CommaText := s;
    if strs.Count < 2 then
      Continue;

    a := GetInputNumber(SysUtils.Trim(strs[0]));
    b := GetInputNumber(SysUtils.Trim(strs[1]));

    if strs.Count > 2 then
    begin
      c := GetInputNumber(SysUtils.Trim(strs[2]));
      if not c.IsInteger then
        c.setInt32(100000000);
    end;

    if not a.IsEmptyOrNull and not b.IsEmptyOrNull and not c.IsEmptyOrNull then
      IntegerTestWith(a, b, c.ToInt32);
  end;
end;

procedure TestInt64NegOperation(repeatCount: Integer);
const
  Sign64: array [Boolean] of Int64 = (1, -1);
var
  i: Integer;
  v, v2: Int64;
  tw: TStopWatch;
  IsNegative: Boolean;
begin
  v := Random(High(Int32)) * Random(High(Int32));
  IsNegative := Random(2) = 1;
  Writeln('IsNegative: ', IsNegative);
  v2 := v;
  tw.start;
  for i := 1 to repeatCount do
    v2 := v * Sign64[IsNegative];
  Writeln('64bit * -1 ', tw.stop, ' ms, result ', v2);

  tw.start;
  for i := 1 to repeatCount do
    if IsNegative then
      v2 := -v
    else
      v2 := v;
  Writeln('-64bit ', tw.stop, ' ms, result ', v2);
end;

end.
