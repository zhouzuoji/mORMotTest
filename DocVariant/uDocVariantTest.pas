unit uDocVariantTest;
{$I Synopse.inc}
{$I HPPas.inc}
interface
uses
  SysUtils,
  Math,
{$ifdef MSWINDOWS}
  Windows,
  VarUtils,
  ComObj,
{$endif}
  Classes,
  Variants,
  SynCommons,
  HPPas,
  HppStrs,
  HppTypeCast,
  HppSysUtils,
  HppJSONParser,
  HppVariants;

procedure PrintSizeOf;
procedure TestFormat;
procedure PutCustomVariantToVariantArray;
procedure test1;
procedure test2;
procedure test3;
procedure test4;
procedure HppVariantsTest;
procedure TestRttiSerialize;
procedure TestSmartString;
procedure SynDynArray_Test;

implementation

procedure PrintSizeOf;
var
  s1: ShortString;
  s2: string[20];
begin
  Writeln('SizeOf(TVariantDataType): ', SizeOf(TVariantDataType));
  Writeln('SizeOf(TVarData): ', SizeOf(TVarData));
  Writeln('SizeOf(TVariantProperty): ', SizeOf(TVariantProperty));
  Writeln('SizeOf(TVariant8): ', SizeOf(TVariant8));
  Writeln('SizeOf(TVariant16): ', SizeOf(TVariant16));
  Writeln('SizeOf(TVariant32): ', SizeOf(TVariant32));
  Writeln('SizeOf(TVariant64): ', SizeOf(TVariant64));
  Writeln('SizeOf(TCompactVariant): ', SizeOf(TCompactVariant));
  Writeln('SizeOf(Currency): ', SizeOf(Currency));
  Writeln('SizeOf(WordBool): ', SizeOf(WordBool));
  Writeln('SizeOf(ShortInt): ', SizeOf(ShortInt));
  Writeln('SizeOf(SmallInt): ', SizeOf(SmallInt));
  Writeln('SizeOf(ShortString): ', SizeOf(s1));
  Writeln('SizeOf(string[20]): ', SizeOf(s2));
  Writeln('SizeOf(ElementOfShortString): ', SizeOf(s1[1]));
  s1 := 's1s1s1';
  s2 := 's2s2';
  Writeln('s1: ', s1);
  Writeln('s2: ', s2);
end;

procedure TestFormat;
begin

end;

function checkDocVariantData(const v: Variant; kind: TDocVariantKind; valueCount: Integer = -1): Boolean;
var
  pData: PVarData;
  c: THppVariantContainer;
begin
  pData := FindVarData(v);

  if pData.VType = DocVariantVType then
    Result := (TDocVariantData(pData^).Kind = kind) and ((valueCount = -1) or (TDocVariantData(pData^).Count = valueCount))
  else if pData.VType = JsonVarTypeID then
  begin
    c := THppVariantContainer(pData.VPointer);
    Result := ((c.IsArray and (kind = dvArray)) or ((not c.IsArray and (kind = dvObject))))
      and ((valueCount = -1) or (c.Count = valueCount)) ;
  end
  else Result := False;
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
  if name <> '' then printTitle('dump ' + name);
  if pData.VType = DocVariantVType then
    Writeln(TDocVariantData(pData^).ToJSON('', '', jsonHumanReadable))
  else if pData.VType and varArray = 0 then
  begin
    case pData.VType of
      varEmpty:
        Writeln('Unassigned');
      varNull:
        Writeln('Null');
    else
      Writeln(Variant(pData^));
    end;
  end
  else
  begin
    Writeln('<OLE Array>');
  end;
end;

procedure SynDynArray_Test;
type
  TPerson = record
    name: string;
    age: Byte;
	end;
  TPersonDynArray = array of TPerson;

  TIntDynArray = array of Integer;
var
  arrd: TIntDynArray;
  RecArrD: array of TPerson;
  arr: TDynArray;
  i, value, cnt: Integer;
  person: TPerson;
