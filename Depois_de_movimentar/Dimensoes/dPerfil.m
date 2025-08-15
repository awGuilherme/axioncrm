let
    Fonte = MySQL.Database(
        "147.79.82.25", 
        Banco, 
        [ReturnSingleDatabase = true]
    ),
    
    neg_perfil = Fonte
    {
        [
            Schema = Banco, 
            Item = "neg_perfil"
        ]
    }
    [Data]
in
    neg_perfil
