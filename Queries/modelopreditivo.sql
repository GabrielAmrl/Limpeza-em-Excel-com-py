DROP TABLE IF EXISTS _variables;

CREATE TEMPORARY TABLE _variables AS (
    SELECT
--        TO_CHAR(DATE_TRUNC('MONTH', CURRENT_DATE), 'YYYYMM')::nvarchar(6) as anomes,
        (SELECT TO_CHAR((DATE_TRUNC('MONTH', CURRENT_DATE)), 'YYYY-MM') as anomes)::varchar(7) as anomes,
        (SELECT TO_CHAR((DATE_TRUNC('MONTH', CURRENT_DATE) - INTERVAL '1 month'), 'YYYY-MM') as anomes_M1)::varchar(7) as anomes_M1,
		(SELECT TO_CHAR((DATE_TRUNC('MONTH', CURRENT_DATE) - INTERVAL '2 month'), 'YYYY-MM') as anomes_M2)::varchar(7) as anomes_M2);

DROP TABLE IF EXISTS Rec_iguais;
 
CREATE TEMPORARY TABLE Rec_iguais AS (
  SELECT cta_contrato, submotivo, COUNT(numero_caso) as Rec_reincidentes
  FROM bi_brrj_act.bt_brrj_requestqlik A
  left join _variables B on B.anomes = left(data_criacao,7)
  WHERE tipo_caso = 'Reclamação'
    AND dataingresso >= CURRENT_DATE - INTERVAL '6' MONTH AND expurgado = 'false' 
    AND motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial')
    AND cta_contrato IS NOT null --and left(data_criacao,7) = B.anomes_m1
  GROUP BY 1, 2
  HAVING COUNT(numero_caso) >= 2
  union all 
  SELECT cta_contrato, submotivo, COUNT(numero_caso) as Rec_reincidentes
  FROM bi_brce_act.bt_brce_requestqlik A
  left join _variables B on B.anomes = left(data_criacao,7)
  WHERE tipo_caso = 'Reclamação'
    AND dataingresso >= CURRENT_DATE - INTERVAL '6' MONTH AND expurgado = 'false' 
    AND motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial')
    AND cta_contrato IS NOT null --and left(data_criacao,7) = B.anomes_m1
  GROUP BY 1, 2
  HAVING COUNT(numero_caso) >= 2
);

DROP TABLE IF EXISTS Rec_diversas;

CREATE TEMPORARY TABLE Rec_diversas AS (
  SELECT cta_contrato, COUNT(DISTINCT submotivo) as Rec_diversas
  FROM bi_brrj_act.bt_brrj_requestqlik A
  left join _variables B on B.anomes = left(data_criacao,7)
  WHERE tipo_caso = 'Reclamação'
    AND dataingresso >= CURRENT_DATE - INTERVAL '6' MONTH AND expurgado = 'false' 
    AND motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial')
    AND cta_contrato IS NOT null --and left(data_criacao,7) = B.anomes_m1
  GROUP BY 1
  HAVING Rec_diversas >= 3
  union all
  SELECT cta_contrato, COUNT(DISTINCT submotivo) as Rec_diversas
  FROM bi_brce_act.bt_brce_requestqlik A
  left join _variables B on B.anomes = left(data_criacao,7)
  WHERE tipo_caso = 'Reclamação'
    AND dataingresso >= CURRENT_DATE - INTERVAL '6' MONTH AND expurgado = 'false' 
    AND motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial')
    AND cta_contrato IS NOT null --and left(data_criacao,7) = B.anomes_m1
  GROUP BY 1
  HAVING Rec_diversas >= 3
);

DROP TABLE IF EXISTS inf_repetidas;

CREATE TEMPORARY TABLE inf_repetidas AS (
  SELECT cta_contrato, COUNT(DISTINCT submotivo) as inf_repetidas
  FROM bi_brrj_act.bt_brrj_requestqlik A
  left join _variables B on B.anomes = left(data_criacao,7)
  WHERE tipo_caso = 'Informação'
    AND dataingresso >= CURRENT_DATE - INTERVAL '30' DAY AND expurgado = 'false' 
    AND motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial')
    and submotivo not in ('ATBR005-DEBITO')
    AND cta_contrato IS NOT null --and left(data_criacao,7) = B.anomes_m1
  GROUP BY 1
  HAVING inf_repetidas >= 3
  union all 
  SELECT cta_contrato, COUNT(DISTINCT submotivo) as inf_repetidas
  FROM bi_brce_act.bt_brce_requestqlik A
  left join _variables B on B.anomes = left(data_criacao,7)
  WHERE tipo_caso = 'Informação'
    AND dataingresso >= CURRENT_DATE - INTERVAL '30' DAY AND expurgado = 'false' 
    AND motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial')
    and submotivo not in ('ATBR005-DEBITO')
    AND cta_contrato IS NOT null --and left(data_criacao,7) = B.anomes_m1
  GROUP BY 1
  HAVING inf_repetidas >= 3
);