begin
  arr.Init(TypeInfo(TIntDynArray), arrd, @cnt);
  for i := 0 to 100 do
  begin
    value := i * i;
    arr.Add(value);
	end;
	Writeln('arr.length: ', arr.Count);
  for i := 0 to arr.Count - 1 do
    Writeln('arrd[', i, ']: ', arrd[i]);

  arr.init(TypeInfo(TPersonDynArray), RecArrD, @cnt);
  person.name:='Susan';
  person.age:=13;
  arr.Add(person);
  person.name := 'Bob';
  person.age := 12;
  arr.Add(person);
  person.name := 'Alex';
  person.age := 14;
  arr.Add(person);
	Writeln('arr.length: ', arr.Count);
  for i := 0 to arr.Count - 1 do
    Writeln('arrd[', i, ']: ', RecArrD[i].name, ' ', RecArrD[i].age);
  arr.Delete(1);
	Writeln('arr.length: ', arr.Count);
  for i := 0 to arr.Count - 1 do
    Writeln('arrd[', i, ']: ', RecArrD[i].name, ' ', RecArrD[i].age);
end;

const
  SAMPLE_JSON = '{"\"p1":"\ndfd", pp2: 1.3e50, "EmptyArray":[], "EmptyObject":{}, "students":[' +
    '{"age":21,"ismale":false,"name":"Susan","address":{"state":"Washington","city":"Seattle"}}' +
    ',{"age":22, "name":"Alex","ismale":true,"address":{"state":"California","city":"San Luis Obispo"}}' + ']}';

procedure PutCustomVariantToVariantArray;
var
  vararr, doc: Variant;
begin
  vararr := VarArrayCreate([0, 2], varVariant);
  doc := _JsonFast(SAMPLE_JSON);
  vararr[0] := doc;
  printVariant('vararr', vararr);
end;

procedure test1;
var
  doc, students, student: Variant;
begin
  printTitle('parse json text');
  Writeln('doc := _JsonFast(', SAMPLE_JSON, ')');
  doc := _JsonFast(SAMPLE_JSON);

  printVariant('doc', doc);
  Assert(checkDocVariantData(doc.students, dvArray, 2));
  printVariant('doc.students', doc.students);

  Assert(doc.students[0].name = 'Susan');
  Assert(doc.students[1].ismale = True);

  students := doc.students;
  printVariant('students[0]', students[0]);
  printVariant('students[1]', students[1]);

  TDocVariantData(student).Init([], dvObject);
  student.age := 18;
  student.ismale := True;
  student.name := 'Kobe';
  student.address := _JsonFast('{"state":"Massa Chusetts","city":"Boston"}');

  printVariant('student', student);

  students[1] := student;
  printVariant('students', students);
  printVariant('doc.students', doc.students);

  doc.Add('ShcoolName', 'Harvard University');
  Assert(doc.ShcoolName = 'Harvard University');
  printVariant('doc.ShcoolName', doc.ShcoolName);

  doc.Add('teachers', _JsonFast('[{"age":55,"ismale":false,"name":"Bill Gates"}]'));
  Assert(checkDocVariantData(doc.teachers, dvArray, 1));
  Assert(doc.teachers[0].age = 55);
  printVariant('doc.teachers', doc.teachers);

  doc.students.add(_JsonFast('{"age":21,"ismale":false,"name":"James","address":{"state":"Utah","city":"Salt Lake"}}'));
  Assert(doc.students._count = 3);
  printVariant('doc.students[2]', doc.students[2]);
  Assert(doc.students[2].address.state = 'Utah');
  Assert(doc.students[2].address['state'] = 'Utah');
  printVariant('doc.students[2]', doc.students[2]);
  doc.students[2].address.city := doc.students[2].address['city'] + ' City';
  printVariant('doc.students[2]', doc.students[2]);
end;

procedure test2;
var
  doc, students: Variant;
