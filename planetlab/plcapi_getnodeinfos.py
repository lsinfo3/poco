#!/usr/bin/python
import xmlrpclib,sys,commands
from getpass import getpass

 #Read command-line parameters
try:
  apiurl = sys.argv[1]
  username = sys.argv[2]
  infilename = sys.argv[3]
  outfilename = sys.argv[4]
  
except:
  print "Usage: %s apiurl username infilename outfilename" % sys.argv[0]
  sys.exit(-1)

api_server = xmlrpclib.ServerProxy(apiurl)
auth = {}
auth['Username']=username
auth['AuthMethod']= 'password'
auth['AuthString']= getpass("Your Password: ")

# add PLC-API Code here

with open(infilename) as infile:
  node_list = [line.strip() for line in infile]

# add PLC-API Code here

with open(outfilename,'w') as outfile:
  for nodename in node_list:
    for node in api_server.GetNodes(auth,{'hostname': nodename}):
      for site in api_server.GetSites(auth,{'site_id': node['site_id']}):
        print "%s;%f;%f" % (node['hostname'],site['latitude'],site['longitude']) 
        outfile.write("%s;%f;%f\n" % (node['hostname'],site['latitude'],site['longitude']))
	  