DROP TABLE IF EXISTS N3;

CREATE TEMPORARY TABLE N3 AS (
  SELECT cta_contrato, COUNT(DISTINCT submotivo) as Aneel
  FROM bi_brrj_act.bt_brrj_requestqlik A
  left join _variables B on B.anomes = left(data_criacao,7)
  WHERE dataingresso >= CURRENT_DATE - INTERVAL '13' MONTH AND expurgado = 'false' 
    AND canal_caso LIKE '%ANEEL%'
    AND motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial')
    AND cta_contrato IS NOT null --and left(data_criacao,7) = B.anomes_m1
  GROUP BY 1
  union all 
  SELECT cta_contrato, COUNT(DISTINCT submotivo) as Aneel
  FROM bi_brce_act.bt_brce_requestqlik A
  left join _variables B on B.anomes = left(data_criacao,7)
  WHERE dataingresso >= CURRENT_DATE - INTERVAL '13' MONTH AND expurgado = 'false' 
    AND canal_caso LIKE '%ANEEL%'
    AND motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial')
    AND cta_contrato IS NOT null --and left(data_criacao,7) = B.anomes_m1
  GROUP BY 1
);

DROP TABLE IF EXISTS Judicial;

CREATE TEMPORARY table Judicial AS (
  SELECT cta_contrato, COUNT(DISTINCT submotivo) as Judicial
  FROM bi_brrj_act.bt_brrj_requestqlik A
  left join _variables B on B.anomes = left(data_criacao,7)
  WHERE dataingresso >= CURRENT_DATE - INTERVAL '13' MONTH AND expurgado = 'false' 
    AND canal_caso in ('19-JUDICIAL',
'36-JURIDICO - PROCESSO JUDICIAL',
'34-JUDICIAL')
    AND motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial')
    AND cta_contrato IS NOT null --and left(data_criacao,7) = B.anomes_m1
  GROUP BY 1
  union all 
   SELECT cta_contrato, COUNT(DISTINCT submotivo) as Judicial
  FROM bi_brce_act.bt_brce_requestqlik A
  left join _variables B on B.anomes = left(data_criacao,7)
  WHERE dataingresso >= CURRENT_DATE - INTERVAL '13' MONTH AND expurgado = 'false' 
    AND canal_caso in ('19-JUDICIAL',
'36-JURIDICO - PROCESSO JUDICIAL',
'34-JUDICIAL')
    AND motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial')
    AND cta_contrato IS NOT null --and left(data_criacao,7) = B.anomes_m1
  GROUP BY 1
);

DROP TABLE IF EXISTS OUVIDORIA;

