let
    Fonte = MySQL.Database(
        "147.79.82.25", 
        Banco, 
        [ReturnSingleDatabase=true]
    ),
    
    neg_prospecter_responsaveis = Fonte{
        [
            Schema= Banco, 
            Item="neg_prospecter_responsaveis"
        ]
    }
    [Data],
    
    #"Consultas Mescladas" = Table.NestedJoin(
        neg_prospecter_responsaveis, 
        {"id_usuario"}, 
        neg_usuarios, 
        {"idusuario"}, 
        "usuarios", 
        JoinKind.LeftOuter
    ),
    
    #"usuarios Expandido" = Table.ExpandTableColumn(#"Consultas Mescladas", "usuarios", {"usuario", "status"}, {"usuario", "status"}),
    
    #"Duplicatas Removidas" = Table.Distinct(#"usuarios Expandido", {"id_usuario"}),
    
    #"Linhas Classificadas" = Table.Sort(#"Duplicatas Removidas",{{"id_usuario", Order.Ascending}})
in
    #"Linhas Classificadas"