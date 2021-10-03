from decimal import Decimal
from brownie import network, config, accounts, MockV3Aggregator
from web3 import Web3

LOCAK_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]
DECIMALS = 8
STARTING_PRICE = 2000

def get_account():
    if network.show_active() in LOCAK_BLOCKCHAIN_ENVIRONMENTS:
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    print("deploying mocks")

    # deploy a mock aggregator only if one does not exist
    if len(MockV3Aggregator) <= 0:
        print("no MockV3Aggregator")
        agg = MockV3Aggregator.deploy(DECIMALS, Web3.toWei(STARTING_PRICE, "ether"), {"from": get_account()})
        print(f"latest round data {agg.latestRoundData()}")
    print("Mocks deployed")
