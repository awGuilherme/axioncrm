let
    Fonte = MySQL.Database("147.79.82.25", "stageprod", [ReturnSingleDatabase=true]),
    adaptweb01_neg_perfil = Fonte{[Schema="adaptweb01",Item="neg_perfil"]}[Data]
in
    adaptweb01_neg_perfil