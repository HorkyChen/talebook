#!/bin/python3
import os
import subprocess

current_dir = os.getcwd()


for filename in os.listdir(current_dir):
    if filename.lower().endswith('.epub'):
        epub_path = os.path.join(current_dir, filename)
        azw3_filename = os.path.splitext(filename)[0] + '.azw3'
        azw3_path = os.path.join(current_dir, azw3_filename)

        try:
            subprocess.run(['ebook-convert', epub_path, azw3_path,
                            '--output-profile=kindle_pw3',
                            '--extra-css=body{font-family:inherit;}',
                            '--enable-heuristics'],
                            check=True)
            print(f"转换成功: {azw3_path}")
        except subprocess.CalledProcessError as e:
            print(f"转换失败: {epub_path}")
