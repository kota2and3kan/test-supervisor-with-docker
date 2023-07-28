FROM debian:bullseye-slim

WORKDIR /foo

RUN apt update && apt install -y supervisor
RUN sed -ir 's#/var/run/supervisor.sock#/foo/supervisor.sock#g' /etc/supervisor/supervisord.conf

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./app1/app1 .
COPY ./app2/app2 .

RUN groupadd -r --gid 300 foo && \
    useradd -r --uid 300 -g foo foo
RUN chown -R foo:foo /foo

USER 300

CMD ["/usr/bin/supervisord"]
