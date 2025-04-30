#!/bin/bash

input_dir=""
output_dir=""
max_depth=""

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --max_depth)
            max_depth="$2"
            shift 2
            ;;
        *)
            if [[ -z "$input_dir" ]]; then
                input_dir="$1"
            elif [[ -z "$output_dir" ]]; then
                output_dir="$1"
            else
                exit 1
            fi
            shift
            ;;
    esac
done

python3 - "$input_dir" "$output_dir" "$max_depth" << EOF
import sys
import os
import shutil

def copy_files_with_depth(src, dst, max_depth=None, current_depth=0):
    if max_depth is not None and current_depth > max_depth:
        return

    os.makedirs(dst, exist_ok=True)

    for item in os.listdir(src):
        src_path = os.path.join(src, item)
        dst_path = os.path.join(dst, item)

        if os.path.isdir(src_path):
            copy_files_with_depth(src_path, dst_path, max_depth, current_depth + 1)
        else:
            shutil.copy2(src_path, dst_path)

if __name__ == "__main__":
    input_dir = sys.argv[1]
    output_dir = sys.argv[2]
    max_depth = int(sys.argv[3]) if len(sys.argv) > 3 and sys.argv[3] else None

    copy_files_with_depth(input_dir, output_dir, max_depth)
EOF