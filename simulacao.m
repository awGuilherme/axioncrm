let
    Fonte = Excel.Workbook(
        File.Contents(
            "C:\Users\PC Gamer\Desktop\GuilhermeDashs\BaseDados-20250924T190040Z-1-001\BaseDados\Receitas.xlsx"
        ),
        null,
        true
    ),
    Receitas_Sheet = Fonte{[Item = "Receitas", Kind = "Sheet"]}[Data],
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Receitas_Sheet, [PromoteAllScalars = true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(
        #"Cabeçalhos Promovidos",
        {
            {"DataEmissao", type date},
            {"DataVencimento", type date},
            {"NFe", Int64.Type},
            {"cdProduto", Int64.Type},
            {"cdVendedor", Int64.Type},
            {"Vendedor", type text},
            {"Supervisor", type text},
            {"Equipe Vendas", type text},
            {"QtdItens", Int64.Type},
            {"PrecoUnitario", type number},
            {"ValorBruto", type number}
        }
    ),
    #"Personalização Adicionada" = Table.AddColumn(#"Tipo Alterado", "idContaReceita", each "1.01.01")
in
    #"Personalização Adicionada"
