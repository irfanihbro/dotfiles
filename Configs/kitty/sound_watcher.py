import subprocess
from pathlib import Path

SOUNDS = Path.home() / ".local/share/sounds"

def on_load(boss, data):
    subprocess.Popen(["pw-play", str(SOUNDS / "scifi-popup.wav")])

def on_close(boss, window, data):
    subprocess.Popen(["pw-play", str(SOUNDS / "scifi-close.wav")])
