program DocVariantTest;

//{$mode objfpc}{$H+}
{$I Synopse.inc}

uses
  {$I SynDprUses.inc}
  {$IFDEF UNIX} {$IFDEF UseCThreads}cthreads, {$ENDIF} {$ENDIF}
  Classes,
  SysUtils,
  TypInfo,
  CustApp,
  Variants,
  VarUtils,
  ComObj,
  SynCommons,
  uDocVariantTest,
  ParseNumberTest,
  main,
  fphttpclient,
  RegexPr { you can add units after this };

type

  { TMyApplication }

  TMyApplication = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
  end;

  function GetExternalIPAddress: string;
  var
    HTTPClient: TFPHTTPClient;
    IPRegex: TRegExpr;
    RawData: string;
  begin
    try
      HTTPClient := TFPHTTPClient.Create(nil);
      HttpClient.Proxy.Host:='127.0.0.1';
      HttpClient.Proxy.Port:= 8081;
      IPRegex := TRegExpr.Create;
      try
        //returns something like:
        {
  <html><head><title>Current IP Check</title></head><body>Current IP Address: 44.151.191.44</body></html>
        }
        RawData := HTTPClient.Get('http://checkip.dyndns.org');
        // adjust for expected output; we just capture the first IP address now:
        IPRegex.Expression := RegExprString('\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b');
        //or
        //\b(?:\d{1,3}\.){3}\d{1,3}\b
        if IPRegex.Exec(RawData) then
        begin
          Result := IPRegex.Match[0];
        end
        else
        begin
          Result := 'Got invalid results getting external IP address. Details:' +
            LineEnding + RawData;
        end;
      except
        on E: Exception do
        begin
          Result := 'Error retrieving external IP address: ' + E.Message;
        end;
      end;
    finally
      HTTPClient.Free;
      IPRegex.Free;
    end;
  end;

function FollowRedircts(const url: string): string;
var
  HttpClient: TFPHTTPClient;
begin
  HttpClient := TFPHTTPClient.Create(nil);
  try
    HttpClient.AllowRedirect := True;
    //HttpClient.RequestHeaders.Values['User-Agent'] := 'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:57.0) Gecko/20100101 Firefox/57.0';
    Result := HttpClient.Get(url);
    Writeln(HttpClient.RequestHeaders.Text);
    Writeln(HttpClient.ResponseHeaders.Text);
    Writeln('Content-Type: ', HttpClient.GetHeader(HttpClient.ResponseHeaders, 'Content-Type'));
    //Result := WinCPToUTF8(Result);
    //Writeln('StringCodePage: ', StringCodePage(Result), '  ', NativeInt(Result));
    //SetCodePage(RawByteString(Result), 936, False);
    //Writeln('StringCodePage: ', StringCodePage(Result), '  ', NativeInt(Result));
	finally
    HttpClient.Free;
	end;
end;

  { TMyApplication }

  procedure TMyApplication.DoRun;
  begin
    try
      Writeln(FollowRedircts('http://www.163.com/'));
      Writeln(GetExternalIPAddress);
      ConsoleMain;
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;
    Writeln('press <ENTER> to exit...');
    Readln;
    Terminate;
  end;

  constructor TMyApplication.Create(TheOwner: TComponent);
  begin
    inherited Create(TheOwner);
    StopOnException := True;
  end;

var
  Application: TMyApplication;
begin
  Application := TMyApplication.Create(nil);
  Application.Title := 'My Application';
  Application.Run;
  Application.Free;
end.
