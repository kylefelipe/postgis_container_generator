#!/bin/bash

# Author: Kyle Felipe
# E-mail: kylefelipe at gmail.com
# data: 18/07/2021
# Script feito para criar um container com postgis e com a pasta data em um
# local específico, a princípio é uma pasta data no diretório atual
# É intenção futura poder escolher via opções onde colocar a pasta data.

database="meupostgis"
hostname="localhost"
container_name="meus-dados-geograficos"
host_port="5434"
pg_password="postgres"
pg_user="postgres"
remove_data="n"
remove_container="n"
pg_pass="s"

usage() {
    echo "Usage: [ -d | --database database name ] [ -p | --port database port ]
                 [ -U | --user database user (root) ] [ -P | --password database password ]
                 [ -c | --container container name ] [ --no_pgpass skip pgpass config]
                 [ --clear_data erases data folder ] [ --rm_container remove container before create ]
                 [ --help exibe esse help ]"
    exit 2
}

use_pgpass() {
    echo "Criando aquivo .pgpas na pasta ./conf"
    echo "localhost:5432:$database:$pg_user:$pg_password" > ./conf/.pgpass
    chmod 0600 ./conf/.pgpass
}

PARSED_ARGUMENTS=$(getopt -a -n argument -o h:d:f:p:P:U: \
                    --long hostname:,database:,container_name:,port:,password:,user:,clear_data,rm_container,help,no_pgpass, -- "$@")

VALID_ARGUMENTS=$?

if [ "$VALID_ARGUMENTS" != "0" ]; then
    usage
fi

eval set -- "$PARSED_ARGUMENTS"

while :
do
    case "$1" in
    -h | --hostname)
        hostname="$2"
        shift 2
    ;;
    -d | --database)
        database="$2"
        shift 2
    ;;
    -c | --container)
        container_name="$2"
        shift 2
    ;;
    -p | --port)
        host_port="$2"
        shift 2
    ;;
    -P | --password)
        pg_password="$2"
        shift 2
    ;;
    -U | --user)
        pg_user="$2"
        shift 2
    ;;
    --clear_data)
        remove_data="s"
        shift
    ;;
    --rm_container)
        remove_container="s"
        shift
    ;;
    --no_pgpas)
        pg_pass="n"
        shift
    ;;
    --help)
        usage
        shift 2
    ;;
    --)
        shift
        break
        ;;
    *)
        echo "Opção $1 não reconhecida."
        usage
        ;;
    esac
done

if [ "$remove_data" = "s" ]; then
    echo "Removendo a pasta data."
    rm -rf data
fi

if [ "$remove_container" = "s" ]; then
    echo "Removendo container $container_name"
    docker container rm -f "$container_name"
fi

if [ ! -r ./data ] && [ ! -w ./data ] && [ ! -x ./data ]; then
    echo "Usuário não tem permissão para alterar a pasta ./data"
    echo "Considere executar como super usuário!"
    exit 1
fi

if [ ! -d "./data" ]; then
    echo "Criando a pasta /data"
    mkdir ./data
fi

if [ "$VALID_ARGUMENTS" = "0" ]
then
    existing_container="$(docker ps -q -f name=$container_name)"
    if [ -n "$existing_container" ] && [ "$remove_container" = "n" ]; then
        echo "Já existe um container com o nome $container_name."
        echo "Por favor, especifique um novo nome de container ou remova o já exstente"
        echo "ou use a opção --rm_container, que remove um container pré existente de mesmo nome"
        usage
    fi

    echo ""
    if [ "$pg_pass" = "s" ]; then
        use_pgpass
    fi

    echo ""
    echo "Criando o container $container_name em modo daemon."
    echo ""
    echo "Imagem Postgis utilizada: postgis/postgis:11-2.5"
    echo "https://hub.docker.com/r/postgis/postgis"

    sudo docker run -d \
        --restart unless-stopped --name "$container_name" \
        -p 0.0.0.0:"$host_port":5432 \
        -e POSTGRES_PASSWORD="$pg_password" \
        -e POSTGRES_USER="$pg_user" \
        -e POSTGRES_DB="$database" \
        -e PGDATA=/var/lib/postgresql/data/pgdata \
        --ipc=host \
        -v "$PWD"/data:/data \
        -v "$PWD"/scripts:/scripts \
        -v "$PWD"/scripts/10_postgis.sh:/docker-entrypoint-initdb.d/10_postgis.sh \
        -v "$PWD"/conf/.pgpass:/root/.pgpass \
        -v "$PWD"/data:/var/lib/postgresql/data/pgdata \
        postgis/postgis:11-2.5
    
    echo ""
    if [ "$(docker ps -q -f name=$container_name -f status=running)"  == "" ]; then
        echo -n "Aguardando container iniciar"
        while [ "$(docker ps -q -f name=$container_name -f status=running)"  == "" ]; do
            echo -n "."
            sleep 1
        done
    fi

    sleep 5

    echo ""
    echo "PostgreSQL Version:"
    docker exec "$container_name" pg_config --version

    echo ""
    echo "Postgis Version:"
    docker container exec "$container_name" psql -U "$pg_user" -d "$database" -c 'SELECT PostGIS_Lib_Version();'

    echo ""
    echo "Container criado com sucesso!"
    echo "Para acessar basta conectar em:"
    echo "localhost:$host_port"
    echo ""
    echo "Para parar o container:"
    echo "docker container stop $container_name"
    echo ""
    echo "Para iniciar o container (reutilizar):"
    echo "docker container start $container_name"
    echo ""
    echo "Para acessar diretamente o psql dentro do container:"
    echo "docker container exec -it $container_name psql -U $pg_user -d $database"
    echo ""
    echo "Para acessar o shell do container:"
    echo "docker container exec -it $container_name bash"
    echo ""
    echo "Be Happy!"
    echo "LLP _\\\\//"
fi
