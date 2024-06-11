query="$1"
urls=(
  "https://www.google.com/search?q=$query+arxiv"
  "https://www.refseek.com/search?q=$query"
  "https://ntrs.nasa.gov/search?q=$query"
  "https://ui.adsabs.harvard.edu/search/q=$query" 
  "https://www.semanticscholar.org/search?q=$query&sort=relevance"
  "https://www.ams.org/home/2018searchresults?q=$query"
  "https://babel.hathitrust.org/cgi/ls?q1=$query&field1=ocr&a=srchls&ft=ft&lmt=ft"  
  "https://en.zlibrary-in.se/s/$query"
  "https://zlib-articles.se/s/$query"
  "https://inspirehep.net/literature?sort=mostrecent&size=25&page=1&q=$query"
  "qhttps://scholar.google.com/scholar?hl=en&as_sdt=0%2C5&q=$query"
  "https://www.base-search.net/Search/Results?type=all&lookfor=$query&ling=1&oaboost=1&name=&thes=&refid=dcresen&newsearch=1"
)

open -na "Google Chrome" --args --incognito "${urls[@]}"
