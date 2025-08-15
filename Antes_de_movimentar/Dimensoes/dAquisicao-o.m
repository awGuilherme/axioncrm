let
    Fonte = MySQL.Database("147.79.82.25", "stageprod", [ReturnSingleDatabase=true]),
    adaptweb01_neg_etiquetas = Fonte{[Schema="adaptweb01",Item="neg_etiquetas"]}[Data],
    #"Outras Colunas Removidas" = Table.SelectColumns(adaptweb01_neg_etiquetas,{"idneg_etiquetas", "titulo", "status", "del"})
in
    #"Outras Colunas Removidas"