CREATE TEMPORARY TABLE OUVIDORIA AS (
  SELECT cta_contrato, COUNT(DISTINCT submotivo) as QTD_OUVIDORIA
  FROM bi_brrj_act.bt_brrj_requestqlik A
  left join _variables B on B.anomes = left(data_criacao,7)
  WHERE dataingresso >= CURRENT_DATE - INTERVAL '13' MONTH AND expurgado = 'false'
    and canal_caso in ('113-OUV ORGAO DEFESA - PROCON CIP',
'29-OUVIDORIA - AREA INTERNA',
'110-OUVIDORIA - CONSELHO CONSUMIDOR',
'116-OUV ORGAO DEFESA - PROCON INTIMACAO',
'112-OUV ORGAO DEFESA - PROCON ASSEMBLEIA',
'109-OUVIDORIA - MME',
'21-OUVIDORIA',
'22-OUVIDORIA - CALL CENTER',
'115-OUV ORGAO DEFESA - PROCON EMAIL',
'33-OUV ORGAO DEFESA - DECON/CODECON PRESENCIAL',
'118-OUV ORGAO DEFESA - PROCON NOTIFICACAO',
'26-OUVIDORIA - EMAIL',
'114-OUV ORGAO DEFESA - PROCON CIP ELETRONICA',
'30-OUV ORGAO DEFESA - DECON/CODECON TEL',
'119-OUV ORGAO DEFESA - PROCON PROCESSO ADM',
'107-OUVIDORIA - CONSUMIDOR GOV',
'28-OUVIDORIA - PRESENCIAL',
'111-OUVIDORIA - IMPRENSA',
'32-OUV ORGAO DEFESA - DECON/CODECON CIP ELETRONICA',
'31-OUV ORGAO DEFESA - DECON/CODECON CIP',
'120-OUV ORGAO DEFESA - PROCON TEL',
'106-OUVIDORIA - ORGAO DEFESA',
'27-OUVIDORIA - CARTA/OFICIO',
'25-OUVIDORIA - VOCE E O PRESIDENTE',
'117-OUV ORGAO DEFESA - PROCON MULTA')
    AND motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial')
    AND cta_contrato IS NOT null --and left(data_criacao,7) = B.anomes_m1
  GROUP BY 1
  HAVING QTD_OUVIDORIA >= 2
  union all 
   SELECT cta_contrato, COUNT(DISTINCT submotivo) as QTD_OUVIDORIA
  FROM bi_brce_act.bt_brce_requestqlik A
  left join _variables B on B.anomes = left(data_criacao,7)
  WHERE dataingresso >= CURRENT_DATE - INTERVAL '13' MONTH AND expurgado = 'false'
    and canal_caso in ('113-OUV ORGAO DEFESA - PROCON CIP',
'29-OUVIDORIA - AREA INTERNA',
'110-OUVIDORIA - CONSELHO CONSUMIDOR',
'116-OUV ORGAO DEFESA - PROCON INTIMACAO',
'112-OUV ORGAO DEFESA - PROCON ASSEMBLEIA',
'109-OUVIDORIA - MME',
'21-OUVIDORIA',
'22-OUVIDORIA - CALL CENTER',
'115-OUV ORGAO DEFESA - PROCON EMAIL',
'33-OUV ORGAO DEFESA - DECON/CODECON PRESENCIAL',
'118-OUV ORGAO DEFESA - PROCON NOTIFICACAO',
'26-OUVIDORIA - EMAIL',
'114-OUV ORGAO DEFESA - PROCON CIP ELETRONICA',
'30-OUV ORGAO DEFESA - DECON/CODECON TEL',
'119-OUV ORGAO DEFESA - PROCON PROCESSO ADM',
'107-OUVIDORIA - CONSUMIDOR GOV',
'28-OUVIDORIA - PRESENCIAL',
'111-OUVIDORIA - IMPRENSA',
'32-OUV ORGAO DEFESA - DECON/CODECON CIP ELETRONICA',
'31-OUV ORGAO DEFESA - DECON/CODECON CIP',
'120-OUV ORGAO DEFESA - PROCON TEL',
'106-OUVIDORIA - ORGAO DEFESA',
'27-OUVIDORIA - CARTA/OFICIO',
'25-OUVIDORIA - VOCE E O PRESIDENTE',
'117-OUV ORGAO DEFESA - PROCON MULTA')
    AND motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial')
    AND cta_contrato IS NOT null --and left(data_criacao,7) = B.anomes_m1
  GROUP BY 1
  HAVING QTD_OUVIDORIA >= 2
);

DROP TABLE IF EXISTS CRITICOS;

