#!/bin/bash
# usage : ./start.sh <start | stop | restart | status | setup> <service name>
#array of services (searx, whoogle, matrix)

services=(searx whoogle matrix)
# help function
function help {
    echo "Usage: ./start.sh <start | stop | restart | status | setup> <service name>"
    echo "Services:"
    for i in "${services[@]}"
    do
        echo "  $i"
    done
}

# if <start | stop | restart | status> is not specified, then print error
if [ -z "$1" ]; then
    echo "Error: command is not specified"
    help
    exit 1
fi
if [[ "$1" = "help" || "$1" = "-h" || "$1" = "--help" ]]; then
    help
    exit 0
fi
# if <start | stop | restart | status...> is not valid, then print error
if [[ "$1" != "start" && "$1" != "stop" && "$1" != "restart" && "$1" != "setup" && "$1" != "status" && "$1" != "logs" ]]; then
    echo "Error: command is not valid"
    help
    exit 1
fi
# if setup is specified, then run setup.sh
if [ "$1" = "setup" ]; then
    echo "Setting up searxng-docker..."
    # clone https://github.com/searxng/searxng-docker.git to searxng-docker..
    git clone https://github.com/searxng/searxng-docker.git
    # ask for the domain name and set it to the variable domain
    read -p "Enter the domain name: " domain
    # ask for the email and set it to the variable email
    read -p "Enter the email: " email
    # set secutiry key and then write to searxng-docker/.env
    sed -i "s|ultrasecretkey|$(openssl rand -hex 32)|g" searxng-docker/searxng/settings.yml
    echo "SEARXNG_HOSTNAME=$domain" > searxng-docker/.env
    echo "LETSENCRYPT_EMAIL=$email" >> searxng-docker/.env
    exit 0
fi
# if <service name> is not specified, then print error
if [ -z "$2" ]; then
    echo "Error: service name is not specified"
    help
    exit 1
fi
if [[ ! " ${services[@]} " =~ " $2 " ]]; then
    echo "Error: service name is not valid"
    help
    exit 1
fi
# for searx
if [ "$2" = "searx" ]; then
    if [ "$1" = "start" ]; then
        cd searxng-docker
        docker-compose up -d
    elif [ "$1" = "stop" ]; then
        cd searxng-docker
        docker-compose down
    elif [ "$1" = "restart" ]; then
        cd searxng-docker
        docker-compose down
        docker-compose up -d
    elif [ "$1" = "status" ]; then
        cd searxng-docker
        docker-compose ps
    elif [ "$1" = "logs" ]; then
        cd searxng-docker
        docker-compose logs -f
    fi
fi
# for matrix; 
if [ "$2" = "matrix" ]; then
    if [ "$1" = "start" ]; then
        docker run -it --rm -d --name synapse -v $PWD/matrix/data:/data -p 8008:8008 matrixdotorg/synapse:latest
    elif [ "$1" = "stop" ]; then
        docker stop synapse
    elif [ "$1" = "restart" ]; then
        docker restart synapse
    elif [ "$1" = "status" ]; then
        docker ps | grep synapse
    elif [ "$1" = "logs" ]; then
        docker logs -f synapse
    fi
fi
    