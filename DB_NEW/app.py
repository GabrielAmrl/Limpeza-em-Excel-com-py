import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import streamlit as st
import pandas as pd
import plotly.express as px
from db_connection import conectar

# Configuração da página
st.set_page_config(page_title="Dashboard", layout="wide")
st.title("📊 Dashboard - Dados Redshift")

# Função para carregar dados com cache
@st.cache_data(ttl=600)
def carregar_dados():
    conn = conectar()
    query = """
        SELECT 
            conta_contrato,
            qtd_cartao
        FROM dp_brrj.tbl_pag_rj_clientes
        LIMIT 100
    """
    df = pd.read_sql(query, conn)
    conn.close()
    return df

# Carrega os dados
with st.spinner("Carregando dados..."):
    df = carregar_dados()

# Métricas no topo
col1, col2, col3 = st.columns(3)
col1.metric("Total de Registros", len(df))
col2.metric("Total de Cartões", int(df['qtd_cartao'].sum()))
col3.metric("Média de Cartões", round(df['qtd_cartao'].mean(), 2))

# Gráfico
st.subheader("Distribuição de Cartões por Conta")
fig = px.bar(
    df.head(20),
    x='conta_contrato',
    y='qtd_cartao',
    title='Top 20 Contas',
    color='qtd_cartao',
    color_continuous_scale='Blues'
)
st.plotly_chart(fig, use_container_width=True)

# Tabela
st.subheader("📋 Dados Brutos")
st.dataframe(df, use_container_width=True)