begin
  printTitle('parse json text');
  Writeln('doc := _JsonFast(', SAMPLE_JSON, ')');
  doc := _JsonFast(SAMPLE_JSON);
  printVariant('doc', doc);

  Assert(checkDocVariantData(doc.students, dvArray, 2));
  printVariant('doc.students', doc.students);

  Assert(doc.students._(0).name = 'Susan');
  Assert(doc.students._(1).ismale = True);

  students := doc.students;

  students.add('untitled');
  Writeln(students._count);
  Writeln(doc.students._count);
  printVariant('students._(students._count - 1)', students._(students._count - 1));
  printVariant('doc.students._(doc.students._count - 1)', doc.students._(doc.students._count - 1));

  doc.Add('ShcoolName', 'Harvard University');
  Assert(doc.ShcoolName = 'Harvard University');
  printVariant('doc.ShcoolName', doc.ShcoolName);

  doc.students.add('untitled');
  Writeln(students._count);
  Writeln(doc.students._count);
  printVariant('doc.students._(doc.students._count - 1)', doc.students._(doc.students._count - 1));

  students.add('untitled');
  Writeln(students._count);
  Writeln(doc.students._count);
  printVariant('students._(students._count - 1)', students._(students._count - 1));
end;

procedure test3;
var
  doc, students, student: Variant;
begin
  Writeln(ParseJSON('1'));
  Writeln(ParseJSON('134e21'));
  Writeln(ParseJSON('.134e-21'));
  Writeln(ParseJSON('.134e-50'));
  printVariant('', ParseJSON('null'));
  Writeln(ParseJSON('false'));
  Writeln(ParseJSON('true'));
  Writeln(ParseJSON('"just a string"'));
  printTitle('parse json text');
  Writeln('doc := ParseJSON(', SAMPLE_JSON, ')');
  doc := ParseJSON(SAMPLE_JSON);

  printVariant('doc', doc);
  Assert(checkDocVariantData(doc.students, dvArray, 2));
  printVariant('doc.students', doc.students);

  Assert(doc.students[0].name = 'Susan');
  Assert(doc.students[1].ismale = True);

  students := doc.students;
  printVariant('students[0]', students[0]);
  printVariant('students[1]', students[1]);

  student := TVariantHandler.NewObject;
  student.age := 18;
  student.ismale := True;
  student.name := 'Kobe';
  student.address := ParseJSON('{"state":"Massa Chusetts","city":"Boston"}');

  printVariant('student', student);

  students[1] := student;
  printVariant('students', students);
  printVariant('doc.students', doc.students);

  doc.Add('ShcoolName', 'Harvard University');
  Assert(doc.ShcoolName = 'Harvard University');
  Writeln(THppVariantObject(TVarData(doc).vpointer).GetString('ShcoolName').ToUTF16String);
  printVariant('doc.ShcoolName', doc.ShcoolName);

  doc.Add('teachers', ParseJSON('[{"age":55,"ismale":false,"name":"Bill Gates"}]'));
  Assert(checkDocVariantData(doc.teachers, dvArray, 1));
  Assert(doc.teachers[0].age = 55);
  printVariant('doc.teachers', doc.teachers);

  doc.students.add(ParseJSON('{"age":21,"ismale":false,"name":"James","address":{"state":"Utah","city":"Salt Lake"}}'));
  Assert(doc.students._count = 3);
  printVariant('doc.students[2]', doc.students[2]);
  Assert(doc.students[2].address.state = 'Utah');
  Assert(doc.students[2].address['state'] = 'Utah');
  printVariant('doc.students[2]', doc.students[2]);
  doc.students[2].address.city := doc.students[2].address['city'] + ' City';
  printVariant('doc.students[2]', doc.students[2]);
end;

procedure test4;
var
  doc, students: Variant;
