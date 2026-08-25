+++
title = "Docker + Rails: Una solución para tus dolores de cabeza"
description = "¿Los nuevos desarrolladores de tu equipo tardan semanas en poder correr el proyecto? ¿Hacer que el proyecto llegue a producción es una odisea? Tal vez Docker sea la solución."
date = 2021-09-02T15:15:49-05:00
slug = "docker-y-rails"
author = "Luis Ángel Ortega"
categories = ["Articulos"]
tags = ["rails", "docker", "desarrollo web"]
draft = false
+++

¿Has llegado a pasar una semana solamente tratando de correr el proyecto al que te acabas de unir? ¿O tu aplicación no corre en producción como corría en local?  
Hay una multitud de factores que pueden contribuir esto, por ello [Docker](https://www.docker.com/) nos ofrece una solución con la cual podemos tener un mayor control sobre estas variables a través de las computadoras que sean necesarias.  

Dicho esto, en este articulo veremos como falicitarnos la vida al tener toda nuestra aplicación de Ruby on Rails corriendo sobre Docker; incluidas las bases de datos que sean necesarias.

## Prerequisitos

Para poder seguir esta guía necesitaras tener [Docker instalado](https://docs.docker.com/get-docker/) así como un proyecto el cual quieras *dockerizar*, si solamente quieres prácticar puedes usar [este proyecto de ejemplo](https://github.com/LinkSake/docker-rails) el cual necesita una conexión a [Postgres](https://es.wikipedia.org/wiki/PostgreSQL) y a [Redis](https://es.wikipedia.org/wiki/Redis) para funcionar.

¿Eres impaciente? ¡Puedes clonar [esta rama](https://github.com/LinkSake/docker-rails/tree/docker) del proyecto donde ya se encuentran los archivos necesarios para correr el projecto dentro de Docker!

## Primero viene el Dockerfile

Lo primero que haremos será hacer una [imagen](https://docs.docker.com/get-started/overview/#docker-objects) personalizada para nuestro proyecto, así que crearemos un archivo en la raíz del mismo llamado `Dockerfile`

```bash
touch Dockerfile
```

La primer linea de nuestro archivo definirá la imagen de la cual nos basaremos, en este caso será la [imagen oficial de Ruby](https://hub.docker.com/_/ruby), pero usaremos la versión de [Alpine](https://es.wikipedia.org/wiki/Alpine_Linux) para tener una imagen más ligera como resultado.

```Dockerfile
FROM ruby:3.0.1-alpine
```

> ⚠️ Asegurate que la version de Ruby (ruby:X.X.X-alpine) sea la misma que en tu proyecto, o tendrás errores a la hora de tratar de construir la imagen. Puedes encontrar la versión que usa tu proyecto en tu Gemfile.

Después sigue la parte más dificil de este Dockerfile, instalar la dependendencias necesarias para que funcione el proyecto; las que se muestran aquí son las que funcionan para nuestro [proyecto de ejemplo](https://github.com/LinkSake/docker-rails), que incluyen las necesarias para realizar una conexión con Postgres, pero tendrás que descubrir cuales son necesarias para tu proyecto.

```Dockerfile
FROM ruby:3.0.1-alpine

RUN apk add --update --no-cache --virtual run-dependencies \
build-base \
postgresql-client \
postgresql-dev \
yarn \
git \
tzdata \
libpq \
&& rm -rf /var/cache/apk/*
```

> Puedes esperar a construir la imagen (`docker build .`) para revisar el error que imprima Docker, con eso podrás ir averiguando que depenencias hacen falta 😉  

La última linea (`rm -rf /var/cache/apk/*`) borra los paquetes de las dependencias que acabamos de instalar, esto ahorrará espacio en la imagen.  

Lo siguiente que debemos de realizar es crear un directorio dentro del contenedor donde podamos copiar el código de nuestra aplicación para su ejecución, eso lo haremos con el siguente comando dentro de nuestro Dockerfile.

```Dockerfile
FROM ruby:3.0.1-alpine

RUN apk add --update --no-cache  --virtual run-dependencies \
build-base \
postgresql-client \
postgresql-dev \
yarn \
git \
tzdata \
libpq \
&& rm -rf /var/cache/apk/*

WORKDIR /docker-rails
```

> ¡Recuerda cambiar el `docker-rails` por el nombre de tu proyecto!

Así como le dimos un hogar a tu proyecto dentro del contenedor que crearemos, las gemas del mismo necesitan una carpeta también. Por ello, le informaremos a [bundler](https://bundler.io/es/) donde colocarlas a través de una variable de ambiente.

```Dockerfile
FROM ruby:3.0.1-alpine

RUN apk add --update --no-cache  --virtual run-dependencies \
build-base \
postgresql-client \
postgresql-dev \
yarn \
git \
tzdata \
libpq \
&& rm -rf /var/cache/apk/*

WORKDIR /docker-rails

ENV BUNDLE_PATH /gems
```

Y aunque ya instalamos las dependencias necesarias para correr Rails dentro del contenedor, tu proyecto necesitará algunas gemas y algunos paquetes de JavaScript para funcionar de manera correcta, vamos a encargarnos de eso de la siguiente manera.

```Dockerfile
FROM ruby:3.0.1-alpine

RUN apk add --update --no-cache  --virtual run-dependencies \
build-base \
postgresql-client \
postgresql-dev \
yarn \
git \
tzdata \
libpq \
&& rm -rf /var/cache/apk/*

WORKDIR /docker-rails

ENV BUNDLE_PATH /gems

COPY package.json yarn.lock /docker-rails/
RUN yarn install
COPY Gemfile Gemfile.lock /docker-rails/
RUN bundle install
```

Ahora que ya tenemos todo lo necesario para que funcione tu proyecto, vamos a copiar el código al contenedor dentro de la que carpeta que creamos con el comando `WORKDIR`.

```Dockerfile
FROM ruby:3.0.1-alpine

RUN apk add --update --no-cache  --virtual run-dependencies \
build-base \
postgresql-client \
postgresql-dev \
yarn \
git \
tzdata \
libpq \
&& rm -rf /var/cache/apk/*

WORKDIR /docker-rails

ENV BUNDLE_PATH /gems

COPY package.json yarn.lock /docker-rails/
RUN yarn install
COPY Gemfile Gemfile.lock /docker-rails/
RUN bundle install

COPY . /docker-rails/
```

> ¿Por qué copiamos primero los manifiestos (package.json, Gemfile, etc.) y después el resto del proyecto? Esto nos evita tener que reinstalar las dependencias (dado a que se quedan en caché) después de cambiar el código base y reconstruir la imagen; de esta manera solo cuando cambien los manifiestos se volverá a correr sus comandos de instalación.

Finalmente le diremos a Docker que comando correr cuando iniciemos nuestro contenedor (`rails`), así como los argumentos de este (`s -b 0.0.0.0`) y que puerto exponer para que nosotros podamos accesar a nuestra aplicación.

```Dockerfile
FROM ruby:3.0.1-alpine

RUN apk add --update --no-cache  --virtual run-dependencies \
build-base \
postgresql-client \
postgresql-dev \
yarn \
git \
tzdata \
libpq \
&& rm -rf /var/cache/apk/*

WORKDIR /docker-rails

ENV BUNDLE_PATH /gems

COPY package.json yarn.lock /docker-rails/
RUN yarn install
COPY Gemfile Gemfile.lock /docker-rails/
RUN bundle install

COPY . /docker-rails/

ENTRYPOINT ["bin/rails"]
CMD ["s", "-b", "0.0.0.0"]

EXPOSE 3000
```

> El puerto default sobre el que Rails corre es el 3000, pero si has designado otro puerto dentro de tu aplicación asegurarte de exponerlo de manera correcta.

Y con esto tenemos listo nuestro Dockerfile, aunque estamos lejos de tener nuestra aplicación lista. Si construyeramos nuestra imagen con `docker build .` y trataramos de correrla con `docker start docker-rails` nos encontraríamos con un error, ya que Rails no encuentra las bases de datos que necesita para iniciar de manera correcta; pero pronto nos encargaremos de ello.

## Luego el docker-compose.yml

Para poder coordinar todos los servicios que necesitamos para el correcto funcionamiento de nuestra aplicación (en este caso 2 bases de datos: Posgres y Redis) usaremos [docker-compose](https://docs.docker.com/compose/), esta útilidad de Docker nos ayudará a crear multimples contenedores de diferentes imagenes, [conectarlos](https://docs.docker.com/compose/networking/), darles [variables de ambiente](https://docs.docker.com/compose/environment-variables/) e incluso [volumenes](https://docs.docker.com/storage/volumes/).

Empezaremos creando un archivo llamado `docker-compose.yml`.

```bash
touch docker-compose.yml
```

Y en su primera linea especificaremos que [versión](https://docs.docker.com/compose/compose-file/#compose-and-docker-compatibility-matrix) de la herramienta queremos usar, en este caso usaremos la más reciente a la redacción de este articulo.

```yaml
version: '3.8'
```

Después indicaremos los servicios que queremos que corra docker-compose, esto lo haremos dentro de la etiqueta `services`. A cada servicio le daremos un nombre el cual será importante cuando estemos configurando nuestra imagen así que asegurate de nombrarlo de una manera que haga sentido para ti. Vamos como primer ejemplo servicio de Posgres, al cual llamaremos *db*.

```yaml
version: '3.8'
services:
  db:
    image: postgres:latest
    container_name: docker-rails-db
    environment:
      - POSTGRES_DB=docker-rails-dev
      - POSTGRES_PASSWORD=password
    ports:
      - 5432:5432
    volumes:
      - 'dbdata:/var/lib/postgresql/data'
```

> Los archivos YAML son sensibles a la identación, así que asegurate de tener todo en orden y andidado de forma correcta.

La etiqueta `db` es el nombre que le dimos al servicio y dentro de la cual especificaremos toda la configuración del mismo.

Lo primero con lo que nos encontramos es `image` que tal como su nombre lo indica es el nombre de la imagen que queremos usar para ese servicio, en este caso es la imagen oficial de Posgres en su última versión (puedes especificar una versión remplazando el `latest` por alguna otra versión válida).

Después nos encontramos con `container_name`, que también es autodescriptivo y el cual vendra útil a la hora de checar nuestros contendores con `docker ps`.

`enviroment` se refiere a las variables de ambiente, y si nos referimos a la documentación de la imagen de [Docker de Posgres](https://hub.docker.com/_/postgres) podemos ver que la única variable obligatoria es `POSTGRES_PASSWORD` pero nosotros también definiremos `POSTGRES_DB` para darle un nombre personalizado a la base de datos que crea la imagen por defecto.

> ⚠️ ¡Asegurate de elegir una contraseña segura para la base de datos!

`ports` son los puertos que necesitaremos pasar de dentro del contenedor a nuestra maquina, los indicados en el archivo son los que por defecto usa Posgres.

Finalmente los `volumes` son la infomación persistente que necesitaremos para no correr las migraciones cada vez que encendamos el contenedor, esto porque Docker borra todos los datos una vez que damos de baja la información, si quieres aprender más sobre este tema te recomiendo [esta](https://docs.docker.com/storage/volumes/) sección de la documentación.

Ahora, el siguiente servicio es el de Redis pero no ahondaremos mucho en el pues cuenta solo con un par de etiquetas las cuales ya hemos revisado, para más información puedes visitar [la imagen oficial.](https://hub.docker.com/_/redis)

```yaml
version: '3.8'
services:
  db:
    image: postgres:latest
    container_name: docker-rails-db
    environment:
      - POSTGRES_DB=docker-rails-dev
      - POSTGRES_PASSWORD=password
    ports:
      - 5432:5432
    volumes:
      - 'dbdata:/var/lib/postgresql/data'
  redis:
    image: redis:latest
    container_name: docker-rails-redis
    ports:
      - 6379:6379
```

Nuestro último servicio lo llamaremos `web` y será la imagen que hemos construido con nuestro `Dockerfile`.

```yaml
version: '3.8'
services:
  db:
    image: postgres:latest
    container_name: docker-rails-db
    environment:
      - POSTGRES_DB=docker-rails-dev
      - POSTGRES_PASSWORD=password
    ports:
      - 5432:5432
    volumes:
      - 'dbdata:/var/lib/postgresql/data'
  redis:
    image: redis:latest
    container_name: docker-rails-redis
    ports:
      - 6379:6379
  web:
    build: .
    image: docker-rails
    container_name: docker-rails-web
    ports:
      - 3000:3000
    depends_on:
      - db
      - redis
    environment:
      - POSTGRES_HOST=db
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
      - REDIS_URL=redis://redis:6379
```

La primer etiqueta nueva con la que nos topamos es `build`, la cual indica el directorio donde se encuentra nuestro Dockerfile; dado a que nuestro Dockerfile está en la raíz solamente pondremos `.`; si tu Dockerfile no está en la raíz o tiene otro nombre es recomendable que leas [esta](https://docs.docker.com/compose/compose-file/compose-file-v3/#build) sección de la documentación para asegurarte que Compose lo encuentre.

La etiqueta `image` en este caso servirá para nombrar la imagen que construirá Compose, ya que al estar presente `build` no irá al repositorio a buscar una imagen preconstruida.

Por último, la etiqueta `depends_on` informará a Compose que no se debe de tratar de iniciar el contenedor hasta que estén creados los servicios `db` y `redis`, así como los conectará de manera interna para que nosotros podamos accesar a ellos mediante un URL (como se puede observar en la variable de ambiente de Redis) o por sus respectivas credenciales (como es el caso de Postgres), si quieres aprender como Docker maneja eso puedes leer sobre [Docker Network](https://docs.docker.com/compose/networking/).

Ahora que ya terminamos con los servicios, lo unico que debemos es listar los volumenes que usaremos y a los cuales [nombramos](https://docs.docker.com/compose/compose-file/compose-file-v3/#volumes) de la siguiente manera.

```yaml
version: '3.8'
services:
  db:
    image: postgres:latest
    container_name: docker-rails-db
    environment:
      - POSTGRES_DB=docker-rails-dev
      - POSTGRES_PASSWORD=password
    ports:
      - 5432:5432
    volumes:
      - 'dbdata:/var/lib/postgresql/data'
  redis:
    image: redis:latest
    container_name: docker-rails-redis
    ports:
      - 6379:6379
  web:
    build: .
    image: docker-rails
    container_name: docker-rails-web
    ports:
      - 3000:3000
    depends_on:
      - db
      - redis
    environment:
      - POSTGRES_HOST=db
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
      - REDIS_URL=redis://redis:6379
    volumes:
      - .:/app
volumes:
  dbdata:
```

¡Y listo! Nuestro `docker-compose.yml` está listo, ahora solo falta un paso para empezar a crear nuestra aplicación contenida en Docker.

## Ojos que no ven, .dockerignore que no siente

Muchas veces no queremos que ciertos archivos estén en nuestra imagen de Docker pues estos no son necesarios para su contrucción (o se generan en la misma) y solo terminan haciendo el proyecto más grande de lo que necesita ser, como puede ser el caso de los `node_modules` y la carpeta `.git`.  
Para ahorrarnos este espacio crearemos un archivo llamado `.dockerignore` en la raíz de nuestro proyecto y añadiremos estas dos carpetas:

```bash
echo ".git \n node_modules" >> .dockerignore
```

Para más información sobre lo que puede contenener un archivo `.dockerignore` puedes consultar la [documentación oficial de Docker](https://docs.docker.com/engine/reference/builder/#dockerignore-file)

## Unas bases de datos para llevar

Antes de correr el proyecto será necesario crear la base de datos que Rails espera, y crearla es tan sencillo que se puede hacer en un solo comando.

```bash
docker-compose run web db:create
```

Este comando le dice a Docker que use la imagen (que construirá) para correr un comando, en este caso `db:create`. Docker, con lo especificado en el `docker-compose.yml` sabe que como *web* depende de *db* tendrá que correr primero la instancia de Postgres, por lo que la base de datos se creará en este contenedor.

> ¿Por qué solamente `db:create` y no `rails db:create` o `rake db:create`? En nuestro `Dockerfile` dimos como punto de entrada el comando `rails`, por ello solo es necesario pasar los parametros. Si quisieramos efectuar otro comando dentro del contenedor esto tendría que ser a través de [docker exec](https://docs.docker.com/engine/reference/commandline/exec/).

## Nuestra aplicación en un contenedor

Con la base de datos creada, solo queda un comando que corra los contenedores en [modo separado](https://docs.docker.com/compose/reference/up/) y podremos ver el fruto de nuestro trabajo.

```bash
docker-compose up -d
```

¡Y listo! Ya podrás accesar a traves de tu navegador a [localhost:3000](http://localhost:3000/) y ver la página de bienvenida de Rails.

![Welcome to Rails!](/images/post/docker-rails-1.png)

## Conclusión

Puede que todo este proceso sea algo intimidante al principio, en especial si no sabes Docker, pero su resultado es un ambiente de desarrollo mucho más sencillo para todos los involucrados en el proyecto, pues ahora solo con tener Docker instalado podrán iniciar a programar; sin mencionar los beneficios que esta tecnología puede traer a tu ambiente de producción cuando se combina con Kubernetes o Docker Swarm.

Espero que te haya sido útil, cualquier cosa puedes [contactarme](https://luisangel.me/es/about) y responderé lo más pronto posible.

## Referencias

- [Docker Docs](https://docs.docker.com/samples/rails/)
- [Go Rails](https://gorails.com/episodes/docker-basics-for-gorails)
