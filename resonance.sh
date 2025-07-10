#!/bin/bash

# -------------------------------------------
# Resonance PDF Downloader and Book Creator
# Usage: resobook
# -------------------------------------------

set -e  # Exit on error

# 📦 Globals
output_dir="gar"
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.198 Safari/537.36"

# 🧾 Read input
get_input() {
  volume="$1"
  issue="$2"

  if [[ -z "$volume" || -z "$issue" ]]; then
    echo "📘 Resonance Journal Downloader"
    echo "🔢 Format: Volume (e.g. 030) Issue (e.g. 06)"
    read -p "Volume Issue: " volume issue
  fi

  if [[ ! "$volume" =~ ^[0-9]{3}$ || ! "$issue" =~ ^[0-9]{2}$ ]]; then
    echo "❌ Invalid input. Volume must be 3 digits, Issue must be 2 digits."
    exit 1
  fi
}

# 🧠 Check for existing output
check_existing_pdf() {
  book_pdf="./resonance_volume_${volume}_issue_${issue}.pdf"
  if [[ -f "$book_pdf" ]]; then
    echo "📄 Book already exists: $book_pdf"
    echo "🚀 Opening now..."
    open "$book_pdf"
    exit 0
  fi
}

# 🌐 Download and parse HTML
fetch_and_parse() {
  mkdir -p "$output_dir"
  url="https://www.ias.ac.in/listing/articles/reso/${volume}/${issue}"
  html=$(curl -s -A "$USER_AGENT" "$url")
  echo "$html" > "$output_dir/page_dump.html"

  echo "$html" | perl -nle 'print $1 if /pp&nbsp;(\d{1,4}-\d{1,4})/' | sort -u > "$output_dir/page_ranges.txt"

  echo "$html" | perl -ne '
    push @lines, $_;
    if (/pp&nbsp;(\d{1,4}-\d{1,4})/) {
      my $range = $1;
      my @next_lines;
      for (1..5) {
        my $l = <STDIN>;
        last unless defined $l;
        push @next_lines, $l;
      }
      foreach my $l (@next_lines) {
        if ($l =~ /<p class=\"journal-article-list-title\">.*?>(.*?)<\/a>/) {
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
}

# 🖼️ Download cover
download_cover() {
  cover_url="https://www.ias.ac.in/public/Volumes/reso/${volume}/${issue}/cover.jpg"
  cover_output="$output_dir/cover.jpg"
  echo "🖼️  Downloading cover page..."
  curl -L -A "$USER_AGENT" -e "https://www.ias.ac.in" "$cover_url" --output "$cover_output"
  [[ -f "$cover_output" ]] && convert "$cover_output" "$output_dir/cover.pdf"
}

# 🔗 Build PDF URLs
generate_pdf_links() {
  > "$output_dir/pdf_links.txt"
  while read -r range; do
    start=$(echo "$range" | cut -d- -f1 | sed 's/^0*//')
    end=$(echo "$range" | cut -d- -f2 | sed 's/^0*//')
    start=$(printf "%04d" "$start")
    end=$(printf "%04d" "$end")
    echo "https://www.ias.ac.in/article/fulltext/reso/${volume}/${issue}/${start}-${end}"
  done < "$output_dir/page_ranges.txt" | sort -u >> "$output_dir/pdf_links.txt"
}

# ⬇️ Download PDFs
download_pdfs() {
  while read -r link; do
    echo "⬇️  Downloading $link ..."
    filename=$(basename "$link")
    curl -L -A "$USER_AGENT" -e "https://www.ias.ac.in" "$link" --output "$output_dir/$filename.pdf"
  done < "$output_dir/pdf_links.txt"
  echo "✅ All downloads completed. Files are in: $output_dir"
}

# 📑 Create TOC PDF
generate_toc_pdf() {
  toc_txt="$output_dir/titles_with_pages.txt"
  toc_md="$output_dir/toc.md"
  toc_pdf="$output_dir/toc.pdf"
  header_file="$output_dir/pandoc-header.tex"

  if [[ -s "$toc_txt" ]]; then
    cat > "$header_file" <<EOF
\usepackage{setspace}
\usepackage{xcolor}
\doublespacing
\vspace*{2\baselineskip}
EOF

    {
      echo "\\begin{center}\\textcolor{blue}{\\LARGE\\textbf{Resonance -- Volume $volume, Issue $issue}}\\end{center}"
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
    
    # Replace problematic Unicode before PDF generation (safe approach)
    sed -i '' 's/∗/*/g' "$toc_md"

    pandoc "$toc_md" \
      --pdf-engine=pdflatex \
      --from markdown+raw_tex \
      -V mainfont="Times New Roman" \
      -V geometry:a4paper \
      -V geometry:top=0cm,left=1cm,right=1cm,bottom=1cm \
      -H "$header_file" \
      -o "$toc_pdf"
  fi
}

# 📚 Combine final book
combine_book() {
  book_pdf="./resonance_volume_${volume}_issue_${issue}.pdf"
  pdf_list="$output_dir/pdf_list.txt"

  > "$pdf_list"
  [[ -f "$output_dir/cover.pdf" ]] && echo "$output_dir/cover.pdf" >> "$pdf_list"
  [[ -f "$output_dir/toc.pdf" ]] && echo "$output_dir/toc.pdf" >> "$pdf_list"

  find "$output_dir" -type f -name "*.pdf" ! -name "$(basename "$book_pdf")" ! -name "cover.pdf" ! -name "toc.pdf" | sort >> "$pdf_list"
  pdfunite $(cat "$pdf_list") "$book_pdf"
  echo "✅ Final book created: $book_pdf"
  rm -rf "$output_dir"
  open "$book_pdf"
}

# 🚀 Run All
get_input "$1" "$2"

check_existing_pdf
fetch_and_parse
download_cover
generate_pdf_links
download_pdfs
generate_toc_pdf
combine_book
