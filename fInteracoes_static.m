let
    Fonte = MySQL.Database(
        "localhost", 
        "adaptweb01", 
        [ReturnSingleDatabase = true]
    ),
    
    adaptweb01_neg_interacao = Fonte{
        [
            Schema = "adaptweb01", 
            Item = "neg_interacao"
        ]
    }
    [Data],
    
    #"Consultas Mescladas" = Table.NestedJoin(
        adaptweb01_neg_interacao,
        {"id_tipo"},
        #"adaptweb01 neg_interacao_tipo",
        {"id"},
        "adaptweb01 neg_interacao_tipo",
        JoinKind.LeftOuter
    ),
    
    #"adaptweb01 neg_interacao_tipo Expandido" = Table.ExpandTableColumn(
        #"Consultas Mescladas", 
        "adaptweb01 neg_interacao_tipo", 
        {"nome"}, 
        {"nome"}
    ),
    
    #"Outras Colunas Removidas" = Table.SelectColumns(
        #"adaptweb01 neg_interacao_tipo Expandido",
        {
            "idni", 
            "id_negociacao", 
            "id_usuario", 
            "agenda_data", 
            "data", 
            "status", 
            "tipo", 
            "id_tipo", 
            "del", 
            "nome"
        }
    ),
    
    #"Consultas Mescladas1" = Table.NestedJoin(
        #"Outras Colunas Removidas", 
        {"id_negociacao"}, 
        fVendas, 
        {"idnp"}, 
        "fVendas", 
        JoinKind.LeftOuter
    ),
    
    #"fVendas Expandido" = Table.ExpandTableColumn(
        #"Consultas Mescladas1", 
        "fVendas", 
        {
            "etapa", 
            "id_neg_funis", 
            "nome"
        }, 
        {
            "etapa", 
            "id_neg_funis", 
            "nome.1"
        }
    ),
    
    #"Tipo Alterado" = Table.TransformColumnTypes(
        #"fVendas Expandido", 
        {
            {
                "data", 
                type date
            }, 
            {
                "agenda_data", 
                type date
            }
        }
    ),
    
    // ✅ Corrigindo agenda_data com data quando for null
    #"Agenda Corrigida" = Table.AddColumn(
        #"Tipo Alterado", 
        "agenda_corrigida", 
        each if 
        [agenda_data] = null 
        then [data] 
        else [agenda_data], 
        type date
    ),
    
    #"Agenda Substituida" = Table.RemoveColumns(
        #"Agenda Corrigida", 
        {"agenda_data"}
    ),
    
    #"Renomeado" = Table.RenameColumns(
        #"Agenda Substituida", 
        {
            {
                "agenda_corrigida", 
                "agenda_data"
            }
        }
    ),

    // ✅ Classificando a agenda
    #"Personalização Adicionada" = Table.AddColumn(
        #"Renomeado",
        "classificacao_agenda",
        each
            let
                hoje = DateTime.Date(DateTime.LocalNow())
            in
                if [tipo] <> "Reunião" then
                    "Sem Agenda"
                else if [status] = "Concluida" then
                    "Realizado"
                else if [status] = "Cancelada" then
                    "No-show"
                else if [status] = "Aberto" and [agenda_data] >= hoje then
                    "Programado"
                else if [status] = "Aberto" and [agenda_data] < hoje then
                    "No-show"
                else
                    "Desconhecido"
    ),
    
    #"Tipo Alterado1" = Table.TransformColumnTypes(
        #"Personalização Adicionada", 
        {
            {
                "classificacao_agenda", 
                type text
            }
        }
    ),
    
    #"Colunas Renomeadas" = Table.RenameColumns
    (
        #"Tipo Alterado1", 
        {
            {
                "nome.1", 
                "nome_funil"
            }
        }
    ),
    
    #"Colunas Reordenadas" = Table.ReorderColumns(
        #"Colunas Renomeadas",
        {
            "idni",
            "id_negociacao",
            "id_usuario",
            "data",
            "agenda_data",
            "status",
            "tipo",
            "classificacao_agenda",
            "id_tipo",
            "nome",
            "etapa",
            "id_neg_funis",
            "nome_funil"
        }
    ),
    
    #"Linhas Filtradas" = Table.SelectRows
    (
        #"Colunas Reordenadas", 
        each [data] > #date(2022, 1, 1)
    ),
    
    #"Linhas Classificadas" = Table.Sort(
        #"Linhas Filtradas", {
            {
                "data", Order.Ascending
            }
        }
    )
in
    #"Linhas Classificadas"
