#!/bin/bash

# Check if input file is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 input_file_without_extension"
    exit 1
fi

# Get the directory where the script is located
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Extract the base filename (without extension)
input_file="$1.tex"
output_file="equn.tex"
output_dir="gar"

# Ensure the output directory exists in the current working directory
mkdir -p "$output_dir"

# Write the LaTeX preamble to the output file
cat <<EOL > "$output_file"
\documentclass[12pt]{article}
\usepackage[margin=2cm]{geometry}
\usepackage{amsmath, amssymb, graphicx, tabularx, booktabs, amsthm, subfiles, enumitem, xcolor, braket, subcaption}

%\numberwithin{equation}{section} % Number equations by section

\title{Equation Lists}
\author{}
\date{}
\newcommand{\td}[1]{\tilde{#1}}
\begin{document}
EOL

# Process the LaTeX file using awk
awk -v output_file="$output_file" '
BEGIN { section = ""; subsection = ""; subsubsection = ""; }
{
    if ($0 ~ /\\section\{/) {
        section = "";  # Set section to an empty string
        print "\\section{}" >> output_file;  # Print empty section
    }
    else if ($0 ~ /\\subsection\{/) {
        subsection = "";  # Set subsection to an empty string
        print "\\subsection{}" >> output_file;  # Print empty subsection
    }
    else if ($0 ~ /\\subsubsection\{/) {
        subsubsection = "";  # Set subsection to an empty string
        print "\\subsubsection{}" >> output_file;  # Print empty subsection

    }
    else if ($0 ~ /\\begin\{equation\}/ || $0 ~ /\\begin\{align\}/ || $0 ~ /\\begin\{eqnarray\}/){
        block = $0 "\n";
        while (getline > 0) {
            block = block $0 "\n";
            if ($0 ~ /\\end\{equation\}/ || $0 ~ /\\end\{align\}/ || $0 ~ /\\end\{eqnarray\}/) {
                print block >> output_file;
                break;
            }
        }
    }
}' "$input_file"

# Close the LaTeX document in the output file
echo "\\end{document}" >> "$output_file"

# Replace "% S" with "\s" in the output file
sed -i 's/^% S/\\s/' "$output_file"

# Inform the user
echo "equn saved to $output_file"

# Compile the LaTeX file into a PDF (ensure paths are correctly handled)
pdflatex -output-directory="$output_dir" "$output_file"

# Open the PDF file
if [ -f "$output_dir/equn.pdf" ]; then
    open "$output_dir/equn.pdf"
else
    echo "PDF compilation failed."
fi
