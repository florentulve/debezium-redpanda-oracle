# Redpanda / Dbezium / Oracle

## Build Oracle Image

```sh
git clone https://github.com/oracle/docker-images.git oracle/docker-images
```

Download Database zip [https://www.oracle.com/database/technologies/oracle-database-software-downloads.html](https://www.oracle.com/database/technologies/oracle-database-software-downloads.html)

to

> oracle/docker-images/OracleDatabase/SingleInstance/dockerfiles/21.3.0

Run

```sh
cd oracle/docker-images/OracleDatabase/SingleInstance/dockerfiles/
./buildContainerImage.sh -v 21.3.0 -t oracle:21.3.0 -s
```

## Build Debezium image

```sh
./ctl.sh --buildContainer
```

## Run stack

```sh
./ctl.sh --run
```

## Preparing the database

[https://debezium.io/documentation/reference/stable/connectors/oracle.html#_preparing_the_database](https://debezium.io/documentation/reference/stable/connectors/oracle.html#_preparing_the_database)

## Create connect

```sh
./ctl.sh --config-connect
```

## UI

`Redpand console` is accessible at [localhost:8080](localhost:8080)

`Debezium UI` is accessible at [localhost:8090](localhost:8090)

