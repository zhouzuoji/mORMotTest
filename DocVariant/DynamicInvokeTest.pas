unit DynamicInvokeTest;
{$I Synopse.inc}
{$I HPPas.inc}
interface
uses
  SysUtils, Classes, Math, TypInfo,
{$ifdef MSWINDOWS}
  Windows,
{$endif}
  SynCommons, HPPas, HppMagic, HppTypeCast, HppSysUtils, HppScript, ParseNumberTest, JSONTest;

procedure TestInvokeWithArrayOfConst;
procedure TestInvokeWithArrayOfRttiValue;

implementation

function add(a, b: Integer): Integer;
begin
  Result := a + b;
end;

procedure substract(a, b: Integer; var c: Integer);
begin
  c := a - b;
end;

function add64(a, b: Int64): Int64;
begin
  Result := a + b;
end;

procedure substract64(a, b: Int64; var c: Int64);
begin
  c := a - b;
end;

function add_flt10(a, b: Extended): Extended;
begin
  Result := a + b;
end;

procedure substract_flt10(a, b: Extended; var c: Extended);
begin
  c := a - b;
end;

procedure substract_flt10_cdecl(a, b: Extended; var c: Extended); cdecl;
begin
  c := a - b;
end;

procedure TestInvokeWithArrayOfRttiValue;
{$ifdef ISDELPHI2010}
var
  c: Integer;
  c64: Int64;
{$endif}
begin
  {$ifdef ISDELPHI2010}
  c := HppMagic.Invoke2(@add, [1, 2], ccReg, TypeInfo(Integer), True, False).AsInteger;
  Writeln(c);
  c64 := HppMagic.Invoke2(@add64, [Int64(156), Int64(186)], ccReg, TypeInfo(Int64), True, False).AsInt64;
  Writeln(c64);
  HppMagic.Invoke2(@substract, [1, 2, PtrInt(@c)], ccReg, TypeInfo(Integer), True, False);
  Writeln(c);
  Writeln(HppMagic.Invoke2(@IntToStr, [4396], ccReg, TypeInfo(string), True, False).AsString);
  {$endif}
end;

function asm_add64_2(a, b: Int64): Int64; overload;
{$ifdef CPU64}
asm
  MOV RAX, a
  ADD RAX, b
end;
{$else}
begin
  Result := a+b;
end;
{$endif}

procedure str_concat_double2(dbl, dbl2: Integer);
begin
  Writeln(FloatToStr(dbl + dbl2));
end;

procedure str_concat_double(dbl: Integer);
begin
  Writeln(FloatToStr(dbl));
end;

function asm_add64_10(n1,n2,n3: Int64; const prefix: string;
 n4,n5: Int64; n6: Integer; n7: Integer; n8: Extended; n9,n10: Int64): string;
begin
  Result := prefix + ': ' + FloatToStr(asm_add64_2(n1, n2) + asm_add64_2(n3, n4) + n5
    + n8 + asm_add64_2(n6, n7) + asm_add64_2(n9, n10));
end;

function asm_addi64andflt_10(n1,n2,n3: Int64;
 n4,n5: Int64; n6: Integer; n7: Extended; n8,n9,n10: Int64): string;
begin
  Result := FloatToStr(asm_add64_2(n1, n2) + asm_add64_2(n3, n4) + asm_add64_2(n5, n8)
    + n6 + n7 + asm_add64_2(n9, n10));
end;

function asm_addi64andflt_10_flt(n1,n2,n3: Int64; const s: string;
 n4,n5: Int64; n6: Integer; n7: Extended; n8,n9,n10: Int64): Double;
begin
  Result := asm_add64_2(n1, n2) + asm_add64_2(n3, n4) + asm_add64_2(n5, n8)
    + n6 + n7 + asm_add64_2(n9, n10) + StrToFloat(s);
end;

procedure TestInvokeWithArrayOfConst;
var
  r: Integer;
  r64: Int64;
  s: string;
  rf: Extended;
  dbl: Double;
begin
  Writeln('Extended :', SizeOf(Extended));
  Writeln(IntToStr(Random(High(Int32))));
  substract_flt10_cdecl(98.3, 43.1, rf);
  Writeln(rf);
  Writeln(SizeOf(TVarRec));
  Writeln(Add64(432, 912));
  //HppMagic.Invoke2(@str_concat_double2, [Integer(2018), Integer(1998)], ccReg, nil, True, False);
  //HppMagic.Invoke2(@str_concat_double, [Integer(2018)], ccReg, nil, True, False);
  HppMagic.Invoke1(@str_concat_double, [Integer(2018)], nil, ccReg, nil, True, False);
  Writeln(s);
  HppMagic.Invoke1(@add, [1, 2], @r, ccReg, TypeInfo(Integer), True, False);
  Writeln(r);
  HppMagic.Invoke1(@IntToStr, [4396], @s, ccReg, TypeInfo(string), True, False);
  Writeln(s);
  WriteLn(asm_add64_10(1,2,3,'some prefix: ',4,5,6,7,8,9,10));
  Writeln(FloatToStr(1.23));
  HppMagic.Invoke1(@asm_addi64andflt_10_flt, [Int64(1), Int64(2), Int64(3), '100.0001',
  Int64(4), Int64(5), 6, 7.7, Int64(8), Int64(9), Int64(10)], @dbl, ccReg, TypeInfo(Double), True, False);
  Writeln(dbl);
  HppMagic.Invoke1(@asm_addi64andflt_10, [Int64(1), Int64(2), Int64(3),
  Int64(4), Int64(5), 6, 7.7, Int64(8), Int64(9), Int64(10)], @s, ccReg, TypeInfo(string), True, False);
  Writeln(s);
  HppMagic.Invoke1(@asm_add64_10, [Int64(1), Int64(2), Int64(3), string('asm_add64_10 prefix'),
  Int64(4), Int64(5), 6, Integer(7), 8.18, Int64(9), Int64(10)], @s, ccReg, TypeInfo(string), True, False);
  Writeln(s);
  HppMagic.Invoke1(@add, [11, 23], @r, ccReg, TypeInfo(Integer), True, False);
  Writeln(r);
  HppMagic.Invoke1(@substract, [1, 2, PtrInt(@r)], nil, ccReg, nil, True, False);
  Writeln(r);
  HppMagic.Invoke1(@substract, [986, 43, PtrInt(@r)], nil, ccReg, nil, True, False);
  Writeln(r);
  HppMagic.Invoke1(@add64, [Int64(High(UInt32)), Int64(High(UInt32))], @r64, ccReg, TypeInfo(Int64), True, False);
  Writeln(r64);
  HppMagic.Invoke1(@add_flt10, [1.3, 2.4], @rf, ccReg, TypeInfo(Extended), True, False);
  Writeln(rf);
  HppMagic.Invoke1(@add_flt10, [11.9, 23.01], @rf, ccReg, TypeInfo(Extended), True, False);
  Writeln(rf);
  HppMagic.Invoke1(@substract_flt10, [1.3, 2.4, PtrInt(@rf)], nil, ccReg, nil, True, False);
  Writeln(rf);
  HppMagic.Invoke1(@substract_flt10, [11.9, 23.01, PtrInt(@rf)], nil, ccReg, nil, True, False);
  Writeln(rf);
  HppMagic.Invoke1(@substract_flt10_cdecl, [11.9, 23.01, PtrInt(@rf)], nil, ccCdecl, nil, True, False);
  Writeln(rf);
end;

end.
