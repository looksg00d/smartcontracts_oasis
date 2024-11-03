# King of the Hill - Oasis Sapphire Project

## Description
King of the Hill is a DApp built on Oasis Sapphire that implements a competitive token-based game system. The project utilizes the Oasis Privacy Layer (OPL) and integrates with the OCEAN token ecosystem.

## Oasis Integration
- Built on Sapphire ParaTime
- Uses Oasis Privacy Layer (OPL)
- Integrates with OCEAN token contract

## Technical Implementation
The project consists of two main smart contracts:

### Nicknames Contract
- Custom nickname system with validation
- Username-to-address mapping
- Address-to-username mapping
- Validation rules for nicknames (3-16 characters, letters, numbers, underscore)

### KingOfTheHill Contract
- OCEAN token integration for betting system
- Time-based king tracking system
- Message system for player communication
- Automated reward distribution (7-day intervals)
- Commission system (5% of pool)
- Reward distribution:
  - 1st place: 50%
  - 2nd place: 30%
  - 3rd place: 15%


## Environment Setup
Clone the repository:
git clone [your repository URL]

cd [project-name]

Install dependencies:
npm install

Create `.env` file in the root directory:
PRIVATE_KEY=your_private_key (without 0x)