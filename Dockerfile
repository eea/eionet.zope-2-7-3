FROM centos:6.6

WORKDIR /opt

ENV WEBSITE=/var/local/website PDIR=/usr/local ZDIR=/usr/local/zope

VOLUME /var/local/website

EXPOSE 8080

# Decompresses automatically
ADD Python-2.3.6.tgz .
ADD Zope-2.7.3-0.tgz .
ADD MySQL-python-1.2.3.tar.gz .
ADD python-ldap-2.4.10.tar.gz .
ADD setuptools-0.6c11-py2.3.egg ./
ADD entrypoint.sh /

RUN \
    yum install -y tar gcc gcc-c++ zlib-devel mysql mysql-devel openldap-devel \
    && cd /opt/Python-2.3.6 && ./configure --prefix=$PDIR && sed -i "s/^#zlib/zlib/g" Modules/Setup && make && make install \
    && cd /opt/python-ldap-2.4.10 && $PDIR/bin/python setup.py build install \
    && cd /opt && PATH=$PDIR/bin:$PATH:. setuptools-0.6c11-py2.3.egg \
    && cd /opt/MySQL-python-1.2.3 && $PDIR/bin/python setup.py build install \
    && cd /opt/Zope-2.7.3-0 && ./configure --prefix=$ZDIR --with-python=$PDIR/bin/python && make && make install

CMD /entrypoint.sh
