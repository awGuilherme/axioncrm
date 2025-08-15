let
    Fonte = MySQL.Database(
        "147.79.82.25", 
        Banco, 
        [ReturnSingleDatabase = true]
    ),
    
    neg_funil_etapas = Fonte
    {
        [
            Schema = Banco,
            Item = "neg_funil_etapas"
        ]
    }
    [Data],
    
    #"Outras Colunas Removidas" = Table.SelectColumns(
        neg_funil_etapas,
        {
            "idnfe", 
            "etapa", 
            "status", 
            "entrada", 
            "conversao", 
            "nao_conversao", 
            "ordem", 
            "id_neg_funis", 
            "del"
        }
    ),
    
    #"Consultas Mescladas" = Table.NestedJoin(
        #"Outras Colunas Removidas",
        {"id_neg_funis"},
        neg_funis,
        {"idneg_funis"},
        "adaptweb01 neg_funis",
        JoinKind.LeftOuter
    ),
    
    #"adaptweb01 neg_funis Expandido" = Table.ExpandTableColumn(
        #"Consultas Mescladas", 
        "adaptweb01 neg_funis", 
        {"nome"}, 
        {"nome"}
    )
in
    #"adaptweb01 neg_funis Expandido"
