unit uDocVariantTest;
{$I Synopse.inc}
interface

uses
  SysUtils,
  Classes,
  Variants,
  VarUtils,
  SynCommons;

procedure test;

implementation

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

end.
