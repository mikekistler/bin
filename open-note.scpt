# AppleScript to open a note in Notes.app. If the note doesn't exist, it will be created.
# Accept an optional argument with the name of the folder where the note should be created.
# If no argument is provided, the note will be created in the default folder.
# The folder name can be a nested folder using "//" as the delimiter
# Usage: osascript open-note.scpt "Note Title" ["Folder with //"]

on run argv
    set nameArg to (item 1 of argv) as string
    set folderArg to (item 2 of argv) as string
    set stdin to do shell script "cat 0<&3"
    MakeNewNote(nameArg, stdin, folderArg)
end run

on MakeNewNote(nameArg, plainBody, folderArg)
    if folderArg is missing value then set folderArg to "Notes"
    if plainBody is missing value then set plainBody to ""
    # "folders" is a keyword! who knew??
    set folderNames to splitText(folderArg, "//")
    tell application "Notes"
        set theContainer to folder (item 1 of folderNames)
        repeat with n from 2 to count of folderNames
            set theContainer to folder (item n of folderNames) of theContainer
        end repeat
        if not exists note nameArg of theContainer then
            # Wrap the title in <h1> to get title format
            set noteBody to "<body><h1 style=\"font-size:20;\">" & nameArg & "</h1>" & plainBody & "</body>"
            make new note at theContainer with properties {body:noteBody}
        end if
        show note nameArg of theContainer separately true
    end tell
end MakeNewNote

# The following script comes from the AppleScript docs at
# https://developer.apple.com/library/archive/documentation/LanguagesUtilities/Conceptual/MacAutomationScriptingGuide/ManipulateText.html#//apple_ref/doc/uid/TP40016239-CH33-SW6
on splitText(theText, theDelimiter)
    set AppleScript's text item delimiters to theDelimiter
    set theTextItems to every text item of theText
    set AppleScript's text item delimiters to ""
    return theTextItems
end splitText