#!/bin/bash
if [[ `diff -q test test3` != '' ]]
then
	echo 'No diff.'
else
	echo 'diff.'	
fi