CREATE TEMPORARY TABLE CRITICOS AS (
SELECT DISTINCT
    A.cta_contrato,
    A.ano,
    A.mes,
    A.tipo_caso,
    A.motivo,
    A.submotivo,
    A.numero_caso,
    A.data_criacao,
    numero_da_ordem_ou_atividade as Ordem,
    A.status,
    CASE WHEN B.cta_contrato IS NOT NULL THEN 1 ELSE 0 END AS Rec_iguais,
    CASE WHEN C.cta_contrato IS NOT NULL THEN 1 ELSE 0 END AS Rec_diversas,
    CASE WHEN D.cta_contrato IS NOT NULL THEN 1 ELSE 0 END AS inf_repetidas,
    CASE WHEN F.cta_contrato IS NOT NULL THEN 1 ELSE 0 END AS Ouvidoria,
    CASE WHEN G.cta_contrato IS NOT NULL THEN 1 ELSE 0 END AS Judicial,
    CASE WHEN E.cta_contrato IS NOT NULL THEN 1 ELSE 0 END AS Aneel,
    CASE
        WHEN Rec_iguais <> 0 THEN true
        WHEN rec_diversas <> 0 THEN true
        WHEN inf_repetidas <> 0 THEN true
        WHEN aneel <> 0 THEN true
        WHEN Ouvidoria <> 0 THEN true
        WHEN Judicial <> 0 THEN true
        ELSE false
    END AS Flag_critico,
    CASE WHEN rec_iguais <> 0 THEN 15 ELSE 0 END AS peso_rec_iguais,
    CASE WHEN rec_diversas <> 0 THEN 15 ELSE 0 END AS peso_rec_diversas,
    CASE WHEN inf_repetidas <> 0 THEN 10 ELSE 0 END AS peso_inf_repetidas,
    CASE WHEN ouvidoria <> 0 THEN 20 ELSE 0 END AS peso_ouvidoria,
    CASE WHEN judicial <> 0 THEN 20 ELSE 0 END AS peso_judicial,
    CASE WHEN aneel <> 0 THEN 20 ELSE 0 END AS peso_aneel,
    CAST(peso_rec_iguais AS int) + CAST(peso_rec_diversas AS int) + CAST(peso_inf_repetidas AS int) + CAST(peso_ouvidoria AS int) + CAST(peso_judicial AS int) + CAST(peso_aneel AS int) AS Nota_F,
    CASE
        WHEN nota_F < 15 THEN 'Verde'
        WHEN Nota_f = 15 AND CAST(peso_rec_iguais AS int) = 15 THEN 'Laranja'
        WHEN Nota_f = 15 AND CAST(peso_rec_diversas AS int) = 15 THEN 'Amarelo'
        WHEN Nota_F = 20 AND CAST(peso_judicial AS int) = 0 AND peso_aneel = 0 THEN 'Amarelo'
        WHEN Nota_F BETWEEN 20 AND 31 AND CAST(peso_judicial AS int) = 0 AND CAST(peso_aneel AS int) = 0 THEN 'Laranja'
        WHEN Nota_F BETWEEN 20 AND 31 AND CAST(peso_ouvidoria AS int) = 0 THEN 'Vermelho'
        WHEN nota_F = 20 AND CAST(peso_ouvidoria AS int) = 0 THEN 'Laranja'
        WHEN nota_f = 25 AND CAST(rec_iguais AS int) >= 0 THEN 'Laranja'
        WHEN nota_F = 35 THEN 'Laranja'
        WHEN nota_f = 20 AND CAST(peso_ouvidoria AS int) = 0 THEN 'Vermelho'
        WHEN nota_f >= 60 THEN 'Vermelho III'
        WHEN nota_f >= 50 THEN 'Vermelho II'
        WHEN nota_f > 35 THEN 'Vermelho'
    END AS Cluster
FROM
    bi_brrj_act.bt_brrj_requestqlik A
LEFT JOIN
    Rec_iguais B ON B.cta_contrato = A.cta_contrato
LEFT JOIN
    Rec_diversas C ON C.cta_contrato = A.cta_contrato
LEFT JOIN
    inf_repetidas D ON D.cta_contrato = A.cta_contrato
LEFT JOIN
    N3 E ON E.cta_contrato = A.cta_contrato
LEFT JOIN
    OUVIDORIA F ON F.cta_contrato = A.cta_contrato
LEFT JOIN
    JUDICIAL G ON G.CTA_CONTRATO = A.CTA_CONTRATO
LEFT JOIN
    _variables H ON left(H.anomes,4) = A.ano
WHERE
    A.motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial')
    AND LEFT(A.data_criacao, 7) >= '2024-00'
    AND A.tipocanal IN ('Humano')
    AND flag_critico = 'true'
    AND tipo_caso IN ('Solicitação', 'Reclamação', 'RSME')
    AND Ordem IS NOT null
   union all
  SELECT DISTINCT
    A.cta_contrato,
    A.ano,
    A.mes,
    A.tipo_caso,
    A.motivo,
    A.submotivo,
    A.numero_caso,
    A.data_criacao,
    numero_da_ordem_ou_atividade as Ordem,
    A.status,
    CASE WHEN B.cta_contrato IS NOT NULL THEN 1 ELSE 0 END AS Rec_iguais,
    CASE WHEN C.cta_contrato IS NOT NULL THEN 1 ELSE 0 END AS Rec_diversas,
    CASE WHEN D.cta_contrato IS NOT NULL THEN 1 ELSE 0 END AS inf_repetidas,
    CASE WHEN F.cta_contrato IS NOT NULL THEN 1 ELSE 0 END AS Ouvidoria,
    CASE WHEN G.cta_contrato IS NOT NULL THEN 1 ELSE 0 END AS Judicial,
    CASE WHEN E.cta_contrato IS NOT NULL THEN 1 ELSE 0 END AS Aneel,
    CASE
        WHEN Rec_iguais <> 0 THEN true
        WHEN rec_diversas <> 0 THEN true
        WHEN inf_repetidas <> 0 THEN true
        WHEN aneel <> 0 THEN true
        WHEN Ouvidoria <> 0 THEN true
        WHEN Judicial <> 0 THEN true
        ELSE false
    END AS Flag_critico,
    CASE WHEN rec_iguais <> 0 THEN 15 ELSE 0 END AS peso_rec_iguais,
    CASE WHEN rec_diversas <> 0 THEN 15 ELSE 0 END AS peso_rec_diversas,
    CASE WHEN inf_repetidas <> 0 THEN 10 ELSE 0 END AS peso_inf_repetidas,
    CASE WHEN ouvidoria <> 0 THEN 20 ELSE 0 END AS peso_ouvidoria,
    CASE WHEN judicial <> 0 THEN 20 ELSE 0 END AS peso_judicial,
    CASE WHEN aneel <> 0 THEN 20 ELSE 0 END AS peso_aneel,
    CAST(peso_rec_iguais AS int) + CAST(peso_rec_diversas AS int) + CAST(peso_inf_repetidas AS int) + CAST(peso_ouvidoria AS int) + CAST(peso_judicial AS int) + CAST(peso_aneel AS int) AS Nota_F,
    CASE
        WHEN nota_F < 15 THEN 'Verde'
        WHEN Nota_f = 15 AND CAST(peso_rec_iguais AS int) = 15 THEN 'Laranja'
        WHEN Nota_f = 15 AND CAST(peso_rec_diversas AS int) = 15 THEN 'Amarelo'
        WHEN Nota_F = 20 AND CAST(peso_judicial AS int) = 0 AND peso_aneel = 0 THEN 'Amarelo'
        WHEN Nota_F BETWEEN 20 AND 31 AND CAST(peso_judicial AS int) = 0 AND CAST(peso_aneel AS int) = 0 THEN 'Laranja'
        WHEN Nota_F BETWEEN 20 AND 31 AND CAST(peso_ouvidoria AS int) = 0 THEN 'Vermelho'
        WHEN nota_F = 20 AND CAST(peso_ouvidoria AS int) = 0 THEN 'Laranja'
        WHEN nota_f = 25 AND CAST(rec_iguais AS int) >= 0 THEN 'Laranja'
        WHEN nota_F = 35 THEN 'Laranja'
        WHEN nota_f = 20 AND CAST(peso_ouvidoria AS int) = 0 THEN 'Vermelho'
        WHEN nota_f >= 60 THEN 'Vermelho III'
        WHEN nota_f >= 50 THEN 'Vermelho II'
        WHEN nota_f > 35 THEN 'Vermelho'
    END AS Cluster
FROM
    bi_brce_act.bt_brce_requestqlik A
LEFT JOIN
    Rec_iguais B ON B.cta_contrato = A.cta_contrato
LEFT JOIN
    Rec_diversas C ON C.cta_contrato = A.cta_contrato
LEFT JOIN
    inf_repetidas D ON D.cta_contrato = A.cta_contrato
LEFT JOIN
    N3 E ON E.cta_contrato = A.cta_contrato
LEFT JOIN
    OUVIDORIA F ON F.cta_contrato = A.cta_contrato
LEFT JOIN
    JUDICIAL G ON G.CTA_CONTRATO = A.CTA_CONTRATO
LEFT JOIN
    _variables H ON left(H.anomes,4) = A.ano
WHERE
    A.motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial')
    AND LEFT(A.data_criacao, 7) >= '2024-00'
    AND A.tipocanal IN ('Humano')
    AND flag_critico = 'true'
    AND tipo_caso IN ('Solicitação', 'Reclamação', 'RSME')
    AND Ordem IS NOT null);

   
   
