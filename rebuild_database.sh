#!/bin/bash

SCHEMA="schema/iodef.sql schema/iodef_idx.sql"

psql -U postgres -c 'DROP DATABASE iodef'
psql -U postgres -c 'CREATE DATABASE iodef'

for S in $SCHEMA; do
    psql -U postgres -d iodef < $S
done
