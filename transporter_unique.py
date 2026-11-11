"""
Purpose
-------
Find files in the Mac's Documents directory that are not already present in
the Synology Drive directory, based on file contents rather than filenames.

Source:
    /Users/Mike/Documents

Destination:
    /Volumes/home/Synology Drive

How it works
------------
1. Recursively scans all files in Synology Drive and creates a SHA-256 hash
   index of their contents.
2. Recursively scans all files in Documents.
3. For each Documents file, compares its SHA-256 hash against the
   files already in Synology Drive.
4. Identical files are considered duplicates, even if they have
   different filenames or are located in different folders.
5. Files that are not already present in Synology Drive are identified
   as unique.
6. Files that are unique are copied to Synology Drive while preserving
   their folder structure relative to Documents.

Safety
------
The script does not delete or modify any files in Documents.

The script is initially run as a DRY RUN. It only reports which files
would be copied and makes no changes.

After reviewing the dry-run results, run the script with the --copy
option to actually copy the unique files.

If Synology Drive is unavailable, the script stops without copying files.

If a file with the same relative path already exists in Synology Drive but
has different contents, the script will NOT overwrite it. Instead, it
will report a conflict and skip that file.

Usage
-----
Dry run (recommended first):
    python3 ~/transporter_unique.py

Actual copy, after reviewing the dry-run results:
    python3 ~/transporter_unique.py --copy

The dry run should always be reviewed before performing the copy.
"""

import os
import sys
import hashlib
import shutil

SOURCE = "/Users/Mike/Documents"
DEST = "/Volumes/home/Synology Drive"


def file_hash(path):
    """Return the SHA-256 hash of a file."""
    h = hashlib.sha256()

    with open(path, "rb") as f:
        while True:
            chunk = f.read(1024 * 1024)
            if not chunk:
                break
            h.update(chunk)

    return h.hexdigest()


# ----------------------------------------------------------------------
# Check command-line option
# ----------------------------------------------------------------------

DO_COPY = "--copy" in sys.argv


# ----------------------------------------------------------------------
# Build an index of all files already in Synology Drive
# ----------------------------------------------------------------------

if not os.path.isdir(DEST):
    sys.exit(f"ERROR: Synology Drive directory is unavailable: {DEST}")

print("Indexing Synology Drive...")
print()

dest_hashes = {}

for root, dirs, files in os.walk(DEST):
    for name in files:
        path = os.path.join(root, name)

        try:
            h = file_hash(path)
            dest_hashes[h] = path
        except (PermissionError, OSError) as e:
            print(f"Could not read: {path}")
            print(f"  {e}")

print(f"Found {len(dest_hashes)} unique file contents in Synology Drive.")
print()


# ----------------------------------------------------------------------
# Find Documents files that aren't already in Synology Drive
# ----------------------------------------------------------------------

unique_files = []
conflicts = []

print("Checking Documents...")
print()

for root, dirs, files in os.walk(SOURCE):
    for name in files:
        source_path = os.path.join(root, name)

        try:
            h = file_hash(source_path)
        except (PermissionError, OSError) as e:
            print(f"Could not read: {source_path}")
            print(f"  {e}")
            continue

        # File contents already exist somewhere in Synology Drive
        if h in dest_hashes:
            continue

        # Preserve the Documents folder structure
        relative = os.path.relpath(source_path, SOURCE)
        dest_path = os.path.join(DEST, relative)

        # Don't overwrite a different file at the same destination path
        if os.path.exists(dest_path):
            conflicts.append((source_path, dest_path))
        else:
            unique_files.append((source_path, dest_path))


# ----------------------------------------------------------------------
# Report results
# ----------------------------------------------------------------------

print("=" * 70)
print(f"Unique files to copy: {len(unique_files)}")
print(f"Conflicts skipped:    {len(conflicts)}")
print("=" * 70)
print()

if unique_files:
    print("Files that will be copied:")
    print()

    for source, dest in unique_files:
        print(f"{source}")
        print(f"  -> {dest}")
        print()

if conflicts:
    print()
    print("=" * 70)
    print("CONFLICTS -- these files were NOT copied:")
    print("=" * 70)
    print()

    for source, dest in conflicts:
        print(f"Documents:      {source}")
        print(f"Synology Drive: {dest}")
        print()


# ----------------------------------------------------------------------
# Dry run
# ----------------------------------------------------------------------

if not DO_COPY:
    print("=" * 70)
    print("DRY RUN -- NOTHING WAS COPIED")
    print("=" * 70)
    print()
    print("If the results look correct, run:")
    print()
    print("    python3 ~/transporter_unique.py --copy")
    print()

    sys.exit()


# ----------------------------------------------------------------------
# Perform the copy
# ----------------------------------------------------------------------

if not unique_files:
    print("Nothing needs to be copied.")
    sys.exit()

print("=" * 70)
print("COPYING FILES")
print("=" * 70)
print()

copied = 0

for source, dest in unique_files:
    try:
        # Create destination folder if necessary
        os.makedirs(os.path.dirname(dest), exist_ok=True)

        shutil.copy2(source, dest)

        print(f"Copied: {source}")
        print(f"     -> {dest}")
        print()

        copied += 1

    except (PermissionError, OSError) as e:
        print(f"ERROR copying: {source}")
        print(f"  {e}")
        print()


print("=" * 70)
print(f"Finished. {copied} of {len(unique_files)} files copied.")
print(f"{len(conflicts)} conflicts skipped.")
print("=" * 70)
