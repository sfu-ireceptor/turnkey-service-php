#!/bin/sh

echo "Stopping AWStats..."
sudo docker stop awstats > /dev/null 2>&1 && sudo docker rm awstats > /dev/null 2>&1
echo "Done"
echo
