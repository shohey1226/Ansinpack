    packer build -var image_name=base.img docker-webapp.json
    docker import - kamesho/base < base.img
    docker run -d -p 5000:5000 -v /tmp/registry:/tmp/registry registry
    docker tag 74690429d72e localhost:5000/base
    docker push localhost:5000/base
    docker run -d -p 2222:22 kamesho/base5 /usr/sbin/sshd -D

