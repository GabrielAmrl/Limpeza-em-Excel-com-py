import redshift_connector
import csv

def conectar():
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

query = """
SELECT 
  'SP' AS uf,
  interacao,
  numero_caso,
  tipo_caso,
  motivo,
  submotivo,
  numero_ponto_de_fornecimento,
  municipio,
  dataingresso,
  ano,
  mes,
  dia
FROM bi_brsp_act.bt_brsp_requestqlik
WHERE ano = '2026' AND mes = '05' AND dia >= '14'
  AND canal_oficial = 'Call Center'
UNION ALL
SELECT 
  'SP' AS uf,
  interacao,
  numero_caso,
  tipo_caso,
  motivo,
  submotivo,
  numero_ponto_de_fornecimento,
  municipio,
  dataingresso,
  ano,
  mes,
  dia
FROM bi_brsp_act.bt_brsp_requestqlik
WHERE ano = '2026' AND mes = '06' AND dia <= '14'
  AND canal_oficial = 'Call Center'
"""

print("[1/3] Conectando ao banco... (aguarde o login no navegador)")
conn = conectar()
print("[1/3] Conectado com sucesso!")

print("[2/3] Executando query SP... (isso pode demorar alguns minutos)")
with conn.cursor() as cur:
    cur.execute(query)
    print("[2/3] Query executada! Salvando dados no CSV...")

    with open('sp_dados.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow([desc[0] for desc in cur.description])

        total = 0
        for row in cur:
            writer.writerow(row)
            total += 1
            if total % 10000 == 0:
                print(f"    -> {total:,} linhas salvas...")

print(f"[3/3] Exportado com sucesso! {total:,} linhas salvas em 'sp_dados.csv'")

conn.close()