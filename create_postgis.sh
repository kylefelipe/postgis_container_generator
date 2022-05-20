#!/bin/bash

# Author: Kyle Felipe
# E-mail: kylefelipe at gmail.com
# data: 18/07/2021
# Ùltima atualização: 20/05/2022
# Script feito para criar um container com postgis e com a pasta data em um
# local específico, a princípio é uma pasta data no diretório atual
# É intenção futura poder escolher via opções onde colocar a pasta data.

REPOLINK="https://github.com/kylefelipe/postgis_container_generator"
version='0.1.0'
database="meupostgis"
hostname="localhost"
container_name="meus-dados-geograficos"
host_port="5434"
pg_password="postgres"
pg_user="postgres"
remove_data="n"
remove_container="n"
pg_pass="s"
data_dir="$(pwd -P)"
script_dir="$(pwd -P)/scripts"
conf_dir="$(pwd -P)/conf"
postgis_version="11-2.5"

usage() {
    echo "Uso:  sudo create_postgis.sh [OPÇÃO]

    Essas opções possuem argumentos obrigatórios:

        [ -c | --container container name ]
        [ -C | --config-dir path path to config folder to map to container ]
        [ -d | --database database name ]
        [ -D | --data-dir path to folder data to map to container ]
        [ -g | --gis-version string postgis container version tag to use, link in the end of this help ]
        [ -h | --hostname hostname hostname/ip to expose at host ]
        [ -p | --port database port ]
        [ -P | --password database password ]
        [ -s | --script-dir path path to script folder to map to container ]
        [ -U | --user database user (root) ]
    
    Essas opções não precisam de argumentos:

        [ --clear_data erases data folder ]
        [ --no_pgpass skip pgpass config]
        [ --rm_container remove container before create ]
        [ --help exibe esse help ]
        [ --version informa a versão e sai ]"
    echo ""
    echo "Cheque as tags que podem ser utilizadas no postgis em <https://hub.docker.com/r/postgis/postgis/tags>"
    echo "Página do repositório desse script: <$REPOLINK>"
    echo "Envie os erros e sugestões para <$REPOLINK/issues>"
    echo "Se foi útil, deixe uma estrelinha"
    echo "LLP _\\\\//"
    echo "<www.kylefelie.com>"
    exit 2
}

use_pgpass() {
    echo "Criando aquivo .pgpas na pasta $conf_dir"
    echo "localhost:5432:$database:$pg_user:$pg_password" > $conf_dir/.pgpass
    chmod 0600 $conf_dir/.pgpass
}

version() {
    echo $version
    exit 2
}

PARSED_ARGUMENTS=$(getopt -a -n argument -o h:c:C:d:D:f:p:P:U:v: \
                    --long container_name:,config-dir:,database:,data-dir:,hostname:,port:,password:,script-dir:,user:,clear_data,rm_container,help,no_pgpass,version -- "$@")

VALID_ARGUMENTS=$?

if [ "$VALID_ARGUMENTS" != "0" ]; then
    usage
fi

eval set -- "$PARSED_ARGUMENTS"

while :
do
    case "$1" in
    -c | --container)
        container_name="$2"
        shift 2
    ;;
    -C | --config-dir)
        config_path="$2"
        shift 2
    ;;
    -d | --database)
        database="$2"
        shift 2
    ;;
    -D | --data-dir)
        data_dir="$2"
        shift 2
    ;;
    -g | --gis-version)
        postgis_version="$2"
        shift 2
    ;;
    -h | --hostname)
        hostname="$2"
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
    -s | --script-dir)
        script_dir="$2"
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
    -v | --version)
        version
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

if [ "$remove_data" = "s" ] && [ -d "$data_dir/data" ]; then
    echo "Removendo a pasta data."
    rm -rf "$data_dir/data"
else
    echo "Pasta $data_dir/data inexistente!"
fi

if [ "$remove_container" = "s" ]; then
    echo "Removendo container $container_name"
    docker container rm -f "$container_name"
fi

if [ ! -r "$data_dir/data" ] && [ ! -w "$data_dir/data" ] && [ ! -x "$data_dir/data" ]; then
    echo "Usuário não tem permissão para alterar a pasta $data_dir/data"
    echo "Considere executar como super usuário!"
    exit 1
fi

if [ ! -d "$data_dir/data" ]; then
    echo "Criando a pasta /data dentro do diretório $data_dir"
    mkdir -p "$data_dir/data"
    echo "Pronto!"

fi

if [ "$VALID_ARGUMENTS" = "0" ]
then
    existing_container="$(docker ps -q -f name=$container_name)"
    if [ -n "$existing_container" ] && [ "$remove_container" = "n" ]; then
        echo "Já existe um container com o nome $container_name."
        echo "Por favor, especifique um novo nome de container ou remova o já exstente"
        echo "ou use a opção --rm_container, para remover um container pré existente de mesmo nome"
        usage
    fi

    echo ""
    if [ "$pg_pass" = "s" ]; then
        use_pgpass
    fi

    echo ""
    echo "Criando o container $container_name em modo daemon."
    echo ""
    echo "Imagem Postgis utilizada: postgis/postgis:$postgis_version"
    echo "https://hub.docker.com/r/postgis/postgis"

    sudo docker run -d \
        --restart unless-stopped --name "$container_name" \
        -p 0.0.0.0:"$host_port":5432 \
        -e POSTGRES_PASSWORD="$pg_password" \
        -e POSTGRES_USER="$pg_user" \
        -e POSTGRES_DB="$database" \
        -e PGDATA=/var/lib/postgresql/data/pgdata \
        --ipc=host \
        -v "$data_dir/data":/data \
        -v "$script_dir":/scripts \
        -v "$script_dir"/10_postgis.sh:/docker-entrypoint-initdb.d/10_postgis.sh \
        -v "$conf_dir"/.pgpass:/root/.pgpass \
        -v "$data":/var/lib/postgresql/data/pgdata \
        postgis/postgis:"$postgis_version"
    
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
