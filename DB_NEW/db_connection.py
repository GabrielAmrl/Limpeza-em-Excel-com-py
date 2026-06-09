import redshift_connector

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