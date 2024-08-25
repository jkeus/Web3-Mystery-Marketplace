#! /bin/bash

geth --datadir bkc_data --rpcapi personal,eth --http --networkid 89992018 --allow-insecure-unlock --http.corsdomain "*" console  2>console.log
