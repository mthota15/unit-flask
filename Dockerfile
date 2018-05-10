FROM mthota15/unit-python:3.6-alpine

RUN apk add --no-cache curl

WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

STOPSIGNAL SIGTERM

RUN unitd && curl -XPUT -d @unit.json --unix-socket /var/run/control.unit.sock http://localhost
CMD ["unitd", "--no-daemon", "--control", "unix:/var/run/control.unit.sock"]