begin
  printTitle('parse json text');
  Writeln('doc := ParseJSON(', SAMPLE_JSON, ')');
  doc := ParseJSON(SAMPLE_JSON);
  printVariant('doc', doc);

  Assert(checkDocVariantData(doc.students, dvArray, 2));
  printVariant('doc.students', doc.students);

  Assert(doc.students._(0).name = 'Susan');
  Assert(doc.students._(1).ismale = True);

  students := doc.students;

  students.add('untitled');
  Writeln(students._count);
  Writeln(doc.students._count);
  printVariant('students._(students._count - 1)', students._(students._count - 1));
  printVariant('doc.students._(doc.students._count - 1)', doc.students._(doc.students._count - 1));

  doc.Add('ShcoolName', 'Harvard University');
  Assert(doc.ShcoolName = 'Harvard University');
  printVariant('doc.ShcoolName', doc.ShcoolName);

  doc.students.add('untitled');
  Writeln(students._count);
  Writeln(doc.students._count);
  printVariant('doc.students._(doc.students._count - 1)', doc.students._(doc.students._count - 1));

  students.add('untitled');
  Writeln(students._count);
  Writeln(doc.students._count);
  printVariant('students._(students._count - 1)', students._(students._count - 1));
end;

procedure TestSmartString;
var
  u8s: UTF8String;
  ss: TStringView;
{$ifdef MSWINDOWS}  
  oldcp: Integer;
  numbytes: Cardinal;
{$endif}
begin
{$ifdef MSWINDOWS}
  oldcp := GetConsoleOutputCP;
  //SetConsoleOutputCP(CP_UTF8);
  try
{$endif}
    u8s := UTF8Encode('[priˈæmbl] 美 [ˈpriˌæmbəl, priˈæm-]n.前言;序;绪言;（法令、文件等的）序文');
    ss.ResetAnsiString(u8s, CP_UTF8);
    Writeln(ss.ToRawByteString);
    Writeln(ss.ToUTF16String);
{$ifdef MSWINDOWS}
    WriteConsoleW(GetStdHandle(STD_OUTPUT_HANDLE), Pointer(ss.ToNullTerminatedUTF16), ss.GetUTF16Length, numbytes, nil);
    Writeln;
{$endif}
{$ifdef MSWINDOWS}
  finally
    SetConsoleOutputCP(oldcp);
  end;
{$endif}
end;

type
  TPerson = class(TPersistent)
  private
    FName: string;
    FAge: Integer;
    procedure SetName(const Value: string);
    procedure SetAge(const Value: Integer);
  published
    property Name: string read FName write SetName;
    property Age: Integer read FAge write SetAge;
  end;

procedure TestRttiSerialize;
var
  person: TPerson;
  obj: THppVariantObject;
  obj2: THppVariantObject;
begin
  obj := ParseJSONObject(UTF8Encode('{age:33,name:"李寻欢"}'));
  person := TPerson.Create;
  obj2 := THppVariantObject.Create(nil);
  try
    obj.ToSimpleObject(person);
    Writeln(person.Name, ' ', person.Age);
    obj2.FromSimpleObject(person);
    Writeln(obj2.ToString);
  finally
    obj.Free;
    obj2.Free;
    person.Free;
  end;
end;

procedure PrintJsonObjProp(obj: THppVariantObject; PropName: UTF8String);
var
  v: Variant;
  vr: TVarData absolute v;
  vt: TVarType;
