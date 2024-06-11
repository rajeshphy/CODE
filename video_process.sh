#!/bin/bash

echo "What do you want to do? (trim/merge/remove_audio/remove_video/merge_audio_to_video/reduce_video_mb)"
read action

case $action in
    trim)
        echo "Enter the input video file path:"
        read input_video
        echo "Enter the start time (format: HH:MM:SS):"
        read start_time
        echo "Enter the end time (format: HH:MM:SS):"
        read end_time
        echo "Enter the output video file path:"
        read output_video

        ffmpeg -i "./$input_video" -ss "$start_time" -to "$end_time" -c:v libx264 -c:a aac "./$output_video"
        echo "Video trimmed and saved to $output_video"
        ;;
    merge)
        echo "Enter the first video file path:"
        read first_video
        echo "Enter the second video file path:"
        read second_video
        echo "Enter the output file path:"
        read output_video

        echo "Converting videos to ensure same codec and format..."
        ffmpeg -i "./$first_video" -c:v libx264 -c:a aac -strict experimental "./0_$first_video"
        ffmpeg -i "./$second_video" -c:v libx264 -c:a aac -strict experimental "./0_$second_video"

        echo "Creating videos.txt file..."
        echo "file ./0_$first_video" > ./videos.txt
        echo "file ./0_$second_video" >> ./videos.txt

        echo "Merging videos..."
        ffmpeg -f concat -safe 0 -i ./videos.txt -c copy "./$output_video"

        echo "Videos merged and saved to output.mp4"
        ;;
    remove_audio)
        echo "Enter the input video file path:"
        read input_video
        echo "Enter the output video file path:"
        read output_video

        ffmpeg -i "./$input_video" -c copy -an "./$output_video"
        echo "Audio removed and saved to $output_video"
        ;;
    remove_video)
        echo "Enter the input video file path:"
        read input_video
        echo "Enter the output audio file path:"
        read output_audio

        ffmpeg -i "./$input_video" -q:a 0 -map a "./$output_audio"
        echo "Video removed and audio saved to $output_audio"
        ;;
    merge_audio_to_video)
        echo "Enter the input video file path:"
        read input_video
        echo "Enter the input audio file path:"
        read input_audio
        echo "Enter the output video file path:"
        read output_video

        ffmpeg -i "./$input_video" -i "./$input_audio" -c:v copy -c:a aac -strict experimental "./$output_video"
        echo "Audio merged to video and saved to $output_video"
        ;;
    reduce_video_mb)
        echo "Enter the input video file path:"
        read input_video
        echo "Enter the output video file path:"
        read output_video
        echo "Enter the desired size in megabytes (e.g., 50M):"
        read size
        echo "Enter the bitrate in k(e.g., 140k for 1M size of 1min duration). Multiply the factor 8388 with Size_M/Video_Duration_Second: "
        read b_rate
        ffmpeg -i "./$input_video" -b:v "$b_rate" -b:a 128k -fs "$size" "./$output_video"
        echo "Video size reduced and saved to $output_video"
        ;;
    *)
        echo "Invalid option selected. Exiting."
        ;;
esac

