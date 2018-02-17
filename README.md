# sakuli-compose
Execute Sakuli E2E tests with docker-compose

ln -s /root/gith/sakuli-compose/conf/nginx /var/lib/docker/data/proxy/conf.d

docker-compose -f docker-compose-revproxy.yml up -d


http://192.168.33.10:81/sakuli-test1/vnc_auto.html?path=sakuli-test1


docker-gen: 
https://techblog.sitegeist.de/docker-compose-setup-mit-nginx-reverse-proxy/
https://xsteadfastx.org/tag/docker.html
https://xsteadfastx.org/2016/03/01/nginx-im-container-und-docker-gen/
http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/
https://blog.confirm.ch/docker-reverse-proxy/



# Execute a Sakuli compose chain: 
./sakuli_compose_chain.sh -c rc.d/sakuli_compose_chain1.rc -l

# Start Portainer
docker-compose -f docker-compose-portainer.yml up

# Start Reverse proxy
docker-compose  -f docker-compose-revproxy.yml

# Inspect generated nginx config: 
cat /var/lib/docker/data/nginx/etc/nginx/conf.d/proxy.conf
error_log /dev/stdout debug;
server {
   listen 81;
   location /sakuli-test3 {
        proxy_pass http://172.21.0.2:6901;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        # WebSocket support (nginx 1.4)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        # Path rewriting
        rewrite /sakuli-test3/(.*) /$1 break;
        proxy_redirect off;
    }
}


# TODO: 
* Makefile for /var/lib/docker/data/proxygen/proxy.tmpl

