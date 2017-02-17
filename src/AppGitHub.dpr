program AppGitHub;

uses
  System.StartUpCopy,
  FMX.Forms,
  untFrmPrincipal in 'untFrmPrincipal.pas' {frmPrincipal},
  untDadosAPIGitHub in 'untDadosAPIGitHub.pas',
  untProjetoClass in 'untProjetoClass.pas',
  untFrmProjetos in 'untFrmProjetos.pas' {frmProjetos};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