DROP TABLE IF EXISTS ORDENS;

CREATE TEMPORARY TABLE ORDENS as (
select distinct
'RJ' as Distribuidora
,'Grupo B' as Grupo
,cluster as cluster_Cliente
,a.anomes
,A.numero_ordem
,case
    when trim(A.numero_ordem_relac) ='' then  '-'
    when trim(A.numero_ordem_relac) =' ' then  '-'
    else A.numero_ordem_relac end as numero_ordem_relac
,D.cluster_ordem
,case when numero_cliente isnull then 0
else numero_cliente end as Numero_cliente
,nro_caso as numero_caso
,V.motivo
,case When V.tipo_caso = 'RSME' Then 'Reclamação' else V.Tipo_caso end as Tipo_caso
,A.Tipo_Ordem
,A.cod_servico
,A.des_servico
,cod_etapa
,descricao_etapa
,cod_retorno
,descricao_retorno
,D.AREA_RESPONSAVEL
,D.Responsavel
,negocio
,D.regulada
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
,upper(left(rol_ingresso,12)) as rol_ingresso
,upper(left(rol_visita,12)) as rol_visita
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
,CASE 
    WHEN A.numero_cliente = '0' THEN NULL
    ELSE G.municipality__c
END AS municipio
,ind_serv_executado
,ind_encerra_ordem
,ind_def_tec_client
,ind_def_tec_empres
,ind_pendencia
,ind_efeito_tempo
,ind_movimenta_med
,ind_procedente
,Rec_iguais
,Rec_diversas
,inf_repetidas
,Ouvidoria
,Judicial
,Aneel
,peso_rec_iguais
,peso_rec_diversas
,peso_inf_repetidas
,peso_ouvidoria
,peso_judicial
,peso_aneel
,Nota_F
,last_update
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
left join bi_brrj_cus.bt_brrj_relatorio_de_cadastro G on G.accountcontract__c = A.numero_cliente
INNER join CRITICOS H on H.NUMERO_CASO = NRO_CASO
left join bi_brrj_act.bt_brrj_requestqlik V on V.NUMERO_CASO = NRO_CASO
where ultima_etapa = true and CLUSTER_ORDEM = 'INICIATIVA CLIENTE' and Status_ordem = 'ABERTA' and a.des_servico not like '%OUV%' and canal_caso not in ('19-JUDICIAL',
'36-JURIDICO - PROCESSO JUDICIAL',
'34-JUDICIAL')
union all 
select distinct
'RJ' as Distribuidora
,'Grupo A' as Grupo
,cluster as cluster_Cliente
,a.anomes
,A.numero_ordem
,case
    when trim(A.numero_ordem_relac) ='' then  '-'
    when trim(A.numero_ordem_relac) =' ' then  '-'
    else A.numero_ordem_relac end as numero_ordem_relac
,D.cluster_ordem
,case when numero_cliente isnull then 0
else numero_cliente end as Numero_cliente
,nro_caso as numero_caso
,V.motivo
,case When V.tipo_caso = 'RSME' Then 'Reclamação' else V.Tipo_caso end as Tipo_caso
,A.Tipo_Ordem
,A.cod_servico
,A.des_servico
,cod_etapa
,descricao_etapa
,cod_retorno
,descricao_retorno
,D.AREA_RESPONSAVEL
,D.Responsavel
,negocio
,D.regulada
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
,upper(left(rol_ingresso,12)) as rol_ingresso
,upper(left(rol_visita,12)) as rol_visita
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
,CASE 
    WHEN A.numero_cliente = '0' THEN NULL
    ELSE G.municipality__c
END AS municipio
,ind_serv_executado
,ind_encerra_ordem
,ind_def_tec_client
,ind_def_tec_empres
,ind_pendencia
,ind_efeito_tempo
,ind_movimenta_med
,ind_procedente
,Rec_iguais
,Rec_diversas
,inf_repetidas
,Ouvidoria
,Judicial
,Aneel
,peso_rec_iguais
,peso_rec_diversas
,peso_inf_repetidas
,peso_ouvidoria
,peso_judicial
,peso_aneel
,nota_f
,last_update
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
left join bi_brrj_cus.bt_brrj_relatorio_de_cadastro G on G.accountcontract__c = A.numero_cliente
INNER join CRITICOS H on H.NUMERO_CASO = NRO_CASO
left join bi_brrj_act.bt_brrj_requestqlik V on V.NUMERO_CASO = NRO_CASO
where ultima_etapa = true and CLUSTER_ORDEM = 'INICIATIVA CLIENTE' and Status_ordem = 'ABERTA' and a.des_servico not like '%OUV%' and canal_caso not in ('19-JUDICIAL',
'36-JURIDICO - PROCESSO JUDICIAL',
'34-JUDICIAL')
union all
select distinct
'CE' as Distribuidora
,'Grupo B' as Grupo
,cluster as cluster_Cliente
,a.anomes
,A.numero_ordem
,case
    when trim(A.numero_ordem_relac) ='' then  '-'
    when trim(A.numero_ordem_relac) =' ' then  '-'
    else A.numero_ordem_relac end as numero_ordem_relac
,D.cluster_ordem
,case when numero_cliente isnull then 0
else numero_cliente end as Numero_cliente
,nro_caso as numero_caso
,V.motivo
,case When V.tipo_caso = 'RSME' Then 'Reclamação' else V.Tipo_caso end as Tipo_caso
,A.Tipo_Ordem
,A.cod_servico
,A.des_servico
,cod_etapa
,descricao_etapa
,cod_retorno
,descricao_retorno
,D.AREA_RESPONSAVEL
,D.Responsavel
,diretoria as negocio
,case when D.escopo = 'REGULADA' then 'Sim' else 'Não' end as regulada
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
,upper(left(rol_ingresso,12)) as rol_ingresso
,upper(left(rol_visita,12)) as rol_visita
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
,CASE 
    WHEN A.numero_cliente = '0' THEN NULL
    ELSE G.municipio
END AS municipio
,ind_serv_executado
,ind_encerra_ordem
,ind_def_tec_client
,ind_def_tec_empres
,ind_pendencia
,ind_efeito_tempo
,ind_movimenta_med
,ind_procedente
,Rec_iguais
,Rec_diversas
,inf_repetidas
,Ouvidoria
,Judicial
,Aneel
,peso_rec_iguais
,peso_rec_diversas
,peso_inf_repetidas
,peso_ouvidoria
,peso_judicial
,peso_aneel
,Nota_F
,last_update
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
	from Bi_brce_cus.bt_brce_clientes_ordem_servico
	) A
