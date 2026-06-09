import os
import pandas as pd
import warnings
from db_connection import conectar

warnings.filterwarnings('ignore', category=UserWarning)

# ✏️ MUDA AQUI
MES_RJ_CE = "'5'"
MES_SP = "'05'"
ANO = '2026'

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

def fetch_requestqlik():
    conn = conectar()

    query = f"""
    SELECT {COLUNAS}
    FROM bi_brrj_act.bt_brrj_requestqlik 
    WHERE ano = '{ANO}'
      AND mes IN ({MES_RJ_CE})
      AND br_atendente IN (
        'BR0093587885','BR0103278235','BR0103096365','BR0095257565','BR0865324085',
        'BR0066783455','BR0125005145','BR0866466815','BR0066669675','BR0101043985',
        'BR0111954975','BR0868471015','BR0830453415','BR0081454535','BR0860392225',
        'BR0103419815','BR0077797415','BR0867256275','BR0858082925','BR0104122865',
        'BR0054488945','BR0067198575','BR0104869855','BR0035750135','BR0020800145',
        'BR0107062525'
      )

    UNION ALL

    SELECT {COLUNAS}
    FROM bi_brce_act.bt_brce_requestqlik 
    WHERE ano = '{ANO}'
      AND mes IN ({MES_RJ_CE})
      AND br_atendente IN (
        'BR0093587885','BR0103278235','BR0103096365','BR0095257565','BR0865324085',
        'BR0066783455','BR0125005145','BR0866466815','BR0066669675','BR0101043985',
        'BR0111954975','BR0868471015','BR0830453415','BR0081454535','BR0860392225',
        'BR0103419815','BR0077797415','BR0867256275','BR0858082925','BR0104122865',
        'BR0054488945','BR0067198575','BR0104869855','BR0035750135','BR0020800145',
        'BR0107062525'
      )

    UNION ALL

    SELECT {COLUNAS}
    FROM bi_brsp_act.bt_brsp_requestqlik 
    WHERE ano = '{ANO}'
      AND mes IN ({MES_SP})
      AND br_atendente IN (
        'BR0862208175','BR0076463765','BR0095333255','BR0868434205','BR0859315295',
        'BR0863487865','BR0032233075','BR0067296125','BR0862343025','BR0884350595',
        'BR0045064705','BR0046470725','BR0629051125','BR0782124485','BR0862295875',
        'BR0793249245','BR0865810505','BR0869401525','BR0858014925','BR0117276665',
        'BR0835103545','BR0866271565','BR0864238175','BR0084283425'
      )
    """

    cursor = conn.cursor()
    cursor.execute(query)

    colunas = [desc[0].lower() for desc in cursor.description]
    dados = cursor.fetchall()

    df = pd.DataFrame(dados, columns=colunas)

    df.columns = [col.capitalize() for col in df.columns]

    cursor.close()
    conn.close()

    return df

if __name__ == "__main__":
    df = fetch_requestqlik()
    print(f"Linhas: {df.shape[0]} | Colunas: {df.shape[1]}")

    mes_label = MES_RJ_CE.replace("'", "").replace(", ", "-")
    output_path = rf'C:\Users\363078\OneDrive - NEOBPO\Área de Trabalho\Dowloand Query\requestqlik_{ANO}_mes{mes_label}.xlsx'
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    df.to_excel(output_path, index=False)
    print(f"Arquivo salvo em: {output_path}")

    