begin
  try
    v := obj[PropName];

    if vr.VType and varArray <> 0 then
      Writeln('obj.', PropName, ' is SafeArray');
    if vr.VType and varByRef <> 0 then
      Writeln('obj.', PropName, ' is VariantByRef');
    vt := vr.VType and varTypeMask;
    case vt of
      varEmpty: Writeln('obj.', PropName, ' is empty');
      varNull: Writeln('obj.', PropName, ' is null');
      varBoolean: Writeln('obj.', PropName, ' is Boolean: ', v);
      varShortInt: Writeln('obj.', PropName, ' is Int8: ', v);
      varByte: Writeln('obj.', PropName, ' is UInt8: ', v);
      varSmallint: Writeln('obj.', PropName, ' is Int16: ', v);
      varWord: Writeln('obj.', PropName, ' is UInt16: ', v);
      varInteger: Writeln('obj.', PropName, ' is Int32: ', v);
      varLongWord: Writeln('obj.', PropName, ' is UInt32: ', v);
      varInt64: Writeln('obj.', PropName, ' is Int64: ', v);
      varUInt64: Writeln('obj.', PropName, ' is UInt64: ', v);
      varString: Writeln('obj.', PropName, ' is AnsiString: ', v);
      varOleStr: Writeln('obj.', PropName, ' is WideString: ', v);
      {$ifdef HASVARUSTRING}
      varUString: Writeln('obj.', PropName, ' is UnicodeString: ', v);
      {$endif}
      varUnknown: Writeln('obj.', PropName, ' is Interface: ', PtrInt(vr.VUnknown));
      varDispatch: Writeln('obj.', PropName, ' is IDispatch: ', PtrInt(vr.VDispatch));
      varDouble: Writeln('obj.', PropName, ' is Double: ', v);
      varDate: Writeln('obj.', PropName, ' is Date: ', v);
      varCurrency: Writeln('obj.', PropName, ' is Currency: ', v);
      varSingle: Writeln('obj.', PropName, ' is Single: ', v);
    end;
  except
    on e: Exception do
      Writeln(e.ClassName, ': ', e.Message);
  end;
end;

function generatePropName: UTF8String;
const
  CHAR_TABLE: UTF8String = '_-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
var
  len, i: Integer;
begin
  len := 5 + Random(64);
  SetLength(Result, len);
  for i := 0 to len - 1 do
    PAnsiChar(Result)[i] := CHAR_TABLE[1 + Random(Length(CHAR_TABLE))];
end;

procedure HppVariantsTest_AddEmpty(obj: THppVariantObject);
var
  name: UTF8String;
begin
  printTitle('test empty property');
  name := generatePropName;
  Writeln('name: ', name);
  obj.Add(name);
  Writeln('obj.', name, '(', VarTypeAsText(VarType(obj[name])), ')');
  Assert(VarIsEmpty(obj[name]));
  PrintJsonObjProp(obj, name);
end;

procedure HppVariantsTest_AddNull(obj: THppVariantObject);
var
  name: UTF8String;
  value: TJSONSpecialValue;
  //TJsonSpecialType = (jstUndefined, jstNull, jstNotANumber, jstPositiveInfinity, jstNegativeInfinity);
begin
  printTitle('test null property');
  name := generatePropName;
  Writeln('name: ', name);
  value := TJSONSpecialValue(Random(Ord(High(TJSONSpecialValue)) + 1));
  Writeln('value: ', JsonSpecialTypeNames[value]);
  obj.Add(name, value);
  Writeln('obj.', name, '(', VarTypeAsText(VarType(obj[name])), ')');
  Assert(VarIsNull(obj[name]));
  PrintJsonObjProp(obj, name);
end;

procedure HppVariantsTest_AddBoolean(obj: THppVariantObject);
var
  name: UTF8String;
  value: Boolean;
begin
  printTitle('test boolean property');
  name := generatePropName;
  Writeln('name: ', name);
  value := Random(2) = 1;
  Writeln('value: ', value);
  obj.Add(name, value);
  Writeln('obj.', name, '(', VarTypeAsText(VarType(obj[name])), '): ', obj[name]);
  Assert((VarType(obj[name]) = varBoolean) and (obj[name] = value));
  PrintJsonObjProp(obj, name);
end;

procedure HppVariantsTest_AddInt8(obj: THppVariantObject);
var
  name: UTF8String;
  value: Int8;
begin
  printTitle('test int8 property');
  name := generatePropName;
  Writeln('name: ', name);
  value := Random(High(Int8) * 2 + 2) - (High(Int8) + 1);
  Writeln('value: ', value);
  obj.Add(name, value);
  Writeln('obj.', name, '(', VarTypeAsText(VarType(obj[name])), '): ', obj[name]);
  Assert((VarType(obj[name]) = varShortInt) and (obj[name] = value));
  PrintJsonObjProp(obj, name);
end;

