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
