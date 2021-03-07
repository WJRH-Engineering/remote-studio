FROM python:3.8
RUN pip install psycopg2 
RUN pip install redis
RUN pip install toml

RUN useradd init
USER init
workdir /home/init/src

# scripts are mounted as volumes for developoment

CMD python main.py
