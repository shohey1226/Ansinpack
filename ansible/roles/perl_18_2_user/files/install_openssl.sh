openssl_version=`openssl version`
if [[ $openssl_version != 'OpenSSL 1.0.1e-fips 11 Feb 2013' ]]
then
    cd /tmp
    tar zxvf openssl-1.0.1f.tar.gz
    cd openssl-1.0.1f 
    ./config --shared 
    make
    make install
fi
