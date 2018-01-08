unit uWindowsOnly;

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

initialization
  _DispInvoke_rtl := VariantsDispInvokeAddress();
  RedirectCode(@_DispInvoke_rtl, @_MyDispInvoke);

end.
