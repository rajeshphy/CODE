#!/bin/bash
cd /Users/rajeshkumar/XXX/SAVE/CODE/Weather
# Define an array of IDs
# Dumka, Ranchi, Deoghar, Giridih, Pakur, Sahibganj, Godda
# ids=("42599" "42701" "13002" "13003" "99442" "99445" "99436")
ids=("42599" "42701")

# Download each page as a PDF
for id in "${ids[@]}"; do
    /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --headless --disable-gpu --print-to-pdf="${id}.pdf" "https://city.imd.gov.in/citywx/city_weather_test_try.php?id=${id}"
done

# Crop each PDF
for id in "${ids[@]}"; do
    pdfcrop --margins "0 0 0 -350" "${id}.pdf" "cropped_${id}.pdf"
done

# Combine the cropped PDFs
pdfunite A.pdf $(for id in "${ids[@]}"; do echo -n "cropped_${id}.pdf "; done) combined.pdf
#pdfunite A.pdf combined0.pdf  combined.pdf

# Clean up individual PDF files if desired
find . -type f -name '*.pdf' ! -name 'combined.pdf' ! -name 'A.pdf' -exec rm {} +
cp combined.pdf ../../Weather-Data/Weather-$(date +%Y-%m-%d).pdf
cd /Users/rajeshkumar/XXX/SAVE/Weather-Data
git add .
git commit -m "Year-Month-Date:$(date +%Y-%m-%d)"
git push -u origin main
open Weather-$(date +%Y-%m-%d).pdf
