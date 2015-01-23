gci env:\ |% {
    write-output "$($_.Name)=$($_.Value)"
}