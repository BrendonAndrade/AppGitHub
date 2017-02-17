unit untProjetoClass;

interface

type
  TProjeto = class
  private
    FNome: string;
    FDataCriacao: TDateTime;
    FDataAlteracao: TDateTime;
    FTopicos: integer;
    FLinguagem: string;
  public
    property Nome: string read FNome write FNome;
    property DataCriacao: TDateTime read FDataCriacao write FDataCriacao;
    property DataAlteracao: TDateTime read FDataAlteracao write FDataAlteracao;
    property Topicos: integer read FTopicos write FTopicos;
    property Linguagem: string read FLinguagem write FLinguagem;
  end;

implementation

{ TProjeto }

end.
