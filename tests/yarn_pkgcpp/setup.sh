#!/bin/bash

apt-get update
apt-get install -y libicu-dev
yarn add node-icu-charset-detector
node main.js

