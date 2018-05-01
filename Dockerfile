FROM python:3.6-slim-stretch
ENV UNIT_VERSION 1.1

RUN apt-get update && apt-get install --no-install-recommends --no-install-suggests -y \
    build-essential curl wget && rm -rf /var/lib/apt/lists/* && \
    cd /tmp && wget -qO - "http://unit.nginx.org/download/unit-$UNIT_VERSION.tar.gz" | tar xvz && \
    cd unit-$UNIT_VERSION && ./configure --prefix=/usr  --modules=lib --control='unix:/var/run/control.unit.sock' --log=/dev/stdout --pid=/var/run/unitd.pid && \
    ./configure python --module=py36 && make install && \
    rm -rf /tmp/unit-$UNIT_VERSION && \
    apt-get remove --auto-remove -y build-essential wget

ADD requirements.txt /src/
ADD unit.json /src/

RUN pip install --no-cache-dir -r /src/requirements.txt
ADD app /src/app

RUN unitd && curl -X PUT -d @/src/unit.json --unix-socket /var/run/control.unit.sock http://localhost
EXPOSE 8080
STOPSIGNAL SIGTERM
CMD ["unitd", "--no-daemon", "--control", "unix:/var/run/control.unit.sock"]
