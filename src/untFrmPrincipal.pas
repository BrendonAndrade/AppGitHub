unit untFrmPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Layouts, System.Rtti, FMX.Grid.Style, FMX.Grid, FMX.Controls.Presentation,
  FMX.ScrollBox, System.JSON, System.Generics.Collections, untDadosAPIGitHub,
  untProjetoClass, Data.DB, Datasnap.DBClient, System.DateUtils, untFrmProjetos;

type
  TfrmPrincipal = class(TForm)
    Layout1: TLayout;
    ScaledLayout1: TScaledLayout;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    Grade: TStringGrid;
    colunaLinguagem: TStringColumn;
    colunaProjetos: TStringColumn;
    DataSetLinguagens: TClientDataSet;
    DataSetLinguagenslinguagem: TStringField;
    DataSetLinguagensprojetos: TIntegerField;
    procedure GradeResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GradeSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
  private
    FListaProjetos: TObjectList<TProjeto>;
    procedure AjustarTamanhoColunasGrid;
    function ConsultarAPIGitHub: boolean;
    function RetirarAspas(pTexto: string): string;
    procedure AdicionarAoDataSetLinguagens(pLinguagem: string);
    procedure IncrementarQuantidadeProjetos;
    procedure InserirLinguagemNoDataSet(pLinguagem: string);
    function TestarSeLinguagemExisteNoDataSet(pLinguagem: string): boolean;
    function JSONDateToDatetime(pJSONDate: string): TDatetime;
    procedure SetarDadosGrid;
    procedure AbrirFormularioProjetos(pColuna, pLinha: integer);
    procedure OrdenarDataSet;
    procedure PercorrerJSONRepositorios(pJSONRepositorios: TJSONObject);
    procedure CriarListaDeObjetosProjetos;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}
{$R *.LgXhdpiPh.fmx ANDROID}

procedure TfrmPrincipal.AjustarTamanhoColunasGrid;
var
  lTamanhoGrid: Double;
  lQuantidadeColunas: Double;
  lTamanhoCampo: Double;
  lIndice: integer;
begin
  lTamanhoGrid := Grade.Width;
  lQuantidadeColunas := Grade.ColumnCount;

  lTamanhoCampo := lTamanhoGrid / lQuantidadeColunas;

  for lIndice := 0 to lQuantidadeColunas.ToString.ToInteger-1 do
  begin
    Grade.Columns[lIndice].Width := lTamanhoCampo;
  end;
end;

procedure TfrmPrincipal.GradeResize(Sender: TObject);
begin
  AjustarTamanhoColunasGrid;
end;

