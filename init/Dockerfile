FROM python:3.8
RUN pip install psycopg2 
RUN pip install redis
RUN pip install toml

RUN whoami
RUN useradd init
USER init
workdir /home/init
run whoami

# scripts are mounted as volumes for developoment

CMD python main.py
