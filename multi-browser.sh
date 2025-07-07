query="$1"
urls=(
  "https://www.google.com/search?q=$query+arxiv"
  "https://www.refseek.com/search?q=$query"
  "https://ntrs.nasa.gov/search?q=$query"
  "https://ui.adsabs.harvard.edu/search/q=$query" 
  "https://www.semanticscholar.org/search?q=$query&sort=relevance"
  "https://www.ams.org/home/2018searchresults?q=$query"
  "https://babel.hathitrust.org/cgi/ls?q1=$query&field1=ocr&a=srchls&ft=ft&lmt=ft"  
  "https://inspirehep.net/literature?sort=mostrecent&size=25&page=1&q=$query"
)

open -na "Google Chrome" --args --incognito "${urls[@]}"
