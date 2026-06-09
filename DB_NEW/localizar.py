import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from db_connection import conectar

def localizar_tabelas():
    conn = conectar()
    cursor = conn.cursor()
    
    query = """
        SELECT 
            table_schema,
            table_name,
            column_name
        FROM 
            information_schema.columns
        WHERE 
            LOWER(column_name) LIKE '%cartao%'
            OR LOWER(column_name) LIKE '%cartão%'
            OR LOWER(column_name) LIKE '%card%'
            OR LOWER(column_name) LIKE '%num%cart%'
            OR LOWER(column_name) LIKE '%nr%cart%'
            OR LOWER(column_name) LIKE '%numero%cart%'
        ORDER BY 
            table_schema, table_name, column_name
    """
    
    cursor.execute(query)
    resultados = cursor.fetchall()

    print(f"{'SCHEMA':<25} {'TABELA':<45} {'COLUNA':<40}")
    print("-" * 110)
    
    for row in resultados:
        print(f"{row[0]:<25} {row[1]:<45} {row[2]:<40}")

    print(f"\nTotal encontrado: {len(resultados)} coluna(s)")
    
    cursor.close()
    conn.close()

localizar_tabelas()