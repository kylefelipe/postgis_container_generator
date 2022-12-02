# CHANGELOG

>The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),  
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

* Tradução
* Help considerando a linguagem do sistema
* Criar um manual para ser usado no `man`

## [0.1.2] 2022-11-28

### Changed

* Versão do container docker do postgis para 15-3.3  
* Porta padrão a ser utilizada pelo container no host para 5432  

## [0.1.1] 2022-05-23

### Added

### Changed

### Fixed

* Bug de testar o acesso à pasta data antes da criação (quando a pasta não existe).

## [0.1.0] - 2022-05-20

### Added

* Opção para indicar o caminho da pasta conf com o script de configuração do banco a ser mapeada para o container.
* Opção para indicar o caminho da pasta com o script de configuração do banco.
* Opção para indicar o caminho da pasta script a ser mapeada para o banco.
* Opção para indicar tag da versão do [Postgis](https://postgis.net) a ser usada.
* Função para exibir a versão atual do script.
* Opção de exibir a versão atual do script.
* Explicação de como colocar o script no path para ser executado em qualquer lugar pelo terminal.
* Criação do arquivo de changelog.

### Changed

* Melhorias no Readme.
* Melhorias na função usage (help).
* Opção de indicar a pasta com o script de configuração do banco.
* Modificação para utilizar o diretório atual do script para utilizar as pastas padrões caso não o usuário não indique o caminho das pastas que deseja usar.

### Fixed

## [0.0.0] - 2021-07-21

Criação do script e repositório.
