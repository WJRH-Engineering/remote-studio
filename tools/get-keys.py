#!/usr/bin/python

import psycopg2 as pg
conn = pg.connect("host = api.wjrh.org dbname = testdb user = wjrh password = hogghall")
cursor = conn.cursor()

cursor.execute("""
    SELECT * FROM mounts;
""")

rows = cursor.fetchall()

output = open('streamkeys.csv', 'w')

output.write('show,mountpoint,password,streamkey,url \n')
for id, shortname, password, mountpoint in rows:
    output.write('{},{},{}?password={},http://remote.wjrh.org:8000/{} \n'.format(shortname, password, shortname, password, shortname ))

output.close()

output = open('streamkeys.csv', 'r')
print(output.read())
