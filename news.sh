curl -o output.html https://newsonair.gov.in/regional-audio.aspx

sed -n '3200,3500p' output.html>output2.html

grep "Ranchi" output2.html>raw.html
grep "mp3" raw.html>raw2.html

grep -o 'Hindi-.*\.mp3' raw2.html>raw3.html



#Open html
echo '<html>
<head>
  <title>Audio Display</title>
</head>
<body>
  <table border="1">
    <tr>
      <th>Audio</th>
      <th>Audio Name</th>
    </tr>'>air-ran.html



# Assuming the file name is 'input_file.txt'
input_file="raw3.html"

# Get the number of lines in the input file
num_lines=$(wc -l < "$input_file")

# Loop through each line and echo them
for ((i = 1; i <= num_lines; i++)); do

echo "<tr>
      <td>
		 $(sed -n "${i}p" raw2.html)
	   </td>
      <td>
		  $(sed -n "${i}p" raw3.html)
	  </td>
</tr>">>air-ran.html

done


echo '</table>
<div><a href="https://newsonair.gov.in/regional-audio.aspx" target="_blank">Link to all air regional audio</a>
</div>
</body>
</html>'>>air-ran.html


rm -rf output.html output2.html raw.html raw2.html raw3.html

open air-ran.html
