#!/usr/bin/python
import xmlrpclib,sys,commands
from getpass import getpass

 #Read command-line parameters
try:
  apiurl = sys.argv[1]
  username = sys.argv[2]
  allNodes = sys.argv[3]
  sshNodes = sys.argv[4]
  slicename= sys.argv[5]
except:
  print "Usage: %s apiurl username allNodes sshNodes slicename" % sys.argv[0]
  sys.exit(-1)

api_server = xmlrpclib.ServerProxy(apiurl)
auth = {}
auth['Username']=username
auth['AuthMethod']= 'password'
auth['AuthString']= getpass("Your Password: ")

# add PLC-API Code here

with open(allNodes) as infile:
  node_list = [line.strip() for line in infile]

with open(sshNodes) as infile:
  for line in infile:
    print "%s" % line
    node_list.remove("%s" % line)

api_server.DeleteSliceFromNodes(auth,slicename,node_list)


