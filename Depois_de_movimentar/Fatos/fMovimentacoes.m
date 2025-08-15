let
    Fonte = MySQL.Database(
        "147.79.82.25", 
        Banco, 
        [ReturnSingleDatabase = true]
    ),

    neg_funil = Fonte
    {
        [
            Schema = Banco, 
            Item = "neg_funil"
        ]
        }
        [Data],

    #"Coluna Duplicada" = Table.DuplicateColumn(
        neg_funil, 
        "data", 
        "Date_data"
    ),

    #"Tipo Alterado" = Table.TransformColumnTypes
    (
        #"Coluna Duplicada", 
        {
            {
                "Date_data", 
                type date
            }
        }
    ),

    #"Linhas Classificadas" = Table.Sort(
        #"Tipo Alterado", 
        {
            {
                "id_negp", 
                Order.Ascending
            }
        }
    ),

    #"Consultas Mescladas" = Table.NestedJoin(
        #"Linhas Classificadas", 
        {"id_etapa_funil"}, 
        dFunil, 
        {"idnfe"}, 
        "dFunil", 
        JoinKind.LeftOuter
    ),

    #"dFunil Expandido" = Table.ExpandTableColumn(
        #"Consultas Mescladas",
        "dFunil",
        {
            "id_neg_funis", 
            "del", 
            "nome"
        },
        {
            "id_neg_funis", 
            "status_funil", 
            "nome_funil"
        }
    ),

    #"Personalização Adicionada" = Table.AddColumn(
        #"dFunil Expandido",
        "Funil Inicial",
        each
            let
                LeadID = [id_negp],
                TabelaDoLead = Table.SelectRows(
                    #"dFunil Expandido", 
                    each [id_negp] = LeadID
                ),
                MenorData = List.Min(TabelaDoLead[data]),
                LinhaInicial = Table.SelectRows(
                    TabelaDoLead, 
                    each [data] = MenorData
                ),
                FunilInicial = LinhaInicial{0}[nome_funil]
            in
                FunilInicial
    ),

    #"Tipo Alterado1" = Table.TransformColumnTypes(
        #"Personalização Adicionada", 
        {
            {
                "Funil Inicial", 
                type text
            }
        }
    ),

    #"Linhas Filtradas" = Table.SelectRows(
        #"Tipo Alterado1", 
        each [data] > #datetime(
            2022, 1, 1, 0, 0, 0
        )
    )
in
    #"Linhas Filtradas"
