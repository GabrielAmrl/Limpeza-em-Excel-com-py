select
    'RJ' as Distribuidora --base_ordens_totais
    ,'Grupo B' as Grupo_Tensao
    ,ano as ano_abertura
    ,mes as mes_abertura
    ,anomes as anomes_abertura
    ,ano_encerramento
    ,mes_encerramento
    ,anomes_encerramento
    ,des_servico
    ,descricao_etapa
    ,AREA_RESPONSAVEL
    ,Responsavel
    ,area_responsavel_etapa
    ,responsavel_etapa
    ,negocio
    ,regulada
    ,artigo
    ,status_prazo
    ,farol_prazo
    ,Controle_Prazo
    ,status_ordem
    ,count(numero_ordem) as qtd
    from
    (select distinct
    corr_visita
    ,ultima_etapa
    ,ano
    ,mes
    ,anomes
    ,left(A.data_estado,4) as ano_encerramento
    ,substring(A.data_estado,6,2) as mes_encerramento
    ,ano_encerramento||mes_encerramento as anomes_encerramento
    ,A.numero_ordem
    ,case
        when trim(A.numero_ordem_relac) ='' then  '-'
        when trim(A.numero_ordem_relac) =' ' then  '-'
        else A.numero_ordem_relac end as numero_ordem_relac
    ,D.cluster_ordem
    ,case when numero_cliente isnull then 0
    else numero_cliente end as Numero_cliente
    ,nro_caso as numero_caso
    ,A.Tipo_Ordem
    ,A.cod_servico
    ,A.des_servico
    ,cod_etapa
    ,descricao_etapa
    ,cod_retorno
    ,descricao_retorno
    ,D.AREA_RESPONSAVEL
    ,D.Responsavel
    ,D.area_responsavel_etapa
    ,D.responsavel_etapa
    ,negocio
    ,D.regulada
    ,D.artigo
    ,case when A.numero_ordem_relac > 0 and descricao = 'ABERTA' or descricao = 'FECHADA' then E.ESTADO_DA_ORDEM else  A.ESTADO end AS ESTADO
    ,case when A.numero_ordem_relac > 0 and descricao = 'ABERTA' or descricao = 'FECHADA' then E.DESCRICAO_ORDEM else descricao end as Estado_Ordem
    ,case when A.numero_ordem_relac > 0 and descricao = 'ABERTA' or descricao = 'FECHADA' then E.STATUS_DA_ORDEM else  c.status_ordem end as status_ordem
    ,convert(varchar(19),Data_ingresso) as Data_abertura
    ,convert(varchar(19),data_fim_regulada) as data_fim_regulada
    ,case 
        when left(sysdate,10) = left(data_fim_regulada,10) and Status_ordem = 'ABERTA' then 'Vence Hoje'
        when sysdate > data_fim_regulada and Status_ordem = 'ABERTA' then 'Vencida'
            when data_fim_regulada <= sysdate+7 AND Status_ordem = 'ABERTA' then 'Vence na Semana'
        when Status_ordem <> 'ABERTA' then '-'
        else 'A Vencer'
        end as Controle_Prazo
    ,left(data_visita,10) as Data_visita
    ,case when A.numero_ordem_relac > 0 and E.data_exec_visita <> '' then E.data_estado
                when A.data_exec_visita <> '' then left(A.data_exec_visita,10)||' '||convert(varchar(8),right(A.hora_exec_visita,8))
                else null end as data_execucao_visita
    ,case
        when situacao = 'N' then 'Dentro do Prazo'
        when situacao = '' then 'Dentro do Prazo'
        when situacao = 'X' then 'Alerta'
        when situacao = 'A' then 'Fora do Prazo'
    end as Status_Prazo
    ,case
        when situacao in ('N', 'X', '') then 'DP'
        when situacao = 'A' then 'FP'
    end as Farol_Prazo
    ,convert(varchar(19),A.Data_estado) as data_estado
    ,observacoes
    ,observacao_exe
    ,upper(left(rol_ingresso,12)) as rol_ingresso
    ,upper(left(rol_visita,12)) as rol_visita
    ,tempo_max_servico
    ,case
        when descricao_retorno is null or descricao_retorno = '' then 'Nenhuma_acao'
        when ind_serv_executado = 'S' then 'Servico_Executado'
        when ind_encerra_ordem = 'S' then 'Encerra_ordem'
        when ind_def_tec_client = 'S' then 'Def_tecnico_cliente'
        when ind_def_tec_empres = 'S' then 'Defeito_tecnico_empresa'
        when ind_pendencia = 'S' then 'Suspensa'
        else 'Nenhuma_acao'
    end as acao_retorno
    ,case
        when ind_efeito_tempo = 'P' then 'Para Tempo'
        when ind_efeito_tempo = 'N' then 'Nao Afeta'
        when ind_efeito_tempo = 'Z' then 'Zera Tempo'
    else ''
    end as efeito_tempo_descricao
    ,last_update as Atualizacao
    --Subquery tratando datas vazias
    from 
    (
        select corr_visita,
        data_estado,
        case 
        when ROW_NUMBER() OVER (PARTITION BY NUMERO_ORDEM ORDER BY corr_visita DESC) = 1
        then true 
        else false
    end as Ultima_Etapa,
        left(data_ingresso,4) as Ano,
        substring(data_ingresso,6,2) as mes, 
        ano||mes as anomes,
        data_ingresso,
        estado,
        etapa,
        nro_gac,
        numero_cliente,
        numero_ordem,
        numero_ordem_relac,
        observacao_exe,
        observacoes,
        rol_ingresso,
        rol_visita,
        tipo_ordem,
        tipo_servico,
        cod_retorno,
        CASE 
            WHEN data_visita <> '' 
            THEN data_visita 
            ELSE NULL 
        END AS data_visita,
        CASE 
            WHEN data_exec_visita <> '' 
            THEN data_exec_visita||' '||convert(varchar(8),right(hora_exec_visita,8))
            ELSE NULL 
        END AS data_exec_visita,
        hora_exec_visita,
        case 
            when data_fim_regulada <> '' 
            then data_fim_regulada 
            else left(convert(varchar(19),DATE_TRUNC('day',cast(tempo_max_servico / 24 AS INT) + cast(data_ingresso AS DATE))),10)||' '||convert(varchar(8),right(data_ingresso,8))
        end as data_fim_regulada,
        situacao,
        dias,
        horas,
        minutos,
        segundos,
        tipo,
        cod_servico,
        des_servico,
        ind_tempo,
        tempo_max_servico,
        cod_etapa,
        descricao_etapa,
        descricao_retorno,
        ind_serv_executado,
        ind_encerra_ordem,
        ind_def_tec_client,
        ind_def_tec_empres,
        ind_pendencia,
        ind_efeito_tempo,
        ind_movimenta_med,
        ind_procedente,
        nro_caso,
        sucursal,
        last_update,
        sysdate as data_referencia
        from Bi_brrj_cus.bt_brrj_clientes_ordem_servico
        ) A
    left join DP_BRRJ.TB_AUX_DEPARA_ESTADO_ORDENS C on C.ESTADO = A.ESTADO
    left join DP_BRRJ.TB_AUX_DEPARA_TIPO_SERVICOS D on D.CHAVE = A.tipo_ordem||A.cod_servico||RTRIM(A.des_servico)
    left join (select numero_ordem, data_estado, numero_ordem_relac, case when data_exec_visita <> '' then data_exec_visita else null end as data_exec_visita, hora_exec_visita, 
    B.DESCRICAO as DESCRICAO_ORDEM, B.status_ordem as STATUS_DA_ORDEM, B.ESTADO as ESTADO_DA_ORDEM from Bi_brrj_cus.bt_brrj_clientes_ordem_servico A
    left join DP_BRRJ.TB_AUX_DEPARA_ESTADO_ORDENS B on B.ESTADO = A.ESTADO) E on E.NUMERO_ORDEM = A.numero_ordem_relac
    where ultima_etapa = true and cluster_ordem = 'INICIATIVA CLIENTE' and status_prazo is not null and ano >= '2024') 
    group by
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21
    union all
    select
    'RJ' as Distribuidora
    ,'Grupo A' as Grupo_Tensao
    ,ano as ano_abertura
    ,mes as mes_abertura
    ,anomes as anomes_abertura
    ,ano_encerramento
    ,mes_encerramento
    ,anomes_encerramento
    ,des_servico
    ,descricao_etapa
    ,AREA_RESPONSAVEL
    ,Responsavel
    ,area_responsavel_etapa
    ,responsavel_etapa
    ,negocio
    ,regulada
    ,artigo
    ,status_prazo
    ,farol_prazo
    ,Controle_Prazo
    ,status_ordem
    ,count(numero_ordem) as qtd
    from
    (select distinct
    corr_visita
    ,ultima_etapa
    ,ano
    ,mes
    ,anomes
    ,left(A.data_estado,4) as ano_encerramento
    ,substring(A.data_estado,6,2) as mes_encerramento
    ,ano_encerramento||mes_encerramento as anomes_encerramento
    ,A.numero_ordem
    ,case
        when trim(A.numero_ordem_relac) ='' then  '-'
        when trim(A.numero_ordem_relac) =' ' then  '-'
        else A.numero_ordem_relac end as numero_ordem_relac
    ,D.cluster_ordem
    ,case when numero_cliente isnull then 0
    else numero_cliente end as Numero_cliente
    ,nro_caso as numero_caso
    ,A.Tipo_Ordem
    ,A.cod_servico
    ,A.des_servico
    ,cod_etapa
    ,descricao_etapa
    ,cod_retorno
    ,descricao_retorno
    ,D.AREA_RESPONSAVEL
    ,D.Responsavel
    ,D.area_responsavel_etapa
    ,D.responsavel_etapa
    ,negocio
    ,D.regulada
    ,D.artigo
    ,case when A.numero_ordem_relac > 0 and descricao = 'ABERTA' or descricao = 'FECHADA' then E.ESTADO_DA_ORDEM else  A.ESTADO end AS ESTADO
    ,case when A.numero_ordem_relac > 0 and descricao = 'ABERTA' or descricao = 'FECHADA' then E.DESCRICAO_ORDEM else descricao end as Estado_Ordem
    ,case when A.numero_ordem_relac > 0 and descricao = 'ABERTA' or descricao = 'FECHADA' then E.STATUS_DA_ORDEM else  c.status_ordem end as status_ordem
    ,convert(varchar(19),Data_ingresso) as Data_abertura
    ,convert(varchar(19),data_fim_regulada) as data_fim_regulada
    ,case 
        when left(sysdate,10) = left(data_fim_regulada,10) and Status_ordem = 'ABERTA' then 'Vence Hoje'
        when sysdate > data_fim_regulada and Status_ordem = 'ABERTA' then 'Vencida'
            when data_fim_regulada <= sysdate+7 AND Status_ordem = 'ABERTA' then 'Vence na Semana'
        when Status_ordem <> 'ABERTA' then '-'
        else 'A Vencer'
        end as Controle_Prazo
    ,left(data_visita,10) as Data_visita
    ,case when A.numero_ordem_relac > 0 and E.data_exec_visita <> '' then E.data_estado
                when A.data_exec_visita <> '' then left(A.data_exec_visita,10)||' '||convert(varchar(8),right(A.hora_exec_visita,8))
                else null end as data_execucao_visita
    ,case
        when situacao = 'N' then 'Dentro do Prazo'
        when situacao = '' then 'Dentro do Prazo'
        when situacao = 'X' then 'Alerta'
        when situacao = 'A' then 'Fora do Prazo'
    end as Status_Prazo
    ,case
        when situacao in ('N', 'X', '') then 'DP'
        when situacao = 'A' then 'FP'
    end as Farol_Prazo
    ,convert(varchar(19),A.Data_estado) as data_estado
    ,observacoes
    ,observacao_exe
    ,upper(left(rol_ingresso,12)) as rol_ingresso
    ,upper(left(rol_visita,12)) as rol_visita
    ,tempo_max_servico
    ,case
        when descricao_retorno is null or descricao_retorno = '' then 'Nenhuma_acao'
        when ind_serv_executado = 'S' then 'Servico_Executado'
        when ind_encerra_ordem = 'S' then 'Encerra_ordem'
        when ind_def_tec_client = 'S' then 'Def_tecnico_cliente'
        when ind_def_tec_empres = 'S' then 'Defeito_tecnico_empresa'
        when ind_pendencia = 'S' then 'Suspensa'
        else 'Nenhuma_acao'
    end as acao_retorno
    ,case
        when ind_efeito_tempo = 'P' then 'Para Tempo'
        when ind_efeito_tempo = 'N' then 'Nao Afeta'
        when ind_efeito_tempo = 'Z' then 'Zera Tempo'
    else ''
    end as efeito_tempo_descricao
    ,last_update as Atualizacao
    --Subquery tratando datas vazias
    from 
    (
        select corr_visita,
        data_estado,
        case 
        when ROW_NUMBER() OVER (PARTITION BY NUMERO_ORDEM ORDER BY corr_visita DESC) = 1
        then true 
        else false
    end as Ultima_Etapa,
        left(data_ingresso,4) as Ano,
        substring(data_ingresso,6,2) as mes, 
        ano||mes as anomes,
        data_ingresso,
        estado,
        etapa,
        nro_gac,
        numero_cliente,
        numero_ordem,
        numero_ordem_relac,
        observacao_exe,
        observacoes,
        rol_ingresso,
        rol_visita,
        tipo_ordem,
        tipo_servico,
        cod_retorno,
        CASE 
            WHEN data_visita <> '' 
            THEN data_visita 
            ELSE NULL 
        END AS data_visita,
        CASE 
            WHEN data_exec_visita <> '' 
            THEN data_exec_visita||' '||convert(varchar(8),right(hora_exec_visita,8))
            ELSE NULL 
        END AS data_exec_visita,
        hora_exec_visita,
        case 
            when data_fim_regulada <> '' 
            then data_fim_regulada 
            else left(convert(varchar(19),DATE_TRUNC('day',cast(tempo_max_servico / 24 AS INT) + cast(data_ingresso AS DATE))),10)||' '||convert(varchar(8),right(data_ingresso,8))
        end as data_fim_regulada,
        situacao,
        dias,
        horas,
        minutos,
        segundos,
        tipo,
        cod_servico,
        des_servico,
        ind_tempo,
        tempo_max_servico,
        cod_etapa,
        descricao_etapa,
        descricao_retorno,
        ind_serv_executado,
        ind_encerra_ordem,
        ind_def_tec_client,
        ind_def_tec_empres,
        ind_pendencia,
        ind_efeito_tempo,
        ind_movimenta_med,
        ind_procedente,
        nro_caso,
        sucursal,
        last_update,
        sysdate as data_referencia
        from Bi_brrj_cus.bt_brrj_grandes_ordem_servico
        ) A
    left join DP_BRRJ.TB_AUX_DEPARA_ESTADO_ORDENS C on C.ESTADO = A.ESTADO
    left join DP_BRRJ.TB_AUX_DEPARA_TIPO_SERVICOS D on D.CHAVE = A.tipo_ordem||A.cod_servico||RTRIM(A.des_servico)
    left join (select numero_ordem, data_estado, numero_ordem_relac, case when data_exec_visita <> '' then data_exec_visita else null end as data_exec_visita, hora_exec_visita, 
    B.DESCRICAO as DESCRICAO_ORDEM, B.status_ordem as STATUS_DA_ORDEM, B.ESTADO as ESTADO_DA_ORDEM from Bi_brrj_cus.bt_brrj_grandes_ordem_servico A
    left join DP_BRRJ.TB_AUX_DEPARA_ESTADO_ORDENS B on B.ESTADO = A.ESTADO) E on E.NUMERO_ORDEM = A.numero_ordem_relac
    where ultima_etapa = true and cluster_ordem = 'INICIATIVA CLIENTE' and status_prazo is not null and ano >='2024')
    group by
    1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21;