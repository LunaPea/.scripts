#!/usr/bin/env python
import os
import sys
from rofi import Rofi
import re

r = Rofi()
if len(sys.argv) < 2:
    torrent = r.text_entry(
        "Torrent",
        lines=1,)
elif sys.argv[1] == "":
    torrent = r.text_entry(
        "Torrent",
        lines=1,)
else:
    torrent = " ".join(sys.argv[1:])

torrent = torrent.replace(" ", "+")

def nyaasi(torrent):
    html = os.popen('''curl -s "https://nyaa.si/?f=0&c=0_0&s=seeders&o=desc&q={}"'''.format(torrent)).read()

    torrents = []
    while True:
        start = html.find("<tr class=")
        if start == -1:
            break
        end = html.find("</tr>", start)
        title = html[start:end].split('<a href="/view/')[-1].split("</a>")[0]
        title = title.split('">')[1]
        magnet = html[start:end].split('<a href="magnet:?xt=urn:')[-1].split("</a>")[0]
        magnet = magnet.split('">')[0]
        magnet = "magnet:?xt=urn:" + magnet
        some_data = html[start:end].split('</a>')[-1].split('<td')
        size = some_data[1].split(">")[1].split("<")[0]
        seeders = some_data[3].split(">")[1].split("<")[0]
        leechers = some_data[4].split(">")[1].split("<")[0]
        downloads = some_data[5].split(">")[1].split("<")[0]
        category = html[start:end].split('alt="')[-1].split('"')[0]
        if category == "Anime - English-translated":
            torrents.append([title, magnet, size, seeders, leechers, downloads])

        html = html[end:]
