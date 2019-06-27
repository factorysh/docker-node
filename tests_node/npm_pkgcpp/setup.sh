#!/bin/bash

npm init -y
apt-get update
apt-get install -y libsqlite3-dev
npm install --build-from-source sqlite3
node main.js
