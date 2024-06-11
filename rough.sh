#!/bin/bash

query="$1"

# Define the base URLs for the respective sites in an array
declare -a urls=(
				  "https://www.google.com/search?q=site%3Ascienceworld.wolfram.com+$query"
                  "https://www.google.com/search?q=site%3Amathworld.wolfram.com+$query"
				  "https://www.google.com/search?q=site%3Achem.libretexts.org+$query"
                  "https://www.google.com/search?q=site%3Aen.wikipedia.org+$query"
                  "https://www.google.com/search?q=site%3hyperphysics.phy-astr.gsu.edu+$query"
                  "https://www.google.com/search?q=site%3Abritannica.com+$query"
                  "https://www.google.com/search?q=site%3Aocw.mit.edu+$query"
                  "https://www.google.com/search?q=site%3Aphysics.stackexchange.com+$query"
                  "https://www.khanacademy.org/search?referer=%2Fscience%2Fphysics&page_search_query=$query"
                  )

# Open URLs sequentially in Google Chrome
for url in "${urls[@]}"
do
    open -na "Google Chrome" --args --incognito "$url"
    sleep 1  # Adjust the delay as needed (e.g., 5 seconds here)
done
