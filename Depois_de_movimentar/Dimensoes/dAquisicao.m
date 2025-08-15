let
    Fonte = MySQL.Database(
        "147.79.82.25", 
        Banco, 
        [ReturnSingleDatabase = true]
    ),

    neg_aquisicao = Fonte{
        [
            Schema = Banco, 
            Item = "neg_aquisicao"
        ]
    }
    [Data]
in
    neg_aquisicao