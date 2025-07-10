#!/bin/bash

# -------------------------------------------
# Resonance PDF Downloader and Book Creator
# Usage: resobook
# -------------------------------------------

# Accept CLI arguments if provided
volume="$1"
issue="$2"

# Prompt interactively if not provided
if [[ -z "$volume" || -z "$issue" ]]; then
  echo "📘 Resonance Journal Downloader"
  echo "🔢 Format: Volume (e.g. 030) Issue (e.g. 06)"
  read -p "Volume Issue: " volume issue
fi

# Validate input
if [[ ! "$volume" =~ ^[0-9]{3}$ || ! "$issue" =~ ^[0-9]{2}$ ]]; then
  echo "❌ Invalid input. Volume must be 3 digits, Issue must be 2 digits."
  exit 1
fi

# 📚 Final PDF path
book_pdf="./resonance_volume_${volume}_issue_${issue}.pdf"

# 🧠 Check if book already exists
if [[ -f "$book_pdf" ]]; then
  echo "📄 Book already exists: $book_pdf"
  echo "🚀 Opening now..."
  open "$book_pdf"
  exit 0
fi

# 📁 Intermediate storage
output_dir="gar"
mkdir -p "$output_dir"

# User-Agent string
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.198 Safari/537.36"

# 🔎 Target URL
url="https://www.ias.ac.in/listing/articles/reso/${volume}/${issue}"

# 🔍 Fetch HTML
html=$(curl -s -A "$USER_AGENT" "$url")
echo "$html" > "$output_dir/page_dump.html"

# 📄 Extract page ranges
echo "$html" | perl -nle 'print $1 if /pp&nbsp;(\d{1,4}-\d{1,4})/' | sort -u > "$output_dir/page_ranges.txt"

# 📄 2. Extract title 5 lines after page range and save in "Title PageRange" format
echo "$html" | perl -ne '
  push @lines, $_;
  if (/pp&nbsp;(\d{1,4}-\d{1,4})/) {
    my $range = $1;
    # Try to read 5 more lines from STDIN
    my @next_lines;
    for (1..5) {
      my $l = <STDIN>;
      last unless defined $l;
      push @next_lines, $l;
    }
    foreach my $l (@next_lines) {
      if ($l =~ /<p class="journal-article-list-title">.*?>(.*?)<\/a>/) {
        my $title = $1;
        $title =~ s/^\s+|\s+$//g;
        print "$title $range\n";
        last;
      }
    }
  }
' > "$output_dir/titles_with_pages.txt"





if [[ ! -s "$output_dir/page_ranges.txt" ]]; then
  echo "❌ No page ranges found. Site structure may have changed."
  exit 2
fi

# 🖼️ Download cover
cover_url="https://www.ias.ac.in/public/Volumes/reso/${volume}/${issue}/cover.jpg"
cover_output="${output_dir}/cover.jpg"
echo "🖼️  Downloading cover page..."
curl -L -A "$USER_AGENT" -e "https://www.ias.ac.in" "$cover_url" --output "$cover_output"

# 🔗 Build PDF URLs
> "$output_dir/pdf_links.txt"
while read -r range; do
    start=$(echo "$range" | cut -d- -f1 | sed 's/^0*//')
    end=$(echo "$range" | cut -d- -f2 | sed 's/^0*//')
    start=$(printf "%04d" "$start")
    end=$(printf "%04d" "$end")
    padded_range="${start}-${end}"
    echo "https://www.ias.ac.in/article/fulltext/reso/${volume}/${issue}/$padded_range"
done < "$output_dir/page_ranges.txt" | sort -u >> "$output_dir/pdf_links.txt"




# ⬇️ Download article PDFs
while read -r link; do
    echo "⬇️  Downloading $link ..."
    filename=$(basename "$link")
    curl -L -A "$USER_AGENT" -e "https://www.ias.ac.in" "$link" --output "$output_dir/$filename.pdf"
done < "$output_dir/pdf_links.txt"


echo "✅ All downloads completed. Files are in: $output_dir"

# 📚 Combine into book
echo "📚 Creating combined PDF book..."

find "$output_dir" -type f -name "*.pdf" ! -name "$(basename "$book_pdf")" | sort > "$output_dir/pdf_list.txt"

# Convert cover to PDF
cover_pdf="${output_dir}/cover.pdf"
if [[ -f "$cover_output" ]]; then
    convert "$cover_output" "$cover_pdf"
fi











# Convert titles_with_pages.txt to a formatted PDF
toc_txt="$output_dir/titles_with_pages.txt"
toc_pdf="$output_dir/toc.pdf"






if [[ -s "$toc_txt" ]]; then
    # Paths
    toc_md="$output_dir/toc.md"
    toc_pdf="$output_dir/toc.pdf"
    header_file="$output_dir/pandoc-header.tex"

    # 1️⃣ Create LaTeX header file
    cat > "$header_file" <<EOF
\usepackage{setspace}
\usepackage{xcolor}
\doublespacing
\vspace*{2\baselineskip}
EOF

    # 2️⃣ Create Markdown with title, volume/issue, and red page numbers
    {
        echo "\textcolor{blue}{\LARGE \textbf{Resonance – Volume $volume, Issue $issue}}"
        echo
        
        awk '{
            match($0, /[0-9]{1,4}-[0-9]{1,4}$/)
            if (RSTART > 0) {
                title = substr($0, 1, RSTART - 1)
                pages = substr($0, RSTART)
                gsub(/^\s+|\s+$/, "", title)
                gsub(/^\s+|\s+$/, "", pages)
                printf "**%s** \\textcolor{red}{%s}\n\n", title, pages
            } else {
                print "**" $0 "**\n"
            }
        }' "$toc_txt"
    } > "$toc_md"

    # 3️⃣ Convert to styled PDF
    pandoc "$toc_md" \
        --pdf-engine=pdflatex \
        --from markdown+raw_tex \
        -V mainfont="Times New Roman" \
        -V geometry:a4paper \
        -V geometry:margin=2cm \
        -H "$header_file" \
        -o "$toc_pdf"
fi





# Insert cover and TOC at the beginning
# List: cover, TOC (if exists), then articles
> "$output_dir/pdf_list.txt"
[[ -f "$cover_pdf" ]] && echo "$cover_pdf" >> "$output_dir/pdf_list.txt"
[[ -f "$toc_pdf" ]] && echo "$toc_pdf" >> "$output_dir/pdf_list.txt"

# Append all article PDFs
find "$output_dir" -type f -name "*.pdf" ! -name "$(basename "$book_pdf")" ! -name "cover.pdf" ! -name "toc.pdf" | sort >> "$output_dir/pdf_list.txt"

# Merge all PDFs into final book
pdfunite $(cat "$output_dir/pdf_list.txt") "$book_pdf"

# ✅ Final message and open
echo "✅ Final book created: $book_pdf"
rm -rf gar
open "$book_pdf"
