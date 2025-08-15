let
    Fonte = MySQL.Database("147.79.82.25", "stageprod", [ReturnSingleDatabase=true]),
    adaptweb01_neg_produtos = Fonte{[Schema="adaptweb01",Item="neg_produtos"]}[Data],
    #"Outras Colunas Removidas" = Table.SelectColumns(adaptweb01_neg_produtos,{"idnp", "produto", "status"})
in
    #"Outras Colunas Removidas"