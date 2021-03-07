FROM python:3.8
RUN pip install psycopg2 
RUN pip install redis
RUN pip install toml

RUN adduser wjrh
workdir /home/wjrh/src

copy .pgpass /home/wjrh/.pgpass
run chown wjrh /home/wjrh/.pgpass

USER wjrh


# scripts are mounted as volumes for developoment

CMD python main.py
