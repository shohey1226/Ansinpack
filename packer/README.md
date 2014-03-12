    packer build -var image_name=base.img docker-webapp.json
    docker import - kamesho/base < base.img
    docker run -p 5000 -v /tmp/registry:/tmp/registry registry
