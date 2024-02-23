FROM debian

ENV WEBSITE=/var/local/website  \
    PDIR=/usr/local \
    ZDIR=/usr/local/zope \
    INITIALADMIN="${INITIALADMIN:-admin:firsttime}"

WORKDIR /opt

# Decompresses automatically
ADD Python-2.3.6.tgz .
ADD Zope-2.7.3-0.tgz .

RUN groupadd -g 10001 zope \
   && useradd -u 10000 -g zope zope \
   && chown -R zope:zope /opt/Zope-2.7.3-0

RUN apt-get update && apt-get install -y tar build-essential zlib1g-dev \
    && apt-get remove expat dav1d \
    && cd /opt/Python-2.3.6 && ./configure --prefix=$PDIR && sed -i "s/^#zlib/zlib/g" Modules/Setup && make && make install \
    && PATH="${PDIR}"/bin:$PATH:. \
    && cd /opt/Zope-2.7.3-0 && ./configure --prefix="${ZDIR}" --with-python="${PDIR}"/bin/python && make && make install

RUN \
    if [ ! -f "${WEBSITE}"/etc/zope.conf ]; then \
        "${ZDIR}"/bin/mkzopeinstance.py -d "${WEBSITE}" -u "${INITIALADMIN}" ; \
        chown -R zope "${WEBSITE}" ; \
    fi

VOLUME /var/local/website

EXPOSE 8080

USER zope:zope

WORKDIR "${WEBSITE}"

ENTRYPOINT ["bin/zopectl"]

CMD ["fg"]
