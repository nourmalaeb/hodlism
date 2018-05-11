from cmd import Cmd
import time
from time import sleep
import datetime
import hashlib
import subprocess
import signal, os
import sys
import csv

def handler(signum, frame):
    """Handles ctrl-c calls."""
    print("Satoshi will remember this sin...")
    return

# Echo server program
import socket

HOST = ''                 # Symbolic name meaning all available interfaces
PORT = 50008              # Arbitrary non-privileged port
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
s.listen(1)
conn, addr = s.accept()
print 'Connected by', addr
#while 1:
#    data = conn.recv(1024)
#    if not data: break
#    conn.sendall(data)
#conn.close()


def checkPrayer(prayer):
    now = datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d_%H:%M:%S')
    """Checks if a hashed version of prayer unlocks genesis block."""

    conn.sendall(prayer)

    seed = str(int(hashlib.sha256(prayer + now).hexdigest(), 16))
    # uses the ku utility to generate an address given a key
    output = subprocess.check_output("ku -au " + seed, shell=True)[:-1]

    with open('prayers.csv', 'a') as csvfile:
        fieldnames = ['timestamp', 'prayer_seed', 'public_key']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writerow({'timestamp': now, 'prayer_seed': prayer, 'public_key': output})

    sys.stdout.write("\nAttempting to unlock the genesis block: ")
    sys.stdout.flush()
    for char in output:
        sleep(.25)
        sys.stdout.write(char)
        sys.stdout.flush()
    sleep(2.5)
    for char in prayer:
        sleep(.25)
    if output == '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa':
        return "You've found the key to the Genesis Block!: " + output
    else:
        conn.sendall("HODL HARDER                qpqpqp")
        return  """\n\nI\'m sorry my child
You are not the chosen one
Have more faith in the HODL
Spread the good word of decentralization\n"""


# Set the signal handler
class MyPrompt(Cmd):

    def emptyline(self):
        return

    def default(self, args):
        """Checks prayer by default"""
        print checkPrayer(args)
        # time before we clear the screen.
        sleep(5)
        os.system('clear')

    def do_12345quit(self, args):
        """Quits the program."""
        conn.close()
        print ("Quitting.")
        raise SystemExit


if __name__ == '__main__':
    signal.signal(signal.SIGINT, handler)
    prompt = MyPrompt()
    # this is reprinted every time.
    prompt.prompt = """Pray for our decentralized future\n
Whoso haveth the most faith
will pray the private key on chain
and unlock Satoshi\'s Genesis Block.\n\n""" + ' Enter thy prayer |> '
    prompt.cmdloop()