procedure TfrmPrincipal.GradeSelectCell(Sender: TObject; const ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
  if (ACol > -1) and (ARow > -1) then
  begin
    AbrirFormularioProjetos(ACol, ARow);
  end;
end;

procedure TfrmPrincipal.AbrirFormularioProjetos(pColuna, pLinha: integer);
var
  lFormProjetos: TfrmProjetos;
begin
  lFormProjetos := TfrmProjetos.Create(Application);
  lFormProjetos.Linguagem := Grade.Cells[pColuna, pLinha];
  lFormProjetos.Projetos  := FListaProjetos;
  lFormProjetos.Show;
end;

procedure TfrmPrincipal.CriarListaDeObjetosProjetos;
begin
  FListaProjetos := TObjectList<TProjeto>.Create;
end;

procedure TfrmPrincipal.PercorrerJSONRepositorios(pJSONRepositorios: TJSONObject);
var
  lIterator: integer;
  lIteratorProjetos: integer;
  lJSONObjectRepositorio: TJSONObject;
  lProjeto: TProjeto;
  lNodoJSON: string;
  lNodoJSONValor: string;
begin
  CriarListaDeObjetosProjetos;

  for lIterator := 0 to pJSONRepositorios.Count-1 do
  begin
    lProjeto := TProjeto.Create;
    try
      lJSONObjectRepositorio := TJsonObject(pJSONRepositorios.Pairs[lIterator]);

      for lIteratorProjetos := 0 to lJSONObjectRepositorio.Count-1 do
      begin
        lNodoJSON := lJSONObjectRepositorio.Pairs[lIteratorProjetos].JsonString.ToString.Trim;
        lNodoJSONValor := lJSONObjectRepositorio.Pairs[lIteratorProjetos].JsonValue.ToString.Trim;

        if lNodoJSON = '"language"' then
        begin
          lProjeto.Linguagem := RetirarAspas(lNodoJSONValor);
          AdicionarAoDataSetLinguagens(lProjeto.Linguagem);
        end
        else if lNodoJSON = '"name"' then
        begin
          lProjeto.Nome := RetirarAspas(lNodoJSONValor);
        end
        else if lNodoJSON = '"created_at"' then
        begin
          lProjeto.DataCriacao := JSONDateToDatetime(lNodoJSONValor);
        end
        else if lNodoJSON = '"updated_at"' then
        begin
          lProjeto.DataAlteracao := JSONDateToDatetime(lNodoJSONValor);
        end
        else if lNodoJSON = '"open_issues"' then
        begin
          lProjeto.Topicos := lNodoJSONValor.ToInteger;
        end;
      end;
    finally
      FListaProjetos.Add(lProjeto);
    end;
  end;
end;

function TfrmPrincipal.ConsultarAPIGitHub: boolean;
var
  lDadosAPIGitHub: TDadosAPIGitHub;
  lJSONObject: TJSONObject;
begin
  Result := True;

  lDadosAPIGitHub := TDadosAPIGitHub.Create;
  try
    lJSONObject := lDadosAPIGitHub.ObterJSONRepositorios;
  finally
    lDadosAPIGitHub.Free;
  end;

  if lJSONObject <> nil then
  begin
    PercorrerJSONRepositorios(lJSONObject);
  end
  else
  begin
    Result := False;
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  DataSetLinguagens.CreateDataSet;
  if ConsultarAPIGitHub then
  begin
    SetarDadosGrid;
  end
  else
  begin
    ShowMessage('Dados offline indisponíveis');
  end;
end;

procedure TfrmPrincipal.OrdenarDataSet;
begin
  DataSetLinguagens.IndexFieldNames := 'projetos;linguagem';
end;

procedure TfrmPrincipal.SetarDadosGrid;
const
  COLUNA_LINGUAGEM = 0;
  COLUNA_PROJETOS = 1;
begin
  OrdenarDataSet;
  DataSetLinguagens.First;
  while not DataSetLinguagens.Eof do
  begin
    Grade.RowCount := Grade.RowCount+1;
    Grade.Cells[COLUNA_LINGUAGEM, Grade.RowCount-1] := DataSetLinguagens.FieldByName('linguagem').AsString.Trim;
    Grade.Cells[COLUNA_PROJETOS, Grade.RowCount-1] := DataSetLinguagens.FieldByName('projetos').AsString;
    DataSetLinguagens.Next;
  end;
end;

function TfrmPrincipal.RetirarAspas(pTexto: string): string;
begin
  Result := StringReplace(pTexto, '"', EmptyStr, [rfReplaceAll]);
end;

procedure TfrmPrincipal.AdicionarAoDataSetLinguagens(pLinguagem: string);
begin
  if not TestarSeLinguagemExisteNoDataSet(pLinguagem) then
  begin
    InserirLinguagemNoDataSet(pLinguagem);
  end
  else
  begin
    IncrementarQuantidadeProjetos;
  end;
end;

procedure TfrmPrincipal.InserirLinguagemNoDataSet(pLinguagem: string);
begin
  DataSetLinguagens.Append;
  DataSetLinguagens.FieldByName('linguagem').Value    := pLinguagem;
  DataSetLinguagens.FieldByName('projetos').AsInteger := 1;
  DataSetLinguagens.Post;
end;

procedure TfrmPrincipal.IncrementarQuantidadeProjetos;
begin
  DataSetLinguagens.Edit;
  DataSetLinguagens.FieldByName('projetos').Value := DataSetLinguagens.FieldByName('projetos').AsInteger + 1;
  DataSetLinguagens.Post;
end;

function TfrmPrincipal.TestarSeLinguagemExisteNoDataSet(pLinguagem: string): boolean;
begin
  Result := DataSetLinguagens.Locate('linguagem', pLinguagem, [loCaseInsensitive]);
end;

function TfrmPrincipal.JSONDateToDatetime(pJSONDate: string): TDatetime;
var
  lAno, lMes, lDia, lHora, lMinuto, lSegundo: Word;
begin
  pJSONDate := RetirarAspas(pJSONDate);
  lAno         := StrToInt(Copy(pJSONDate, 1, 4));
  lMes         := StrToInt(Copy(pJSONDate, 6, 2));
  lDia         := StrToInt(Copy(pJSONDate, 9, 2));
  lHora        := StrToInt(Copy(pJSONDate, 12, 2));
  lMinuto      := StrToInt(Copy(pJSONDate, 15, 2));
  lSegundo     := StrToInt(Copy(pJSONDate, 18, 2));

  Result := EncodeDateTime(lAno, lMes, lDia, lHora, lMinuto, lSegundo, 0);
end;

end.
