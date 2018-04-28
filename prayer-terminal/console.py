from cmd import Cmd
import hashlib
import subprocess
import signal, os

prayers_list = []

def handler(signum, frame):
    """Handles ctrl-c calls."""
    print("Satoshi will remember this sin...")
    return 


def checkPrayer(prayer):
    """Checks if a hashed version of prayer unlocks genesis block."""
    global prayers_list
    prayers_list.append(prayer)
    seed = str(int(hashlib.sha256(prayer).hexdigest(), 16))
    # uses the ku utility to generate an address given a key
    output = subprocess.check_output("ku -au " + seed, shell=True)
    if output == '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa':
        return "You've found the key to the Genesis Block!: " + output
    else: 
        return  "Your seed: " + output + """\nI\'m sorry my child 
You are not the chosen one 
Have more faith in the HODL""" 
    
    
    #"You are not the chosen one: " + output


# Set the signal handler
class MyPrompt(Cmd):
    
    def default(self, args):
        """Checks prayer by default"""
        print checkPrayer(args) 

    def do_prayers(self, args):
        """All prayers"""
        global prayers_list
        print str(len(prayers_list)) + " prayers given\n " + str(prayers_list)

    def do_quit(self, args):
        """Quits the program."""
        print ("Quitting.")
        raise SystemExit


if __name__ == '__main__':    
    signal.signal(signal.SIGINT, handler)
    prompt = MyPrompt()
    prompt.prompt = 'Enter thy prayer |> '
    prompt.cmdloop("""Whoso haveth the most faith 
will pray the private key on chain 
and unlock Satoshi\'s Genesis Block.""")
