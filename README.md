
# Magento 2 base image for Docker

## Supported tags

`2.4.1`, `2.4.1-dev`, `2.4.2`, `2.4.2-dev`, `2.4.3`, `2.4.3-dev`

## How to run this image
This image is based on the latest Apache version in the [official PHP image](https://registry.hub.docker.com/_/php/) and it required MySQL or MariaDB and Elasticsearch images. Requirements for database and Elasticsearch versions will differ in every Magento 2 base version. The image itself is build to work with a reverse proxy instead of binding the HTTP ports directly. You can find the simple running steps below or use a `docker-compose` file instead.

```bash
# Create a network for Reverse Proxy, DB, Elasticsearch and Magento 2.
$ docker network create backend
# Run MariaDB/MySQL database image
$ docker run -d --net backend --name mariadb -e MARIADB_USER=magento -e MARIADB_PASSWORD=magento -e MARIADB_ROOT_PASSWORD=root -e MARIADB_DATABASE=magento mariadb:10.4
# Run Elasticsearch (change the ram amount if needed) image
$ docker run -d --name elasticsearch --net backend -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.16.2
# Run Rever Proxy (if needed) image
$ docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro nginxproxy/nginx-proxy
# Run Magento 2 base image
$ docker run -d -e VIRTUAL_HOST=subdomain.yourdomain.tld -e DB_SERVER=mariadb -e ELASTICSEARCH_SERVER=elasticsearch -e MAGENTO_HOST=subdomain.yourdomain.tld --net backend --name magento2 ataberkylmz/magento2:2.4.2
```

### Running with SSL
Create a network then run database and Elasticsearch images same as before:
```bash
# Create a network for Reverse Proxy, DB, Elasticsearch and Magento 2.
$ docker network create backend
# Run MariaDB/MySQL database image
$ docker run -d --net backend --name mariadb -e MARIADB_USER=magento -e MARIADB_PASSWORD=magento -e MARIADB_ROOT_PASSWORD=root -e MARIADB_DATABASE=magento mariadb:10.4
# Run Elasticsearch (change the ram amount if needed) image
$ docker run -d --name elasticsearch --net backend -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.16.2
```

Run Nginx reverse proxy:
```bash
$ docker run -d --net backend --name nginx-proxy -p 8080:80 -p 4443:443 \
    --volume certs:/etc/nginx/certs \
    --volume vhost:/etc/nginx/vhost.d \
    --volume html:/usr/share/nginx/html \
    --volume /var/run/docker.sock:/tmp/docker.sock:ro \
    nginxproxy/nginx-proxy
```
Run Acme container for Let's Encrypt:
```bash
$ docker run -d --name nginx-proxy-acme -e DEFAULT_EMAIL=mail@yourdomain.tld \
    --volumes-from nginx-proxy \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    --volume acme:/etc/acme.sh \
    nginxproxy/acme-companion
```
Run the image with SSL settings:
```bash
$ docker run -d -e VIRTUAL_HOST=subdomain.yourdomain.tld -e USE_SSL=1 -e LETSENCRYPT_HOST=subdomain.yourdomain.tld -e LETSENCRYPT_EMAIL=mail@yourdomain.tld -e DB_SERVER=mariadb -e ELASTICSEARCH_SERVER=elasticsearch -e MAGENTO_HOST=subdomain.yourdomain.tld --net backend --name magento2 ataberkylmz/magento2:2.4.2
```
### Running with Docker Compose
Assuming that the `nginx-proxy` and `elasticsearch` containers already running in the background and the network `backend` is already created, the below docker-compose.yml can be used.
```yml
version: '3.9'

services:
  db:
    image: mariadb:10.4
    container_name: mariadb
    environment:
      MARIADB_ROOT_PASSWORD: root
      MARIADB_DATABASE: magento
      MARIADB_USER: magento
      MARIADB_PASSWORD: magento
  web:
    image: ataberkylmz/magento2:2.4.2
    container_name: magento2
    environment:
      - DB_SERVER=mariadb
      - ELASTICSEARCH_SERVER=elasticsearch
      - MAGENTO_HOST=subdomain.yourdomain.tld
      - VIRTUAL_HOST=subdomain.yourdomain.tld
      - LETSENCRYPT_HOST=subdomain.yourdomain.tld
      - USE_SSL=1
      - DEPLOY_SAMPLEDATA=1
    networks: 
      - backend
      - default
    volumes:
      - type: volume
        source: webdata
        target: /var/www/html
  sftp:
    ports:
      - 2222:22/tcp
    command:
      - admin:admin:33
    image: atmoz/sftp
    volumes:
      - webdata:/home/admin/web
      
volumes:
  webdata:

networks:
  nginx-proxy:
    external:
      name: backend
```

## Remote debugging
Assuming that the `nginx-proxy` and `elasticsearch` containers already running in the background and the network `backend` is already created, run the below docker-compose file to create the container for Magento 2 and MariaDB.

```yml
  version: '3.9'

  services:
    db:
      image: mariadb:10.4
      container_name: mariadb
      environment:
        MARIADB_ROOT_PASSWORD: root
        MARIADB_DATABASE: magento
        MARIADB_USER: magento
        MARIADB_PASSWORD: magento

    web:
      image: ataberkylmz/magento2:2.4.2-dev
      container_name: magento2
      environment:
        - DB_SERVER=mariadb
        - ELASTICSEARCH_SERVER=elasticsearch
        - MAGENTO_HOST=subdomain.yourdomain.tld
        - VIRTUAL_HOST=subdomain.yourdomain.tld
        - LETSENCRYPT_HOST=subdomain.yourdomain.tld
        - USE_SSL=1
        - DEPLOY_SAMPLEDATA=1
      networks: 
        - backend
        - default
      volumes:
        - type: volume
          source: webdata
          target: /var/www/html
      ports:
        - 2022:22/tcp
        
  volumes:
    webdata:

  networks:
    backend:
      external:
        name: backend
```

Assuming that the container is running behind the reverse proxy and your local device cannot expose ports due to certain reasons, then you need to create an SSH tunnel between your local device and the container. After running the docker-compose, run the below command to create the SSH tunnel.

```bash
$ ssh -R 127.0.0.1:9003:127.0.0.1:9003 -p 2022 dev@subdomain.yourdomain.tld
```

After the tunnel is created, you can configure your IDE to listen on 9003 (or the your defined port).

## Environment variables
- **MAGENTO_HOST**: Will be used while installing Magento, indicates the Magento host, \(default *\<will be defined\>*\), **Required**.
- **DB_SERVER**: IP or Hostname of the MySQL/MariaDB server \(default *\<will be defined\>*\), **Required**.
- **DB_PORT**: Port of the database server/instance \(default *3306*\)
- **DB_NAME**: Database name in your Database host \(default *magento*\)
- **DB_USER**: Database user \(default *magento*\)
- **DB_PASSWORD**: Database password \(default *magento*\)
- **DB_PREFIX**: Database table prefix \(default *m2_*\)
- **ELASTICSEARCH_SERVER**: IP or Hostname of Elasticsearch server/container \(default *\<will be defined\>*\), **Required**.
- **ELASTICSEARCH_PORT**: Port of the elasticsearch host/instance \(default *9200*\)
- **ELASTICSEARCH_INDEX_PREFIX**: Index prefix for Elasticsearch \(default *magento2*\).
- **ELASTICSEARCH_TIMEOUT**: Timeout seconds for Elasticsearch connection \(default *15*\)
- **ADMIN_NAME**: Admin first name \(default *admin*\)
- **ADMIN_LASTNAME**: Admin last name \(default *admin*\)
- **ADMIN_EMAIL**: Admin email \(default *admin@example.com*\)
- **ADMIN_USERNAME**: Admin username for Magento 2 backend login \(default *admin*\)
- **ADMIN_PASSWORD**: Admin password for Magento 2 backend login \(default *admin123*\)
- **ADMIN_URLEXT**: Admin access URL extension, \<your_domain\>\/\<admin_extension\>  \(default */admin*\)
- **MAGENTO_LANGUAGE**: Language of Magento 2 \(default *en_US*\)
- **MAGENTO_CURRENCY**: Currency of Magento 2 \(default *EUR*\)
- **MAGENTO_TZ**: Timezone of Magento 2 instance \(default *Europe/Amsterdam*\)
- **DEPLOY_SAMPLEDATA**: Deploys the sample data of Magento 2 when active \(default *0*\)
- **USE_SSL**: Sets required SSL configs such as base-url-secure in Magento 2 config, requires `nginxproxy/acme-companion`  container and `LETSENCRYPT_HOST` env variable \(default *0*\)
### ONLY AVAILABLE ON `x.x.x-dev` IMAGES:
- **XDEBUG_CLIENT_HOST**: Client host for xdebug. Use your client's IP if you are running the image on a remote host and no using a reverse proxy. Use `localhost` if you cannot expose port on your local device, then you also need to use SSH tunnel \(default *localhost*\) -- **ONLY AVAILABLE ON `x.x.x-dev` IMAGES**
- **XDEBUG_CLIENT_PORT**: Use the port that you are exposing on your local device for xdebug \(default *9003*\) -- **ONLY AVAILABLE ON `x.x.x-dev` IMAGES**
- **XDEBUG_IDEKEY**: IDEKEY for xdebug, use the appropriate one for your situation  \(default *"PHPSTORM"*\) -- **ONLY AVAILABLE ON `x.x.x-dev` IMAGES**
- **DEBUG_USERNAME**: Username to be used while connecting via SSH. Useful for SSH Tunneling \(default *dev*\) -- **ONLY AVAILABLE ON `x.x.x-dev` IMAGES**
- **DEBUG_USERPASS**: Password for the debug user \(default *dev*\) -- **ONLY AVAILABLE ON `x.x.x-dev` IMAGES**
