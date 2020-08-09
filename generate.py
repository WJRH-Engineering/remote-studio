#!/usr/bin/python3

import csv
import sys

import random
import string

# clear files
mounts = open('icecast/mounts.xml', 'w')
mounts.write('')
mounts.close()
mounts = open('icecast/mounts.xml', 'a')

sources = open('liq/sources.liq', 'w')
sources.write('')
sources.close()
sources = open('liq/sources.liq', 'a')

switch = open('liq/switch.liq', 'w')
switch.write('active = switch([\n')
switch.close()
switch = open('liq/switch.liq', 'a')

mount_template = '''\
<mount>
	<mount-name>/{}</mount-name>
	<username>source</username>
	<password>{}</password>
	<max-listeners>10</max-listeners>
</mount>
'''

source_template = '''\
{} = strip_blank(
	max_blank=30.,
	input.http("http://remote.wjrh.org:8000/{}")
)
'''

def generate_password():
		chars = string.ascii_uppercase + string.ascii_lowercase + string.digits
		size = 8
		return ''.join(random.choice(chars) for x in range(size, 20))


# Read existing password combinations from file
password_file = csv.reader(open("passwords.csv", "r+"))
passwords = {}
for mountpoint, password in password_file:
	passwords[mountpoint] = password
	

new_passwords = []

# get the password for the given mount point
# from the passwords.csv file. If none exists,
# generate a new one and append it to the file
def get_password(name):
	try:
		return passwords[name]
	except:
		new_password = generate_password()
		new_passwords.append((name, new_password))
		return new_password

with open('data.csv', newline='') as csvfile:
	parser = csv.reader(csvfile, delimiter=',')
	next(parser) # discard the first row
	for row in parser:
		name, author, start_time, end_time = row

		# Generate a password for this mountpoint
		password = get_password(name)

		# Generate Icecast mountpoint
		mount_string = mount_template.format(name, password)
		mounts.write(mount_string)

		safename = name.replace('-','_')
	
		# Generate Liquidsoap source
		source_string = source_template.format(safename, name)
		sources.write(source_string)

		# Generate row in Liquidsoap switch statement
		switch_string = '\t({{ {}-{} }}, {}),\n'.format(start_time, end_time, safename)
		switch.write(switch_string)


switch.write('])')

# Add new passwords to file
# password_file.close()
password_file = open('passwords.csv', 'a')
for name, password in new_passwords:
	password_file.write('{},{}\n'.format(name, password))

password_file.close()

mounts.close()
sources.close()
switch.close()
