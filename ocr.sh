# Create a directory to store the PNG images

echo "Input pdf file name"
read pdf_name
echo "Language: eng, hin, ori, ben, sat, pan, tam, tel"
read language

mkdir ./png_pages

# Convert PDF to individual PNG images
convert -density 300 "./$pdf_name" -depth 8 -strip -background white -alpha off ./png_pages/page.png

# Preprocess and OCR each image
mkdir ./preprocessed_pages
mkdir ./ocr_output

for img in ./png_pages/*.png; do
    # Preprocess the image (optional)
    base=$(basename "$img" .png)
    preprocessed="./preprocessed_pages/${base}.png"
    convert "./$img" -colorspace Gray -depth 8 "./$preprocessed"
    
    # Perform OCR
    tesseract "$preprocessed" "./ocr_output/${base}" -l $language
done

# Combine all text files into a single output
cat ./ocr_output/*.txt > ./output.txt

# Clean up (optional)