left join DP_BRRJ.TB_AUX_DEPARA_ESTADO_ORDENS C on C.ESTADO = A.ESTADO
left join dp_brce_cus.tb_aux_depara_ce_tipo_servicos_totais_v2 D on D.CHAVE = 'BT'||A.tipo_ordem||A.cod_servico||RTRIM(A.des_servico)
left join (select numero_ordem, data_estado, numero_ordem_relac, case when data_exec_visita <> '' then data_exec_visita else null end as data_exec_visita, hora_exec_visita, 
B.DESCRICAO as DESCRICAO_ORDEM, B.status_ordem as STATUS_DA_ORDEM, B.ESTADO as ESTADO_DA_ORDEM from Bi_brce_cus.bt_brce_clientes_ordem_servico A
left join DP_BRRJ.TB_AUX_DEPARA_ESTADO_ORDENS B on B.ESTADO = A.ESTADO) E on E.NUMERO_ORDEM = A.numero_ordem_relac
left join dp_brce_cus.e2e_base_clientes_b2bg G on cast(G.ponto_fornecimento as int) = A.numero_cliente
INNER join CRITICOS H on H.NUMERO_CASO = NRO_CASO
left join bi_brce_act.bt_brce_requestqlik V on V.NUMERO_CASO = NRO_CASO
where ultima_etapa = true and CLUSTER_ORDEM = 'CLIENTE' and Status_ordem = 'ABERTA' and a.des_servico not like '%OUV%' and canal_caso not in ('19-JUDICIAL',
'36-JURIDICO - PROCESSO JUDICIAL',
'34-JUDICIAL')
union all 
select distinct
'CE' as Distribuidora
,'Grupo A' as Grupo
,cluster as cluster_Cliente
,a.anomes
,A.numero_ordem
,case
    when trim(A.numero_ordem_relac) ='' then  '-'
    when trim(A.numero_ordem_relac) =' ' then  '-'
    else A.numero_ordem_relac end as numero_ordem_relac
