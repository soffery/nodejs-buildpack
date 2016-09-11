# Docerfile for bluesecure layer 
#
# VERSION               0.1

FROM davidhibm/nodejs-runtime

RUN mkdir -p /app/.defender
ENV DEFENDER_HOME=/app/.defender
WORKDIR /app/.defender
ONBUILD ADD . /app/.defender
ONBUILD RUN npm install

ONBUILD RUN rm  /app/.defender/sid
ONBUILD RUN cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 32 > /app/.defender/sid


WORKDIR /app
EXPOSE 80
