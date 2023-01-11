Assessment Question:
Create a shared wallet that will hold funds in ETH and that can be funded by an admin. The admin will provide an allowance to a few users , and authorises only them,  who can then spend it as per their allowance and till a certain time limit set by the admin. whenever that limit is exceeding, it should raise an event and remove the authorization for that user.

Deployed contract at https://goerli.etherscan.io/tx/0x106ad884995a037edace89e509b0f2050f7c8da09367c66f03bc31a9e7e9c260

Verifed and Updated code https://goerli.etherscan.io/address/0x6189141a1d969af6139828b3c28bf85d82ec27a1#code

Also added a ChainLink Automation to trigger the `checkExpirations` at https://automation.chain.link/goerli/48637310309027712560333262266934760885929550293011769571029981860274378404071
which will called for every three hours to check the time limit if reached then removing the user to authoize the wallet