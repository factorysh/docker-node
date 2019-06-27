#!/bin/bash

apt-get update
apt-get install -y libsqlite3-dev
yarn add sqlite3
node main.js