procedure HppVariantsTest_AddUInt8(obj: THppVariantObject);
var
  name: UTF8String;
  value: UInt8;
begin
  printTitle('test uint8 property');
  name := generatePropName;
  Writeln('name: ', name);
  value := Random(High(UInt8) + 1);
  Writeln('value: ', value);
  obj.Add(name, value);
  Writeln('obj.', name, '(', VarTypeAsText(VarType(obj[name])), '): ', obj[name]);
  Assert((VarType(obj[name]) = varByte) and (obj[name] = value));
  PrintJsonObjProp(obj, name);
end;

const
  THppVariantObject_AddPropProcs: array [vdtEmpty..vdtUInt8] of procedure(obj: THppVariantObject) =
  (HppVariantsTest_AddEmpty, HppVariantsTest_AddNull, HppVariantsTest_AddBoolean,
  HppVariantsTest_AddInt8, HppVariantsTest_AddUInt8);

procedure HppVariantsTest;
const
  SLongPropName: RawByteString = 'LongPropName';
var
  obj2, obj, subobj: THppVariantObject;
  arr: THppVariantArray;
  i: Integer;
  v, v2, EmptyArray, EmptyObject, v3: Variant;
begin
  v2 := ParseJSON(SAMPLE_JSON);
  //Clipboard.AsText := v2;
  EmptyArray := v2.EmptyArray;
  Writeln(EmptyArray);
  Writeln(EmptyArray._count);
  Writeln(EmptyArray._json);
  EmptyArray.Add('create and add');
  printVariant('EmptyArray', EmptyArray);
  printVariant('v2.EmptyArray', v2.EmptyArray);
  v3 := EmptyArray;
  printVariant('v3', v3);

  EmptyObject := v2.EmptyObject;
  Writeln(EmptyObject);
  Writeln(EmptyObject._count);
  Writeln(EmptyObject._json);
  EmptyObject.Add('first', '007');
  printVariant('EmptyObject', EmptyObject);
  printVariant('v2.EmptyObject', v2.EmptyObject);
  v3 := EmptyObject;
  printVariant('v3', v3);

  obj2 := ParseJSONObject(SAMPLE_JSON);
  //obj2.Clone.Free;
  obj2.Free;
  obj := THppVariantObject.Create(nil);
  encapsulate(obj, TVarData(v));
  obj.Capacity := 2000000;
  for i := 1 to 1000 do
    THppVariantObject_AddPropProcs[TVariantDataType(Random(Ord(vdtInt16)))](obj);
  obj['NumberStr'] := '-52352352452355';
  Writeln(obj['NumberStr']);
  Writeln(obj.GetNumber('NumberStr').ToString);
  obj.Add(PAnsiChar(SLongPropName), Length(SLongPropName), Int8(11));
  Writeln(obj[SLongPropName]);
  obj.SetInt64(SLongPropName, High(Int64));
  Writeln(obj[SLongPropName]);
  Assert(obj[SLongPropName]=High(Int64));
  arr := obj.AddArray('persons');
  subobj := arr.AddObject;
  subobj.Add('name', 'zzj');
  subobj.Add('age', Int8(33));
  subobj := arr.AddObject;
  subobj.Add('name', 'hyf');
  subobj.Add('age', Int8(32));
  Writeln(v.persons._count);
  Writeln(v.persons);
  Writeln(v.persons[1]);
  Writeln(obj.A['persons'].Count);
  Writeln(obj.A['persons'].O[1].GetString('name').ToUTF16String);
  obj.Remove('persons');
  Writeln(obj.A['persons'].Count);
  //Writeln(obj.A['persons'].O[1].S['name']);
  for i := 1 to obj.Count div 2 do
    obj.Delete(Random(obj.Count));
  //Clipboard.AsText := obj.ToString;
  Writeln(v._JSON);
end;

{ TPerson }

procedure TPerson.SetAge(const Value: Integer);
begin
  FAge := Value;
end;

procedure TPerson.SetName(const Value: string);
begin
  FName := Value;
end;

end.
