unit uDocVariantTest;
{$I Synopse.inc}
interface

uses
  SysUtils,
  Windows,
  Classes,
  Variants,
  VarUtils,
  ComObj,
  SynCommons;

procedure test;

implementation

type
  TDispInvokeFunc = procedure(Dest: PVarData; const Source: TVarData; CallDesc: PCallDesc; Params: Pointer); cdecl;
  TCustomVariantTypeFake = class(TCustomVariantType)

  end;

var
  _DispInvoke_rtl: TDispInvokeFunc;

function VariantsDispInvokeAddress: TDispInvokeFunc;
asm
  {$ifdef CPU64}
  mov rax,offset Variants.@DispInvoke
  {$else}
  mov eax,offset Variants.@DispInvoke
  {$endif}
end;

procedure _MyDispInvoke(Dest: PVarData; const Source: TVarData;
  CallDesc: PCallDesc; Params: Pointer); cdecl;
var
  pSource: PVarData;
  LHandler: TCustomVariantType;
  LDest: TVarData;
  LDestPtr: PVarData;
begin
  pSource := @Source;
  while pSource.VType = varByRef or varVariant do
    pSource := PVarData(pSource.VPointer);

  // figure out destination temp
  if Dest = nil then
    LDestPtr := nil
  else
  begin
    VariantInit(LDest);
    LDestPtr := @LDest;
  end;

  // attempt it
  try

    // we only do this if it is one of those special types
    case pSource^.VType of
      varDispatch,
      varDispatch + varByRef,
      varUnknown,
      varUnknown + varByRef,
      varAny:
        if Assigned(VarDispProc) then
          VarDispProc(PVariant(LDestPtr), Variant(pSource^), CallDesc, @Params);
    else
      // finally check to see if it is one of those custom types
      if FindCustomVariantType(pSource^.VType, LHandler) then
        TCustomVariantTypeFake(LHandler).DispInvoke(LDestPtr, pSource^, CallDesc, @Params)
      else
        VarInvalidOp;
    end;
  finally

    // finish up with destination temp
    if LDestPtr <> nil then
    begin
      VarClear(Variant(Dest^));
      Dest^ := LDestPtr^;
      ZeroFill(LDestPtr);
    end;
  end;
end;

procedure patchRTL;
begin
  _DispInvoke_rtl := VariantsDispInvokeAddress();
  RedirectCode(@_DispInvoke_rtl, @_MyDispInvoke);
end;

function checkDocVariantData(const v: Variant; kind: TDocVariantKind; valueCount: Integer = -1): Boolean;
var
  pData: PVarData;
begin
  pData := FindVarData(v);

  Result := (pData.VType = DocVariantVType) and (TDocVariantData(pData^).Kind = kind)
    and ( (valueCount = -1) or (TDocVariantData(pData^).Count = valueCount) );
end;

procedure printTitle(const title: string);
begin
  Writeln;
  Writeln('****************************  ', title, '  ****************************');
end;

procedure printPointer(ptr: Pointer);
begin
  Writeln(Format('0x%p', [ptr]));
end;

procedure printVariant(const name: string; const v: Variant);
var
  pData: PVarData;
begin
  pData := FindVarData(v);
  printTitle('dump ' + name);
  if pData.VType = DocVariantVType then
    Writeln(TDocVariantData(pData^).ToJSON('', '', jsonHumanReadable))
  else if pData.VType and varArray = 0 then
  begin
    case pData.VType of
      varEmpty: Writeln('Unassigned');
      varNull: Writeln('Null');
      else
        Writeln(Variant(pData^));
    end;
  end
  else begin
    Writeln('<OLE Array>');
  end;
end;

procedure test1; forward;

procedure test;
begin
  test1;
end;

///
///Add subscript support to TDocVariant
///Add OLE array support for TTextWriter.AddVariant
///

procedure callDispMethodOfVariantReference(const v: Variant);
begin
end;

procedure printIntArray(const a: array of Integer);
var
  i: Integer;
begin
  for i := Low(a) to High(a) do
    Write(a[i], ' ');
  Writeln;
end;

procedure testDynArray;
var
  a1, a2: array of Integer;
begin
  SetLength(a1, 2);
  a1[0] := 1;
  a1[1] := 2;
  a2 := a1;
  printIntArray(a1);
  printIntArray(a2);
  a2[0] := 20;
  a1[1] := 11;
  printIntArray(a1);
  printIntArray(a2);
  SetLength(a2, 3);
  a2[2] := 987;
  printIntArray(a1);
  printIntArray(a2);
end;

procedure test1;
var
  doc: Variant;
  json: RawUTF8;
begin
  json := '{"students":['
    + '{"age":21,"ismale":false,"name":"Susan","address":{"state":"Washington","city":"Seattle"}}'
    + ',{"age":22, "name":"Alex","ismale":true,"address":{"state":"California","city":"San Luis Obispo"}}'
    + ']}';
  printTitle('parse json text');
  Writeln('doc := _JsonFast(' , json, ')');
  doc := _JsonFast(json);

  printVariant('doc', doc);

  Assert(checkDocVariantData(doc.students, dvArray, 2));
  printVariant('doc.students', doc.students);

  Assert(doc.students[0].name = 'Susan');
  Assert(doc.students[1].ismale = True);

  doc.Add('ShcoolName', 'Harvard University');
  Assert(doc.ShcoolName = 'Harvard University');
  printVariant('doc.ShcoolName', doc.ShcoolName);

  doc.Add('teachers', _JsonFast('[{"age":55,"ismale":false,"name":"Bill Gates"}]'));
  Assert(checkDocVariantData(doc.teachers, dvArray, 1));
  Assert(doc.teachers[0].age=55);
  printVariant('doc.teachers', doc.teachers);

  doc.students.add(_JsonFast('{"age":21,"ismale":false,"name":"James","address":{"state":"Utah","city":"Salt Lake"}}'));
  Assert(doc.students._count=3);
  Assert(doc.students[2].address.state = 'Utah');
  Assert(doc.students[2].address['state'] = 'Utah');
  printVariant('doc.students[2]', doc.students[2]);
  doc.students[2].address.city := doc.students[2].address['city'] + ' City';
  printVariant('doc.students[2]', doc.students[2]);
end;

initialization
  patchRTL;

end.
