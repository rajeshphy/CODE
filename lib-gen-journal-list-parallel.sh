#!/bin/bash

output="libgen_series_titles.txt"


# Create a temp script to fetch header
fetch_script=$(mktemp)

cat > "$fetch_script" << 'EOF'
#!/bin/bash
id="$1"
url="https://libgen.li/series.php?id=$id"
title=$(curl -s "$url" | awk 'match($0, /<h3>.*<\/h3>/) { tag = substr($0, RSTART, RLENGTH); gsub(/<[^>]+>/, "", tag); print tag; exit }')

if [ -n "$title" ]; then
    echo -e "$id\t$title" >> libgen_series_titles.txt
    echo "✅ ID $id: $title"
else
    echo "❌ ID $id: No header found"
fi
EOF

chmod +x "$fetch_script"

# Export output path for use in parallel jobs
export output

# Run in parallel using xargs
seq -w 17063 26699 | xargs -n 1 -P 10 "$fetch_script"

# Clean up
rm -f "$fetch_script"
