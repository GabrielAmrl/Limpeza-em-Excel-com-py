import os
import redshift_connector
import pandas as pd

# Configurações de caminhos
PASTA_DESTINO = r"C:\Users\363078\OneDrive - NEOBPO\Área de Trabalho\Dowloand Query"
ARQUIVO_FINAL = os.path.join(PASTA_DESTINO, "resultado_query_uf.csv")

def conectar():
    print("Iniciando conexão com o Amazon Redshift...")
    return redshift_connector.connect(
        host='latam-ap35552-prod-rshift-00-biba-58jpjcv7kr96.cu7jkfaatmsm.eu-central-1.redshift.amazonaws.com',
        database='dredprodbiba',
        port=5439,
        ssl=True,
        iam=True,
        cluster_identifier='latam-ap35552-prod-rshift-00-biba-58jpjcv7kr96',
        credentials_provider='BrowserAzureOAuth2CredentialsProvider',
        idp_tenant='d539d4bf-5610-471a-afc2-1c76685cfefa',
        client_id='dc48ea68-3244-425d-b34e-f2a5cdabd3e8',
        listen_port=7890,
        idp_response_timeout=50,
        scope='api://enel.com/bb52aafd-bf62-4722-9757-db5350d0ab8d/.default'
    )

# Query otimizada (Ajustada a tipagem de ano/mes para o Redshift performar melhor)
# DICA: Substitua o '*' pelas colunas específicas que você realmente usa.
QUERY_OTIMIZADA = """
-- RJ
SELECT *, 'RJ' AS uf
FROM bi_brrj_act.bt_brrj_requestqlik 
WHERE ano = '2026'
  AND mes IN ('6', '06')
  AND br_atendente IN (
    'BR0093587885','BR0103278235','BR0103096365','BR0095257565','BR0865324085',
    'BR0066783455','BR0125005145','BR0866466815','BR0066669675','BR0101043985',
    'BR0111954975','BR0868471015','BR0830453415','BR0081454535','BR0860392225',
    'BR0103419815','BR0077797415','BR0867256275','BR0858082925','BR0104122865',
    'BR0054488945','BR0067198575','BR0104869855','BR0035750135','BR0020800145',
    'BR0107062525'
  )

UNION ALL

-- CE
SELECT *, 'CE' AS uf
FROM bi_brce_act.bt_brce_requestqlik 
WHERE ano = '2026'
  AND mes IN ('6', '06')
  AND br_atendente IN (
    'BR0093587885','BR0103278235','BR0103096365','BR0095257565','BR0865324085',
    'BR0066783455','BR0125005145','BR0866466815','BR0066669675','BR0101043985',
    'BR0111954975','BR0868471015','BR0830453415','BR0081454535','BR0860392225',
    'BR0103419815','BR0077797415','BR0867256275','BR0858082925','BR0104122865',
    'BR0054488945','BR0067198575','BR0104869855','BR0035750135','BR0020800145',
    'BR0107062525'
  )

UNION ALL

-- SP
SELECT *, 'SP' AS uf
FROM bi_brsp_act.bt_brsp_requestqlik 
WHERE ano = '2026'
  AND mes IN ('6', '06')
  AND br_atendente IN (
    'BR0862208175','BR0076463765','BR0095333255','BR0868434205','BR0859315295',
    'BR0863487865','BR0032233075','BR0067296125','BR0862343025','BR0884350595',
    'BR0045064705','BR0046470725','BR0629051125','BR0782124485','BR0862295875',
    'BR0793249245','BR0865810505','BR0869401525','BR0858014925','BR0117276665',
    'BR0835103545','BR0866271565','BR0864238175','BR0084283425'
  )
"""

def executar_download():
    # Garante que a pasta de destino exista
    if not os.path.exists(PASTA_DESTINO):
        os.makedirs(PASTA_DESTINO)
        print(f"Pasta criada: {PASTA_DESTINO}")

    conn = None
    try:
        conn = conectar()
        print("Conectado com sucesso! Executando query e baixando dados...")
        
        # O pandas lê o cursor do redshift de forma integrada e otimizada
        df = pd.read_sql_query(QUERY_OTIMIZADA, conn)
        
        print(f"Query concluída. Total de linhas retornadas: {len(df)}")
        print(f"Salvando arquivo em: {ARQUIVO_FINAL}")
        
        # Salva em CSV usando encoding ideal para Excel (utf-8-sig) e sem o índice do pandas
        df.to_csv(ARQUIVO_FINAL, index=False, encoding='utf-8-sig', sep=';')
        
        print("Processo concluído com sucesso!")
        
    except Exception as e:
        print(f"Ocorreu um erro durante o processo: {e}")
        
    finally:
        if conn:
            conn.close()
            print("Conexão com o Redshift encerrada.")

if __name__ == "__main__":
    executar_download()