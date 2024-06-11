#!/bin/bash

query="$1"

# Define the base URLs for the respective sites in an array
declare -a urls=(
				  "https://www.google.com/search?q=site%3Awolfram.com+$query"
				  "https://www.google.com/search?q=site%3Alibretexts.org+$query"
                  "https://en.wikipedia.org/wiki/$query"
                  "https://www.britannica.com/search?query=$query"
                  "https://physics.stackexchange.com/search?q=$query"
                  "https://www.google.com/search?q=site%3Aphysicsforums.com+$query"
                  "https://www.google.com/search?q=site%3Aacademic.oup.com+$query"
                  "https://www.google.com/search?q=site%3Aocw.mit.edu+$query"
                  "https://www.google.com/search?q=site%3hyperphysics.phy-astr.gsu.edu+$query"
                  "https://www.khanacademy.org/search?referer=%2Fscience%2Fphysics&page_search_query=$query"
                  "https://www.google.com/search?q=$query"
                  )


# Open URLs sequentially in Google Chrome
first_iteration=true

for url in "${urls[@]}"
do
    open -na "Google Chrome" --args --incognito "$url" 
    if [ "$first_iteration" = true ]; then
        sleep 1
        first_iteration=false
    else
        sleep 0.05
    fi
done

	