,D.cluster_ordem
,case when numero_cliente isnull then 0
else numero_cliente end as Numero_cliente
,nro_caso as numero_caso
,V.motivo
,case When V.tipo_caso = 'RSME' Then 'Reclamação' else V.Tipo_caso end as Tipo_caso
,A.Tipo_Ordem
,A.cod_servico
,A.des_servico
,cod_etapa
,descricao_etapa
,cod_retorno
,descricao_retorno
,D.AREA_RESPONSAVEL
,D.Responsavel
,diretoria as negocio
,case when D.escopo = 'REGULADA' then 'Sim' else 'Não' end as regulada
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
,upper(left(rol_ingresso,12)) as rol_ingresso
,upper(left(rol_visita,12)) as rol_visita
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
,CASE 
    WHEN A.numero_cliente = '0' THEN NULL
    ELSE G.municipio
END AS municipio
,ind_serv_executado
,ind_encerra_ordem
,ind_def_tec_client
,ind_def_tec_empres
,ind_pendencia
,ind_efeito_tempo
,ind_movimenta_med
,ind_procedente
,Rec_iguais
,Rec_diversas
,inf_repetidas
,Ouvidoria
,Judicial
,Aneel
,peso_rec_iguais
,peso_rec_diversas
,peso_inf_repetidas
,peso_ouvidoria
,peso_judicial
,peso_aneel
,nota_f
,last_update
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
	from Bi_brce_cus.bt_brce_grandes_ordem_servico
	) A
