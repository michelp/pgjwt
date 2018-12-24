FROM postgres:11
RUN apt-get update && apt-get install -y make git postgresql-server-dev-11 postgresql-11-pgtap
RUN mkdir "/pgjwt"
WORKDIR "/pgjwt"
COPY . .
RUN make && make install

