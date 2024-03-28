on run argv
    set noteName to ("PR " & item 1 of argv)
    set stdin to do shell script "cat 0<&3"
    tell application "Notes"
        tell folder "API Stewardship"
            if not exists note noteName then
                # Wrap the title in <h1> to get title format
                set noteBody to "<body><h1 style=\"font-size:20;\">" & noteName & "</h1>" & stdin & "</body>"
                make new note with properties {body:noteBody}
            end if
            show note noteName separately true
        end tell
    end tell
end run