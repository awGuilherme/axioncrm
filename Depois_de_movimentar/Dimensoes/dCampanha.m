let
    Fonte = MySQL.Database
    (
        "147.79.82.25", 
        Banco, 
        [ReturnSingleDatabase=true]
    ),
    
    neg_campanha = Fonte
    {
        [
            Schema= Banco, 
            Item="neg_campanha"
        ]
    }
    [Data],
    
    #"Linhas Filtradas" = Table.SelectRows
    (
        neg_campanha, 
        each true
    )
in
    #"Linhas Filtradas"