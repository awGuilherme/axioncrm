let
    Fonte = MySQL.Database(
        "147.79.82.25", 
        Banco, 
        [ReturnSingleDatabase = true]
    ),
    
    neg_etiquetas = Fonte{
        [
            Schema = Banco, 
            Item = "neg_etiquetas"
        ]
        }
        [Data],
    
    #"Outras Colunas Removidas" = Table.SelectColumns(
        neg_etiquetas, 
        {
            "idneg_etiquetas", 
            "titulo", 
            "status", 
            "del"
        }
    )
in
    #"Outras Colunas Removidas"
