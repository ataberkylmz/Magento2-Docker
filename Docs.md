# Building a Docker image
cd into the location of `Dockerfile` and then run:
```bash
docker build -t tag_name .
```

# Running a Docker Image
Run with specific port mapping and deattached:
```bash
docker run -d -p 80:80 --name name_of_container name_of_image[:tag]
docker run -d -p 80:80 --name magento magento2
```
If Nginx-reverse proxy is running, use VIRTUAL_HOST env variable:
```bash
docker run -d -e VIRTUAL_HOST=magento2.ataberkylmz.com --name magento magento2
```
Nginx reverse proxy needs the image to have `EXPOSE 80` or other EXPOSE ports in the Dockerfile.

# Running Nginx Reverse Proxy
```bash
docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
```

# Running MySQL Image
```bash
docker run --name mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=magento -e MYSQL_USER=magento -e MYSQL_PASSWORD=magento -d mysql:8.0
```
With the above, you can only connect to it from other containers if you know the ip address of it in the `bridge` network. However, if you create another network and add both of the containers, you can ping it by container name.

# Creaating Network

In order to create a network, run the below command
```bash
docker network create network_name
```

# Connecting Containers to a Network
Run the below code to connect to a container to a network:
```bash
docker network connect network_name container_name
```

# Running Elasticsearch
```bash
docker run -d --name elasticsearch --net network_name -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:tag
```


