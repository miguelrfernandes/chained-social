# Chained Social

A decentralized social media platform built on the Internet Computer (ICP). This project features a modular backend architecture with user management, content system, social graph, governance, and monetization canisters.

## Project Overview

Chained Social is a comprehensive social media platform that leverages the Internet Computer's capabilities to provide a truly decentralized social experience. The platform includes features for user authentication, content creation, social interactions, community governance, and creator monetization.

## Project structure
`sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"`
`pnpm add -g ic-mops`

```
dfx start --background
```

### 3. Create a local developer identity.

To manage your project's canisters, it is recommended that you create a local [developer identity](https://internetcomputer.org/docs/building-apps/getting-started/identities) rather than use the `dfx` default identity that is not stored securely.

To create a new identity, run the commands:

```

dfx identity new IDENTITY_NAME

dfx identity use IDENTITY_NAME

```

Replace `IDENTITY_NAME` with your preferred identity name. The first command `dfx start --background` starts the local `dfx` processes, then `dfx identity new` will create a new identity and return your identity's seed phase. Be sure to save this in a safe, secure location.

The third command `dfx identity use` will tell `dfx` to use your new identity as the active identity. Any canister smart contracts created after running `dfx identity use` will be owned and controlled by the active identity.

Your identity will have a principal ID associated with it. Principal IDs are used to identify different entities on ICP, such as users and canisters.

[Learn more about ICP developer identities](https://internetcomputer.org/docs/building-apps/getting-started/identities).

### 4. Deploy the project locally.

Deploy your project to your local developer environment with:

```
npm install
dfx generate
dfx deploy

```

Your project will be hosted on your local machine. The local canister URLs for your project will be shown in the terminal window as output of the `dfx deploy` command. You can open these URLs in your web browser to view the local instance of your project.

### 5. Obtain cycles.

To deploy your project to the mainnet for long-term public accessibility, first you will need [cycles](https://internetcomputer.org/docs/building-apps/getting-started/tokens-and-cycles). Cycles are used to pay for the resources your project uses on the mainnet, such as storage and compute.

> This cost model is known as ICP's [reverse gas model](https://internetcomputer.org/docs/building-apps/essentials/gas-cost), where developers pay for their project's gas fees rather than users pay for their own gas fees. This model provides an enhanced end user experience since they do not need to hold tokens or sign transactions when using a dapp deployed on ICP.

> Learn how much a project may cost by using the [pricing calculator](https://internetcomputer.org/docs/building-apps/essentials/cost-estimations-and-examples).

Cycles can be obtained through [converting ICP tokens into cycles using `dfx`](https://internetcomputer.org/docs/building-apps/developer-tools/dfx/dfx-cycles#dfx-cycles-convert).

### 6. Deploy to the mainnet.

Once you have cycles, run the command:

```

dfx deploy --network ic

```

After your project has been deployed to the mainnet, it will continuously require cycles to pay for the resources it uses. You will need to [top up](https://internetcomputer.org/docs/building-apps/canister-management/topping-up) your project's canisters or set up automatic cycles management through a service such as [CycleOps](https://cycleops.dev/).

> If your project's canisters run out of cycles, they will be removed from the network.

## Planned Backend Architecture (ICP Canisters)

This project will use a modular backend architecture on the Internet Computer, with the following canisters:

- **User Management Canister:** Handles profile creation, authentication, and identity verification
- **Content System Canister:** Manages posts, comments, media uploads, and content moderation
- **Social Graph Canister:** Controls connections, follows, and social interactions
- **Governance Canister:** Implements DAO voting, proposals, and community decisions
- **Monetization Canister:** Manages token rewards, creator payments, and tip system

**First step:** Authentication — Internet Identity integration

## Additional examples

Additional code examples and sample applications can be found in the [DFINITY examples repo](https://github.com/dfinity/examples).
