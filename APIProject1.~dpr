library APIProject1;

uses
  ActiveX,
  ComObj,
  WebBroker,
  ISAPIApp,
  ISAPIThreadPool,
  uclMainAPIunit in 'uclMainAPIunit.pas' {WebModule1: TWebModule},
  uclUtils in 'uclUtils.pas',
  uclAllBooks in 'uclAllBooks.pas',
  uclUsers in 'uclUsers.pas',
  uclBookTransactions in 'uclBookTransactions.pas';

{$R *.RES}

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

begin
  CoInitFlags := COINIT_MULTITHREADED;
  Application.Initialize;
  Application.CreateForm(TWebModule1, WebModule1);
  Application.Run;
end.
