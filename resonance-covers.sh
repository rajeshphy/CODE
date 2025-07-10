#!/bin/bash

# 📘 Cover Page Collector for Resonance Journal
echo "📥 Resonance Volume Cover Downloader"

# Accept volume from command-line if provided
volume="$1"

# Ask interactively if not passed as argument
if [[ -z "$volume" ]]; then
  read -p "🔢 Enter Volume Number (e.g., 030): " volume
fi

# ✅ Validate volume format
if [[ ! "$volume" =~ ^[0-9]{3}$ ]]; then
  echo "❌ Volume must be a 3-digit number."
  exit 1
fi

# 🎯 Determine issue count
if [[ "$volume" == "030" ]]; then
  total_issues=6
else
  total_issues=12
fi

# 🧾 Output file name
final_pdf="resonance_volume_${volume}_covers.pdf"

# ✅ Skip if already created
if [[ -f "$final_pdf" ]]; then
  echo "✅ $final_pdf already exists. Opening..."
  open "$final_pdf"
  exit 0
fi

# 📁 Prepare working directory
outdir="gar_covers"
mkdir -p "$outdir"

# 🌐 User agent string for curl
USER_AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 13_5_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.198 Safari/537.36"

echo "📦 Downloading covers for Volume $volume..."

cover_pdf_list=()

# 🔁 Download and convert covers
for ((i = 1; i <= total_issues; i++)); do
  issue=$(printf "%02d" "$i")
  img_url="https://www.ias.ac.in/public/Volumes/reso/${volume}/${issue}/cover.jpg"
  img_file="${outdir}/cover_${volume}_${issue}.jpg"
  pdf_file="${outdir}/cover_${volume}_${issue}.pdf"

  # ✅ Skip if already processed
  if [[ -s "$pdf_file" ]]; then
    echo "✅ Already exists: $pdf_file"
    cover_pdf_list+=("$pdf_file")
    continue
  fi

  echo "⬇️  Downloading: $img_url"
  curl -s -L -A "$USER_AGENT" -e "https://www.ias.ac.in" "$img_url" --output "$img_file"

  if [[ -s "$img_file" ]]; then
    convert "$img_file" "$pdf_file"
    cover_pdf_list+=("$pdf_file")
  else
    echo "⚠️  Skipped: No cover image found for issue $issue"
    rm -f "$img_file"
  fi
done

# 🧩 Merge all covers
if [[ ${#cover_pdf_list[@]} -gt 0 ]]; then
  echo "📚 Creating final merged PDF: $final_pdf"
  pdfunite "${cover_pdf_list[@]}" "$final_pdf"
  echo "✅ Done. Output saved to $final_pdf"
  rm -rf gar_covers
  open "$final_pdf"
else
  echo "❌ No covers were downloaded. Nothing to merge."
  exit 1
fi
