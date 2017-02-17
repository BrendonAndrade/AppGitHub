unit untFrmProjetos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FMX.TreeView,
  System.Generics.Collections, untProjetoClass;

type
  TfrmProjetos = class(TForm)
    Layout1: TLayout;
    ScaledLayout1: TScaledLayout;
    TabControl1: TTabControl;
    TabItem1: TTabItem;
    ArvoreItens: TTreeView;
    lblLinguagem: TLabel;
    procedure FormShow(Sender: TObject);
  private
    FProjetos: TObjectList<TProjeto>;
    FLinguagem: string;
    procedure AdicionarProjetoNaArvore(pProjeto: TProjeto);
    procedure ExibirProjetosDaLinguagemSelecionada;
  public
    property Projetos: TObjectList<TProjeto> read FProjetos write FProjetos;
    property Linguagem: string read FLinguagem write FLinguagem;
  end;

implementation

{$R *.fmx}

procedure TfrmProjetos.AdicionarProjetoNaArvore(pProjeto: TProjeto);
var
  lItemProjeto: TTreeViewItem;
  lSubItemDataCriacao: TTreeViewItem;
  lSubItemDataAlteracao: TTreeViewItem;
  lSubItemTopicos: TTreeViewItem;
begin
  lItemProjeto := TTreeViewItem.Create(ArvoreItens);
  lItemProjeto.Parent := ArvoreItens;
  lItemProjeto.Text := pProjeto.Nome;

  lSubItemDataCriacao := TTreeViewItem.Create(lItemProjeto);
  lSubItemDataCriacao.Parent := lItemProjeto;
  lSubItemDataCriacao.Text := 'Criado em: ' + FormatDateTime('dd/mm/yyyy', pProjeto.DataCriacao);

  lSubItemDataAlteracao := TTreeViewItem.Create(lItemProjeto);
  lSubItemDataAlteracao.Parent := lItemProjeto;
  lSubItemDataAlteracao.Text := 'Alterado em: ' + FormatDateTime('dd/mm/yyyy', pProjeto.DataAlteracao);

  lSubItemTopicos := TTreeViewItem.Create(lItemProjeto);
  lSubItemTopicos.Parent := lItemProjeto;
  lSubItemTopicos.Text := 'Tópicos: ' + pProjeto.Topicos.ToString;
end;

procedure TfrmProjetos.ExibirProjetosDaLinguagemSelecionada;
var
  lProjeto: TProjeto;
begin
  for lProjeto in FProjetos do
  begin
    if lProjeto.Linguagem = FLinguagem then
    begin
      AdicionarProjetoNaArvore(lProjeto);
    end;
  end;
end;

procedure TfrmProjetos.FormShow(Sender: TObject);
begin
  lblLinguagem.Text := FLinguagem;
  ExibirProjetosDaLinguagemSelecionada;
end;

end.
