#!/usr/bin/python
import xmlrpclib,sys,commands
from getpass import getpass

 #Read command-line parameters
try:
  apiurl = sys.argv[1]
  username = sys.argv[2]
  infilename = sys.argv[3]
  slicename = sys.argv[4]
  
except:
  print "Usage: %s apiurl username infilename slicename" % sys.argv[0]
  sys.exit(-1)

api_server = xmlrpclib.ServerProxy(apiurl)
auth = {}
auth['Username']=username
auth['AuthMethod']= 'password'
auth['AuthString']= getpass("Your Password: ")

# add PLC-API Code here

with open(infilename) as infile:
  node_list = [line.strip() for line in infile]

api_server.DeleteSliceFromNodes(auth,slicename,node_list)