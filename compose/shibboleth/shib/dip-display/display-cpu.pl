#!/bin/sh
# -*- coding: utf-8 -*-
NAME=`"cpuinfo"`
echo "Content-type:text/html\r\n"
echo "<html><head>"
echo "<title>$NAME</title>"
echo '<meta name="description" content="'$NAME'">'
echo '<meta name="keywords" content="'$NAME'">'
echo '<meta http-equiv="Content-type"
content="text/html;charset=UTF-8">'
echo '<meta name="ROBOTS" content="noindex">'
echo "</head><body><pre>"
date
echo "\nuname -a"
uname -a
echo "\ncpuinfo"
cat /proc/cpuinfo
echo "</pre></body></html>"

