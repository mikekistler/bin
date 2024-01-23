on run argv
    set noteName to ("PR " & item 1 of argv)
    set theFile to (item 2 of argv) as string
    tell application "Notes"
        tell folder "API Stewardship"
            if not exists note noteName then
                set content to (read theFile)
                # Wrap the title in <h1> to get title format
                set noteBody to "<body><h1 style=\"font-size:20;\">" & noteName & "</h1>" & content & "</body>"
                make new note with properties {body:noteBody}
            end if
            show note noteName separately true
        end tell
    end tell
end run