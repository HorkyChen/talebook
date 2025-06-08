import psutil

def is_process_running_with_string(search_string):
    for process in psutil.process_iter(['cmdline']):
        try:
            cmdline = process.info['cmdline']
            if cmdline and any(search_string in arg for arg in cmdline):
                print("Found process with string '%s': PID %s", search_string, process.pid)
                return True
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass
    print("No process found with string '%s'", search_string)
    return False


if __name__ == "__main__":
    search_string = ".vscode"
    if is_process_running_with_string(search_string):
        print(f"Process with string '{search_string}' is running.")
    else:
        print(f"No process with string '{search_string}' is running.")
