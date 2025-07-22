# Decentralized Water Rights and Conservation System

A blockchain-based water management system built on Stacks using Clarity smart contracts to ensure transparent, efficient, and equitable water resource allocation and conservation.

## System Overview

This system consists of five interconnected smart contracts that work together to manage water resources:

### 1. Water Usage Monitoring Contract (`water-usage-monitor.clar`)
- Tracks real-time water consumption for users and regions
- Enforces allocation limits and usage quotas
- Maintains historical usage data for analysis
- Provides alerts when approaching limits

### 2. Conservation Incentive Contract (`conservation-incentives.clar`)
- Rewards users for water-saving behaviors
- Implements tiered incentive programs
- Tracks conservation achievements
- Distributes rewards based on efficiency metrics

### 3. Quality Assurance Contract (`water-quality.clar`)
- Monitors water safety parameters across distribution networks
- Tracks contamination events and quality metrics
- Manages quality certifications and compliance
- Provides public access to water quality data

### 4. Cross-Jurisdictional Sharing Contract (`water-sharing.clar`)
- Manages water rights and sharing agreements between regions
- Facilitates water trading and allocation transfers
- Handles inter-regional water distribution
- Maintains transparent sharing records

### 5. Drought Response Automation Contract (`drought-response.clar`)
- Monitors reservoir levels and drought conditions
- Automatically implements water restrictions based on severity
- Manages emergency water allocation protocols
- Coordinates regional drought response efforts

## Key Features

- **Transparent Allocation**: All water rights and usage are recorded on-chain
- **Automated Enforcement**: Smart contracts automatically enforce limits and restrictions
- **Incentive Alignment**: Rewards conservation and efficient usage
- **Quality Assurance**: Continuous monitoring of water safety
- **Regional Cooperation**: Facilitates sharing between jurisdictions
- **Emergency Response**: Automated drought and crisis management

## Technical Architecture

### Data Structures
- User profiles with allocation limits and usage history
- Regional water reserves and distribution networks
- Quality monitoring stations and sensor data
- Conservation programs and reward structures
- Drought severity levels and response protocols

### Access Control
- Multi-level permissions for users, operators, and administrators
- Regional authority management
- Emergency override capabilities
- Public read access for transparency

### Economic Model
- Conservation rewards funded by usage fees
- Water trading mechanisms between regions
- Penalty system for overconsumption
- Emergency fund for drought response

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm
- Stacks wallet for testing

### Installation

1. Clone the repository
2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

3. Run tests:
   \`\`\`bash
   npm test
   \`\`\`

4. Deploy contracts:
   \`\`\`bash
   clarinet deploy
   \`\`\`

## Usage Examples

### Register as Water User
\`\`\`clarity
(contract-call? .water-usage-monitor register-user u1000000) ;; 1M gallon allocation
\`\`\`

### Record Water Usage
\`\`\`clarity
(contract-call? .water-usage-monitor record-usage u50000) ;; 50K gallons used
\`\`\`

### Check Conservation Rewards
\`\`\`clarity
(contract-call? .conservation-incentives get-user-rewards tx-sender)
\`\`\`

### Report Water Quality
\`\`\`clarity
(contract-call? .water-quality report-quality-reading u95 u7 u0) ;; pH 9.5, dissolved oxygen 7, contamination 0
\`\`\`

## Testing

The system includes comprehensive tests covering:
- Usage tracking and limit enforcement
- Conservation reward calculations
- Quality monitoring and alerts
- Cross-regional water sharing
- Drought response automation

Run tests with:
\`\`\`bash
npm test
\`\`\`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For questions or support, please open an issue in the repository.
