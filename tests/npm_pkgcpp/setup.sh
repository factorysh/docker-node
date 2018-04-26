#!/bin/bash

npm init -y
apt-get update
apt-get install -y libicu-dev
npm install node-icu-charset-detector
node main.js
