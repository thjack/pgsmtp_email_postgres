# pgsmtp_email_postgres
Extension para enviar correo con Postgres 10 en windows

Esta extension ha sido probada con Postgres 10 beta 4 con el instalador de EDB con python 3.x

Es la primera vez que escribo algo en python tengo la necesidad de enviar un correo desde postgres
Asi que analizando esta extensión que hizo Anthony Sotolongo

https://github.com/asotolongo/pgsmtp

La modifique para que funcione con python 3.x especificamente python 3.4 que es el que trae el instalador de EDB.

Estuve probando con PgAdmin 4 y no se porque razon cuando ejecuto la extension no me da ningun error pero no puedo ver el schema
creado creado por codigo desde PgAdmin 4 asi que para poder trabajar cree manualmente la extensión antes y la primera linea
que crea el esquema para la tabla de los correos esta comentada
