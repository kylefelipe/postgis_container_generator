# Gerador de container Postgis

Esse script foi criado para gerar um container Docker com o [Postgis](https://postgis.net) 
usando a imagem oficial. O difierencial é que já gera um arquivo pg_pass, evitando
 a necessidade de solicitar senha sempre que logar com o super usuário.  
E cria uma pasta no diretório corrente para receber os dados do banco.

As opções padrões do script são:

- Nome do container = meus-dados-geográficos;  
- Nome do banco = meupostgis;  
- Porta do host = 5434;  
- Root = postgres;  
- Senha do root = postgres;  
- Recria a pasta data: não;  
- Remove o container caso exista: não;  

Esses padrões podem ser configurados conforme as opções que estarão no help

## Modo de uso

```shel
./create_postgis.sh
```

Talvêz seja necessário rodar o script como super user para fazer algumas modificações.

## Help

As seguinte opções podem ser passadas:

- `--clear_data` > Remove a pasta data existente no diretório atual e cria uma nova.
- `--rm_container` > Remove o container de mesmo nome caso já exista.
- `--no_pgpass` > Não cria o arquivo pgpass

> Essas opções anteriores não precisam de parâmetros.

- `-d | --database string` > Nome do banco a ser criado dentro do container.
- `-p | --port number` > Número da porta do host que irá receber a interna do banco.
- `-U | --user string` > Nome do usuário root.
- `-P | --password string` > Senha do usuário Root.
- `-c | --container string` > Nome do container a ser criado.

## Pasta scripts

Esta pasta é mapeada para dentro do container (`/script`), caso queira usar algum arquivo dentro do mesmo, basta jogar nessa pasta.  
Não é necessário reiniciar o container após inserir arquivos nessa pasta.

### 10_postgis.sh

É usado para criar o banco e as extensões. caso queira criar uma extensão a mais, basta alterar esse arquivo.
Ele é mapeado para dentro do entrypoint do container para ser executado.
