import os
import hashlib
import shutil

SOURCE = "/Users/Mike/Transporter"
DEST = "/Users/Mike/Documents"

def file_hash(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(1024 * 1024):
            h.update(chunk)
    return h.hexdigest()

# Build a hash index of all files already in Documents
print("Indexing Documents...")
dest_hashes = {}

for root, dirs, files in os.walk(DEST):
    for name in files:
        path = os.path.join(root, name)
        try:
            dest_hashes[file_hash(path)] = path
        except (PermissionError, OSError) as e:
            print(f"Could not read: {path} ({e})")

print(f"Found {len(dest_hashes)} files in Documents.")

# Find Transporter files whose contents aren't already in Documents
unique_files = []

print("\nChecking Transporter...")

for root, dirs, files in os.walk(SOURCE):
    for name in files:
        source_path = os.path.join(root, name)

        try:
            h = file_hash(source_path)
        except (PermissionError, OSError) as e:
            print(f"Could not read: {source_path} ({e})")
            continue

        if h not in dest_hashes:
            relative = os.path.relpath(source_path, SOURCE)
            dest_path = os.path.join(DEST, relative)
            unique_files.append((source_path, dest_path))

print(f"\nFiles in Transporter NOT already in Documents: {len(unique_files)}")

if not unique_files:
    print("Nothing needs to be copied.")
    exit()

print("\nFiles that WOULD be copied:")
print("-" * 70)

for source, dest in unique_files:
    print(f"{source}")
    print(f"  -> {dest}")

print("\nDRY RUN ONLY -- nothing has been copied.")
print("Review the list above. If it looks correct, run the script with --copy.")
