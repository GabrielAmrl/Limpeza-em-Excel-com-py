import webbrowser
import redshift_connector
import time

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

def query(sql, conn, tentativas=3):
    for i in range(tentativas):
        try:
            cursor = conn.cursor()
            cursor.execute(sql)
            return cursor, conn
        except Exception:
            print(f"⚠️ Conexão perdida, reconectando... (tentativa {i+1}/{tentativas})")
            try:
                conn = conectar()
                print("✅ Reconectado!")
            except Exception as e:
                print(f"❌ Falha ao reconectar: {e}")
                time.sleep(3)
    raise Exception("❌ Não foi possível reconectar após várias tentativas.")

def query_df(sql, conn):
    import pandas as pd
    cursor, conn = query(sql, conn)
    df = pd.DataFrame(cursor.fetchall(), columns=[d[0] for d in cursor.description])
    return df, conn

# Inicia conexão
try:
    conn = conectar()
    print("✅ Conexão bem-sucedida! Aguardando demanda...")
except Exception as e:
    print(f"❌ Falha na conexão inicial: {e}")
    conn = None