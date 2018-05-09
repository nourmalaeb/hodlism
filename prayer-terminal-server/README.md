# Summary

A hacky version of Alex's Python 2.7 terminal application to check if a user can unlock the bitcoin genesis block. 

It takes the string, hashes it with Sha256, converts it into an `int`, and then uses that as a seed to generate a wallet using Pycoin's `ku` shell utility.

It also stores in memory all of the history prayers received by the system.

Nour added a simple server that sends the prayer to a Processing sketch.

## Running
To run:
1. `pip install -r requirements.txt`
1. `python console.py`

The server cannot be cancelled with `ctrl-C` calls. This is a sin.

## Commands

`|> {prayer}` : checks if a prayer can unlock the genesis wallet.
`|> prayers` : returns information on the prayers given to the system.
`|> quit` : quits the application.

