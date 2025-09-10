let
    Fonte = MySQL.Database(
        "147.79.82.25", 
        Banco, 
        [ReturnSingleDatabase = true]
    ),

    neg_interacao = Fonte
    {
        [
            Schema = Banco, 
            Item = "neg_interacao"
        ]
    }
    [Data],

    #"Consultas Mescladas" = Table.NestedJoin(
        neg_interacao,
        {"id_tipo"},
        neg_interacao_tipo,
        {"id"},
        "neg_interacao_tipo",
        JoinKind.LeftOuter
    ),

    #"neg_interacao_tipo Expandido" = Table.ExpandTableColumn(
        #"Consultas Mescladas", 
        "neg_interacao_tipo", 
        {"nome"}, 
        {"nome"}
    ),

    #"Outras Colunas Removidas" = Table.SelectColumns(
        #"neg_interacao_tipo Expandido",
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

//[DataFormat.Error] Não conseguimos converter em Número.

    #"Tipo Alterado" = Table.TransformColumnTypes(
        #"Consultas Mescladas1", 
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
        [agenda_data] = null then [data] 
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
    )
    
    #"fVendas Expandido" =
    let
        Expanded = Table.ExpandTableColumn(
           #"Tipo Alterado1",
            "fVendas",
            {"etapa","id_neg_funis","nome"},
            {"etapa","id_neg_funis","nome.1"}
        ),
        SafeTypes = Table.TransformColumns(
            Expanded,
            {
                {"etapa", each try Text.From(_) otherwise null, type text},
                {"id_neg_funis", each try Number.From(_) otherwise null, type number},
                {"nome.1", each try Text.From(_) otherwise null, type text}
            }
        )
    in
        SafeTypes,

    #"Colunas Renomeadas" = Table.RenameColumns(
        #"fVendas Expandido", 
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

    #"Linhas Filtradas" = Table.SelectRows(
        #"Colunas Reordenadas", 
        each [data] > #date(
            2022, 1, 1
        )
    )
in
   #"Linhas Filtradas"

















   // Atual 23/08  11:49


//    let
//     Fonte = MySQL.Database("147.79.82.25", "stageprod", [ReturnSingleDatabase=true]),

//     neg_interacao = Fonte
//     {
//         [
//             Schema = Banco, 
//             Item = "neg_interacao"
//         ]
//     }
//     [Data],

//     #"Consultas Mescladas" = Table.NestedJoin(
//         neg_interacao,
//         {"id_tipo"},
//         neg_interacao_tipo,
//         {"id"},
//         "neg_interacao_tipo",
//         JoinKind.LeftOuter
//     ),

//     #"neg_interacao_tipo Expandido" = Table.ExpandTableColumn(
//         #"Consultas Mescladas", 
//         "neg_interacao_tipo", 
//         {"nome"}, 
//         {"nome"}
//     ),

//     #"Outras Colunas Removidas" = Table.SelectColumns(
//         #"neg_interacao_tipo Expandido",
//         {
//             "idni", 
//             "id_negociacao", 
//             "id_usuario", 
//             "agenda_data", 
//             "data", 
//             "status", 
//             "tipo", 
//             "id_tipo", 
//             "del", 
//             "nome"
//         }
//     ),

//        // join com fVendas
//     #"Consultas Mescladas1" = Table.NestedJoin(
//         #"Outras Colunas Removidas", 
//         {"id_negociacao"}, 
//         fVendas, 
//         {"idnp"}, 
//         "fVendas", 
//         JoinKind.LeftOuter
//     ),

//     // 🔧 garante que o campo fVendas continua sendo TABELA (e não number)
//     #"ForcaTipo_fVendas" = Table.TransformColumnTypes(#"Consultas Mescladas1",{{"fVendas", type any}}),

//     #"fVendas Expandido" =
//     let
//         Expanded = Table.ExpandTableColumn(
//             #"ForcaTipo_fVendas",
//             "fVendas",
//             {"etapa","id_neg_funis","nome"},
//             {"etapa","id_neg_funis","nome.1"}
//         ),
//         SafeTypes = Table.TransformColumns(
//             Expanded,
//             {
//                 {"etapa", each try Text.From(_) otherwise null, type text},
//                 {"id_neg_funis", each try Number.From(_) otherwise null, type number},
//                 {"nome.1", each try Text.From(_) otherwise null, type text}
//             }
//         )
//     in
//         SafeTypes,

//     #"Tipo Alterado" = Table.TransformColumnTypes(
//         #"fVendas Expandido", 
//         {
//             {
//                 "data", 
//                 type date
//             }, 
//             {
//                 "agenda_data", 
//                 type date
//             }
//         }
//     ),

//     // ✅ Corrigindo agenda_data com data quando for null
//     #"Agenda Corrigida" = Table.AddColumn(
//         #"Tipo Alterado", 
//         "agenda_corrigida", 
//         each if 
//         [agenda_data] = null then [data] 
//         else [agenda_data], 
//         type date
//     ),

//     #"Agenda Substituida" = Table.RemoveColumns(
//         #"Agenda Corrigida", 
//         {"agenda_data"}
//     ),

//     #"Renomeado" = Table.RenameColumns(
//         #"Agenda Substituida", 
//         {
//             {
//                 "agenda_corrigida", 
//                 "agenda_data"
//             }
//         }
//     ),

//     // ✅ Classificando a agenda
//     #"Personalização Adicionada" = Table.AddColumn(
//         #"Renomeado",
//         "classificacao_agenda",
//         each
//             let
//                 hoje = DateTime.Date(DateTime.LocalNow())
//             in
//                 if [tipo] <> "Reunião" then
//                     "Sem Agenda"
//                 else if [status] = "Concluida" then
//                     "Realizado"
//                 else if [status] = "Cancelada" then
//                     "No-show"
//                 else if [status] = "Aberto" and [agenda_data] >= hoje then
//                     "Programado"
//                 else if [status] = "Aberto" and [agenda_data] < hoje then
//                     "No-show"
//                 else
//                     "Desconhecido"
//     ),

//     #"Tipo Alterado1" = Table.TransformColumnTypes(
//         #"Personalização Adicionada", 
//         {
//             {
//                 "classificacao_agenda", 
//                 type text
//             }
//         }
//     ),

//     #"Colunas Renomeadas" = Table.RenameColumns(
//         #"Tipo Alterado1", 
//         {
//             {
//                 "nome.1", 
//                 "nome_funil"
//             }
//         }
//     ),

//     #"Colunas Reordenadas" = Table.ReorderColumns(
//         #"Colunas Renomeadas",
//         {
//             "idni",
//             "id_negociacao",
//             "id_usuario",
//             "data",
//             "agenda_data",
//             "status",
//             "tipo",
//             "classificacao_agenda",
//             "id_tipo",
//             "nome",
//             "etapa",
//             "id_neg_funis",
//             "nome_funil"
//         }
//     ),

//     #"Linhas Filtradas" = Table.SelectRows(#"Colunas Reordenadas", each [data] > #date(2022, 1, 1))
// in
//     #"Linhas Filtradas"