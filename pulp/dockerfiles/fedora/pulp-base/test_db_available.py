#!/usr/bin/env python
import sys
import os
import pymongo

# PRECEDENCE:
#  CLI
#  ENV
#  DEFAULT

if __name__ == "__main__":

  # Set default
  dbhost = None
  dbport = 27017

  # ENV takes precedence over default
  if 'PULP_DB_SERVICE_HOST' in os.environ: dbhost = os.environ['PULP_DB_SERVICE_HOST']
  if 'PULP_DB_SERVICE_PORT' in os.environ: dbport = int(os.environ['PULP_DB_SERVICE_PORT'])

  # CLI takes precedence over all
  if len(sys.argv) > 1: dbhost = sys.argv[1]
  if len(sys.argv) > 2: dbport = int(sys.argv[2])

  if dbhost == None:
    print sys.argv[0]+ ": Missing required value for PULP_DB_SERVICE_HOST"
    sys.exit(2)

  print "Testing connection to MongoDB on %s, %s" % (dbhost, dbport)
  try:
    connection = pymongo.Connection(dbhost, int(dbport))
  except:
    sys.exit(1)

