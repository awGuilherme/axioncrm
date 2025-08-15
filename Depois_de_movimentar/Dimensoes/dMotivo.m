let
    Fonte = MySQL.Database(
        "147.79.82.25", 
        Banco, 
        [ReturnSingleDatabase = true]
    ),
    
    neg_motivo_naoconversao = Fonte{
        [
            Schema = Banco, 
            Item = "neg_motivo_naoconversao"
        ]
    }
    [Data]
in
    neg_motivo_naoconversao
