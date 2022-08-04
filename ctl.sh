#! /bin/bash

PARAMS=""
while (( "$#" )); do
  case "$1" in
    --build)
      BUILD=1
      shift
      ;;
    --start)
      RUN=1
      shift
      ;;
    --stop)
      STOP=1
      shift
      ;;
    --configure)
      CONFIG=1
      shift
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done
# set positional arguments in their proper place
eval set -- "$PARAMS"

function runPod () {
    stopPod
    podman play kube stack.final.yml
}

function stopPod () {
    podman pod stop cdc
    podman pod rm cdc
}

function buildContainer() {
    buildah bud -t "$LOCAL_DEBEZIUM_IMAGE_TAG" --build-arg DEBEZIUM_VERSION="$DEBEZIUM_VERSION" -f Containerfile.debezium-connect .
    buildah bud -t "$LOCAL_DEBEZIUM_UI_IMAGE_TAG" --build-arg DEBEZIUM_VERSION="$DEBEZIUM_VERSION" -f Containerfile.debezium-ui .
    buildah bud -t "$LOCAL_REDPANDA_IMAGE_TAG" --build-arg REDPANDA_VERSION="$REDPANDA_VERSION" -f Containerfile.redpanda .
}

function configDBZ () {

    curl --request POST \
    --url http://localhost:8083/connectors \
    --header 'Content-Type: application/json' \
    --data '{
                "name": "my-connector",
                "config": {
                    "topic.creation.enabled": true,
                    "topic.creation.default.replication.factor": -1,
                    "topic.creation.default.partitions": 1,
                    "connector.class": "io.debezium.connector.oracle.OracleConnector",
                    "tasks.max": "1",
                    "database.hostname": "localhost",
                    "database.port": "1521",
                    "database.user": "system",
                    "database.password": "Zero!123",
                    "database.dbname" : "ORASID",
                    "database.pdb.name" : "ORAPDB",
                    "database.server.name": "oracle",
                    "schema.include.list": "TESTDB",
                    "database.history.kafka.bootstrap.servers": "localhost:9092",
                    "database.history.kafka.topic": "schema-changes.inventory"
                }
            }'

}

export $(echo $(cat .env | sed 's/#.*//g'| xargs) | envsubst)


if [ "$BUILD" = 1 ]
then
    buildContainer
fi

if [ "$CONFIG" = 1 ]
then
    configDBZ
fi

if [ "$STOP" = 1 ]
then
  stopPod
fi

if [ "$RUN" = 1 ]
then
    envsubst < stack.yml > stack.final.yml
    runPod
fi
