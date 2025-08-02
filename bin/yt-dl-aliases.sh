# youtube-dl alias
mp3 () {
    yt-dlp --embed-thumbnail --add-metadata -f bestaudio --extract-audio --audio-format mp3 -o '~/Music/yt-dl/%(title)s.%(ext)s' "$1"
}

mp3p () {
    yt-dlp --sleep-interval 3 --embed-thumbnail --add-metadata -f bestaudio --extract-audio --audio-format best -o '~/Music/yt-dl/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' "$1"
}

mp3 https://youtu.be/2RgKVk1M9M0?list=PL65E33789AA7052BC
