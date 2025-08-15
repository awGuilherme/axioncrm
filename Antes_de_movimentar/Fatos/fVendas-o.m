let
    Fonte = MySQL.Database("147.79.82.25", Banco, [ReturnSingleDatabase = true]),
    neg_prospecter = Fonte{[Schema = Banco, Item = "neg_prospecter"]}[Data],
    
    #"Outras Colunas Removidas" = Table.SelectColumns(
        neg_prospecter,
        {
            "idnp",
            "empresa",
            "responsavel",
            "cidade",
            "uf",
            "valor_adesao",
            "valor_recorrencia",
            "id_produto",
            "id_aquisicao",
            "id_campanha",
            "situacao",
            "id_perfil",
            "registro",
            "id_cliente",
            "del",
            "id_neg_etiquetas",
            "proposta_personalizada",
            "conversao",
            "id_usuario_conversao",
            "data_conversao",
            "id_motivo"
        }
    ),
    #"Linhas Classificadas" = Table.Sort(#"Outras Colunas Removidas", {{"registro", Order.Descending}}),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Linhas Classificadas", {{"registro", type date}}),
    #"Consultas Mescladas" = Table.NestedJoin(
        #"Tipo Alterado", {"idnp"}, dVendedor, {"id_negp"}, "neg_prospecter_responsaveis", JoinKind.LeftOuter
    ),
    #"neg_prospecter_responsaveis Expandido" = Table.ExpandTableColumn(
        #"Consultas Mescladas", "neg_prospecter_responsaveis", {"id_usuario"}, {"id_usuario"}
    ),
    #"Tipo Alterado1" = Table.TransformColumnTypes(
        #"neg_prospecter_responsaveis Expandido", {{"data_conversao", type date}, {"situacao", Int64.Type}}
    ),
    #"Linhas Filtradas" = Table.SelectRows(#"Tipo Alterado1", each true),
    #"Consultas Mescladas1" = Table.NestedJoin(
        #"Linhas Filtradas", {"situacao"}, dFunil, {"idnfe"}, "dFunil", JoinKind.LeftOuter
    ),
    #"dFunil Expandido" = Table.ExpandTableColumn(
        #"Consultas Mescladas1",
        "dFunil",
        {"etapa", "id_neg_funis", "del", "nome"},
        {"etapa", "id_neg_funis", "del.1", "nome"}
    ),
    #"Colunas Renomeadas" = Table.RenameColumns(#"dFunil Expandido", {{"situacao", "Etapa Atual"}}),
    #"Personalização Adicionada" = Table.AddColumn(
        #"Colunas Renomeadas",
        "Situação",
        each
            let
                hoje = DateTime.Date(DateTime.LocalNow())
            in
                if [conversao] = "Sim" then
                    "Convertido"
                else if [conversao] = "Nao" then
                    "Perdido"
                else if [conversao] = "0" then
                    "Em negociação"
                else
                    "Em negociação"
    ),
    #"Tipo Alterado2" = Table.TransformColumnTypes(#"Personalização Adicionada", {{"Situação", type text}}),
    #"Colunas Reordenadas" = Table.ReorderColumns(
        #"Tipo Alterado2",
        {
            "idnp",
            "empresa",
            "responsavel",
            "cidade",
            "uf",
            "valor_adesao",
            "valor_recorrencia",
            "id_produto",
            "id_aquisicao",
            "id_campanha",
            "Etapa Atual",
            "id_perfil",
            "registro",
            "id_cliente",
            "del",
            "id_neg_etiquetas",
            "proposta_personalizada",
            "conversao",
            "id_usuario_conversao",
            "data_conversao",
            "Situação",
            "id_motivo",
            "id_usuario",
            "etapa",
            "id_neg_funis",
            "del.1",
            "nome"
        }
    ),
    #"Personalização Adicionada1" = Table.AddColumn(
        #"Colunas Reordenadas",
        "dias_negociacao",
        each
            Duration.Days(
                if [data_conversao] <> null then
                    [data_conversao] - [registro]
                else
                    DateTime.Date(DateTime.LocalNow()) - [registro]
            )
    ),
    #"Tipo Alterado3" = Table.TransformColumnTypes(#"Personalização Adicionada1", {{"dias_negociacao", Int64.Type}}),
    #"Linhas Filtradas1" = Table.SelectRows(#"Tipo Alterado3", each [registro] > #date(2022, 1, 1))
in
    #"Linhas Filtradas1"