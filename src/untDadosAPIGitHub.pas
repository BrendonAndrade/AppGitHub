unit untDadosAPIGitHub;

interface

uses Rest.Client, System.JSON, System.SysUtils, FMX.Dialogs, System.Classes, System.IOUtils,
     IPPeerCommon, IPPeerClient;

type
  TDadosAPIGitHub = class
  private
    FRestCliente: TRestClient;
    FRestRequest: TRestRequest;
    FCustomRestResponse: TCustomRESTResponse;
    procedure SalvarArquivoLocal;
    function  ExecutarRequisicao: boolean;
    function  TestarSeExisteArquivoLocal: boolean;
    function  ObterJSONArquivoLocal: string;
    function  ObterNomeArquivoJSONLocal: string;
  public
    function ObterJSONRepositorios: TJSONObject;
  end;

implementation

{ TDadosAPIGitHub }

function TDadosAPIGitHub.ObterJSONRepositorios: TJSONObject;
begin
  Result := nil;
  if ExecutarRequisicao then
  begin
    SalvarArquivoLocal;
    Result := TJSONObject(TJSONObject.ParseJSONValue(FCustomRestResponse.Content));
  end
  else
  if TestarSeExisteArquivoLocal then
  begin
    Result := TJSONObject(TJSONObject.ParseJSONValue(ObterJSONArquivoLocal));
  end;
end;

function TDadosAPIGitHub.ObterJSONArquivoLocal: string;
var
  lArquivo: TStringList;
begin
  lArquivo := TStringList.Create;
  try
    lArquivo.LoadFromFile(ObterNomeArquivoJSONLocal);
    Result := lArquivo.Text;
  finally
    lArquivo.Free;
  end;
end;

function TDadosAPIGitHub.ObterNomeArquivoJSONLocal: string;
begin
  Result := TPath.GetDocumentsPath + PathDelim + 'JSONRetornoGitHub.txt';
end;

procedure TDadosAPIGitHub.SalvarArquivoLocal;
var
  lArquivo: TStringList;
begin
  lArquivo := TStringList.Create;
  try
    lArquivo.Add(FCustomRestResponse.Content);
    lArquivo.SaveToFile(ObterNomeArquivoJSONLocal);
  finally
    lArquivo.Free;
  end;
end;

function TDadosAPIGitHub.ExecutarRequisicao: boolean;
begin
  Result := True;
  try
    FRestCliente := TRESTClient.Create('https://api.github.com/orgs/BearchInc/repos');
    FRestRequest := TRESTRequest.Create(nil);
    FRestRequest.Client := FRestCliente;
    FRestRequest.Execute;
    FCustomRestResponse := FRestRequest.Response;
  except
    Result := False;
  end;
end;

function TDadosAPIGitHub.TestarSeExisteArquivoLocal: boolean;
begin
  result := FileExists(TPath.GetDocumentsPath + PathDelim + 'JSONRetornoGitHub.txt');
end;

end.