left join DP_BRRJ.TB_AUX_DEPARA_ESTADO_ORDENS C on C.ESTADO = A.ESTADO
left join dp_brce_cus.tb_aux_depara_ce_tipo_servicos_totais_v2 D on D.CHAVE = 'AT'||A.tipo_ordem||A.cod_servico||RTRIM(A.des_servico)
left join (select numero_ordem, data_estado, numero_ordem_relac, case when data_exec_visita <> '' then data_exec_visita else null end as data_exec_visita, hora_exec_visita, 
B.DESCRICAO as DESCRICAO_ORDEM, B.status_ordem as STATUS_DA_ORDEM, B.ESTADO as ESTADO_DA_ORDEM from Bi_brce_cus.bt_brce_grandes_ordem_servico A
left join DP_BRRJ.TB_AUX_DEPARA_ESTADO_ORDENS B on B.ESTADO = A.ESTADO) E on E.NUMERO_ORDEM = A.numero_ordem_relac
left join dp_brce_cus.e2e_base_clientes_b2bg G on cast(G.ponto_fornecimento as int) = A.numero_cliente
INNER join CRITICOS H on H.NUMERO_CASO = NRO_CASO
left join bi_brce_act.bt_brce_requestqlik V on V.NUMERO_CASO = NRO_CASO
where ultima_etapa = true and cluster_ordem = 'CLIENTE' and status_ordem = 'ABERTA' and a.des_servico not like '%OUV%' and canal_caso not in ('19-JUDICIAL',
'36-JURIDICO - PROCESSO JUDICIAL',
'34-JUDICIAL'));


-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS RECONTATO;

CREATE TEMPORARY TABLE RECONTATO AS (
    WITH ordens_com_proxima AS (
        SELECT 
            B.numero_cliente,
            B.data_abertura,
            B.motivo,
            LEAD(B.data_abertura) OVER (PARTITION BY B.numero_cliente ORDER BY B.data_abertura) AS proxima_data_abertura
        FROM 
            ORDENS B
    )
    
    -- Primeiro SELECT da tabela bt_brrj_requestqlik
    SELECT 
        B.numero_cliente AS clienteqlik,
        A.motivo AS motivo_contato,
        COUNT(*) AS quantidade_contatos,             
        B.data_abertura AS data_ordem_atual,
        B.motivo AS motivo_ordem,
        MIN(A.data_criacao) AS primeiro_contato,     
        MAX(A.data_criacao) AS ultimo_contato        
    FROM 
        bi_brrj_act.bt_brrj_requestqlik A              
    JOIN 
        ordens_com_proxima B ON B.numero_cliente = A.cta_contrato  
    WHERE 
        A.data_criacao > B.data_abertura -- Somente contatos após a abertura da ordem atual
        AND (B.proxima_data_abertura IS NULL OR A.data_criacao < B.proxima_data_abertura) -- Limitar até a próxima ordem
        AND A.expurgado = 'false'                      
        AND A.motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial') 
        AND A.submotivo NOT IN ('ATBR021-SEG VIA')     
        AND A.cta_contrato <> '0'                      
        AND B.motivo = A.motivo                        
        AND A.ano >= '2024'                             
    GROUP BY 
        B.numero_cliente, A.motivo, B.data_abertura, B.motivo                
    
    UNION ALL
    
    -- Segundo SELECT da tabela bt_brce_requestqlik
    SELECT 
        B.numero_cliente AS clienteqlik,
        A.motivo AS motivo_contato,
        COUNT(*) AS quantidade_contatos,             
        B.data_abertura AS data_ordem_atual,
        B.motivo AS motivo_ordem,
        MIN(A.data_criacao) AS primeiro_contato,     
        MAX(A.data_criacao) AS ultimo_contato        
    FROM 
        bi_brce_act.bt_brce_requestqlik A              
    JOIN 
        ordens_com_proxima B ON B.numero_cliente = A.cta_contrato  
    WHERE
        A.data_criacao > B.data_abertura -- Somente contatos após a abertura da ordem atual
        AND (B.proxima_data_abertura IS NULL OR A.data_criacao < B.proxima_data_abertura) -- Limitar até a próxima ordem
        AND A.expurgado = 'false'                      
        AND A.motivo NOT IN ('MOT001-Sol Registro Aviso Emergencial') 
        AND A.submotivo NOT IN ('ATBR021-SEG VIA')     
        AND A.cta_contrato NOT IN ('0', '9011870', '9011890')                     
        AND B.motivo = A.motivo                        
        AND A.ano >= '2024'                  
    GROUP BY 
        B.numero_cliente, A.motivo, B.data_abertura, B.motivo
);
  
   
SELECT 
    A.*,  
    COALESCE(B.quantidade_contatos, 0) AS qtd_recontatos 
FROM 
    ORDENS A
LEFT JOIN 
    RECONTATO B 
ON 
    A.numero_cliente = B.clienteqlik
    AND A.motivo = B.motivo_ordem 
    AND A.data_abertura = B.data_ordem_atual;