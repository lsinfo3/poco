#!/usr/bin/python
import xmlrpclib,sys,commands
from getpass import getpass

 #Read command-line parameters
try:
  apiurl = sys.argv[1]
  username = sys.argv[2]
  outfilename = sys.argv[3]
  
except:
  print "Usage: %s apiurl username outfilename" % sys.argv[0]
  sys.exit(-1)

api_server = xmlrpclib.ServerProxy(apiurl)
auth = {}
auth['Username']=username
auth['AuthMethod']= 'password'
auth['AuthString']= getpass("Your Password: ")

# add PLC-API Code here

with open(outfilename,'w') as outfile:
  for node in api_server.GetNodes(auth):
    outfile.write("%s\n" % node['hostname'])
