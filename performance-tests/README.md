\# Pruebas de carga con K6



\## Objetivo



Evaluar el rendimiento del endpoint de notificaciones de la arquitectura serverless mediante pruebas de carga con K6.



\## Herramienta



\- K6 v2.2.0

\- API Gateway de AWS

\- Lambda principal: `api-hexagonal`



\## Configuración utilizada



El script `load-test.js` utiliza:



\- Usuarios virtuales configurables.

\- Duración configurable.

\- URL base mediante la variable `BASE\_URL`.

\- Token de autenticación mediante la variable `TOKEN`.

\- Método HTTP POST.

\- Verificación de respuestas HTTP 202.



\## Requisitos previos



1\. Tener K6 instalado.

2\. Disponer de una URL válida de API Gateway.

3\. Disponer de un token de autenticación válido.

4\. Configurar las variables de entorno antes de ejecutar la prueba.



\## Ejecución de referencia



Desde esta carpeta, ejecutar en PowerShell:



```powershell

$env:BASE\_URL = "https://TU\_API\_ID.execute-api.us-east-1.amazonaws.com"

$env:TOKEN = "TU\_TOKEN\_VALIDO"



k6 run --vus 10 --duration 1m `

&#x20; -e BASE\_URL=$env:BASE\_URL `

&#x20; -e TOKEN=$env:TOKEN `

&#x20; load-test.js

```



Para cambiar la cantidad de usuarios virtuales o la duración, modificar los parámetros `--vus` y `--duration`.



\## Precauciones



\- No publicar tokens, claves de AWS ni credenciales.

\- No ejecutar pruebas de alta carga sin autorización y control de los efectos sobre los servicios.

\- Los resultados dependen de la configuración de AWS y del entorno de ejecución.

\- Las pruebas documentadas se realizaron contra el endpoint configurado en el script.



