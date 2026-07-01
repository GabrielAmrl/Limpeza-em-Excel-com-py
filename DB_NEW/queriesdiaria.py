import os
import time
import pandas as pd
import warnings
import threading
from db_connection import conectar

warnings.filterwarnings('ignore', category=UserWarning)

# ✏️ MUDA AQUI
MES_RJ_CE = "'6'"
MES_SP = "'06'"
ANO = '2026'
DIA_INICIO = 1
DIA_FIM = 9

COLUNAS = """
    estado,
    interacao,
    numero_caso,
    tipo_caso,
    motivo,
    submotivo,
    tipoatendimento,
    br_atendente,
    canal_oficial,
    data_criacao,
    data_fechamento_caso,
    numero_ponto_de_fornecimento,
    cta_contrato,
    municipio,
    dataingresso,
    ano,
    mes,
    dia
"""

ATENDENTES_RJ_CE = """
    'BR0093587885','BR0103278235','BR0103096365','BR0095257565','BR0865324085',
    'BR0066783455','BR0125005145','BR0866466815','BR0066669675','BR0101043985',
    'BR0111954975','BR0868471015','BR0830453415','BR0081454535','BR0860392225',
    'BR0103419815','BR0077797415','BR0867256275','BR0858082925','BR0104122865',
    'BR0054488945','BR0067198575','BR0104869855','BR0035750135','BR0020800145',
    'BR0107062525'
"""

ATENDENTES_SP = """
    'BR0862208175','BR0076463765','BR0095333255','BR0868434205','BR0859315295',
    'BR0863487865','BR0032233075','BR0067296125','BR0862343025','BR0884350595',
    'BR0045064705','BR0046470725','BR0629051125','BR0782124485','BR0862295875',
    'BR0793249245','BR0865810505','BR0869401525','BR0858014925','BR0117276665',
    'BR0835103545','BR0866271565','BR0864238175','BR0084283425'
"""

def executar_com_timer(cursor, query, descricao):
    concluido = threading.Event()

    def timer():
        inicio = time.time()
        while not concluido.is_set():
            elapsed = int(time.time() - inicio)
            print(f"\r⏱️  {descricao}... {elapsed}s", end="", flush=True)
            time.sleep(1)
        elapsed = int(time.time() - inicio)
        print(f"\r✅ {descricao} — {elapsed}s                          ")

    t = threading.Thread(target=timer)
    t.start()
    cursor.execute(query)
    concluido.set()
    t.join()

def fetch_requestqlik():
    print("🔌 Conectando ao banco de dados...")
    conn = conectar()
    print("✅ Conexão estabelecida!\n")

    dfs = []
    cursor = conn.cursor()

    dias = list(range(DIA_INICIO, DIA_FIM + 1))
    total = len(dias) * 3
    contador = 0
    inicio_total = time.time()

    for dia in dias:
        dia_fmt = f"{dia:02d}"  # formata com zero à esquerda: 1 → 01

        for estado, schema, mes, atendentes in [
            ("RJ", "bi_brrj_act.bt_brrj_requestqlik", MES_RJ_CE, ATENDENTES_RJ_CE),
            ("CE", "bi_brce_act.bt_brce_requestqlik", MES_RJ_CE, ATENDENTES_RJ_CE),
            ("SP", "bi_brsp_act.bt_brsp_requestqlik", MES_SP,    ATENDENTES_SP),
        ]:
            contador += 1
            print(f"[{contador}/{total}] 🔍 {estado} — dia {dia_fmt}/{DIA_FIM:02d}")

            query = f"""
                SELECT {COLUNAS}
                FROM {schema}
                WHERE ano = '{ANO}'
                  AND mes IN ({mes})
                  AND dia = '{dia_fmt}'
                  AND br_atendente IN ({atendentes})
            """

            executar_com_timer(cursor, query, f"Buscando {estado} dia {dia_fmt}")

            inicio_fetch = time.time()
            dados = cursor.fetchall()
            colunas = [desc[0].lower() for desc in cursor.description]
            dfs.append(pd.DataFrame(dados, columns=colunas))
            print(f"   📦 {len(dados)} linhas carregadas em {int(time.time() - inicio_fetch)}s")

    cursor.close()
    conn.close()
    print(f"\n🔒 Conexão encerrada. Tempo total de queries: {int(time.time() - inicio_total)}s")

    print("\n🧱 Juntando dados dos 3 estados...")
    df = pd.concat(dfs, ignore_index=True)
    df.columns = [col.capitalize() for col in df.columns]
    print(f"✅ Total final: {df.shape[0]} linhas x {df.shape[1]} colunas")

    return df

if __name__ == "__main__":
    inicio_geral = time.time()
    df = fetch_requestqlik()

    mes_label = "junho"
    dia_label = f"_dia{DIA_INICIO:02d}a{DIA_FIM:02d}"
    output_path = rf'C:\Users\363078\OneDrive - NEOBPO\Área de Trabalho\Dowloand Query\requestqlik_{ANO}_{mes_label}{dia_label}.xlsx'

    print(f"\n💾 Salvando arquivo Excel...")
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    df.to_excel(output_path, index=False)
    print(f"✅ Arquivo salvo em:\n   {output_path}")
    print(f"\n⏱️  Tempo total geral: {int(time.time() - inicio_geral)}s")