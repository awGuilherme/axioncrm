let
    Fonte = MySQL.Database("147.79.82.25", "stageprod", [ReturnSingleDatabase=true]),
    adaptweb01_neg_motivo_naoconversao = Fonte{[Schema="adaptweb01",Item="neg_motivo_naoconversao"]}[Data]
in
    adaptweb01_neg_motivo_naoconversao