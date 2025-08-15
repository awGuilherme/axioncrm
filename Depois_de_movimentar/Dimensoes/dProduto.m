let
    Fonte = MySQL.Database(
        "147.79.82.25", 
        Banco, 
        [ReturnSingleDatabase=true]
    ),
    
    neg_produtos = Fonte{
        [
            Schema= Banco,
            Item="neg_produtos"
        ]
    }
    [Data],
    
    #"Outras Colunas Removidas" = Table.SelectColumns(
        neg_produtos,
        {
            "idnp", 
            "produto", 
            "status"
        }
    )
in
    #"Outras Colunas Removidas"