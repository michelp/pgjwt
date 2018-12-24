FROM postgres:11
RUN apt-get update && apt-get install -y make git postgresql-server-dev-11 postgresql-11-pgtap
RUN git clone https://github.com/michelp/pgjwt.git
WORKDIR "/pgjwt"
RUN make && make install
COPY test.sql test.sql

