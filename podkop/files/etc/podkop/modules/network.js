// modules/network.js
import { execCommand } from './utils.js';
import { logger } from './logger.js';

export class NetworkManager {
    async initialize() {
        await this.createNftTable();
    }

    async createNftTable() {
        try {
            await execCommand('nft add table inet PodkopTable');
            await execCommand('nft add chain inet PodkopTable mangle { type filter hook prerouting priority -150 \\; policy accept \\;}');
        } catch (error) {
            logger.error(`Failed to create nft table: ${error.message}`);
        }
    }

    async addMarking() {
        try {
            const rules = await execCommand('ip rule list');
            if (!rules.includes('0x105 lookup podkop')) {
                await execCommand('ip -4 rule add fwmark 0x105 table podkop priority 105');
            }
        } catch (error) {
            logger.error(`Failed to add marking: ${error.message}`);
        }
    }

    async addAllTrafficRules(ips) {
        if (!Array.isArray(ips)) return;

        for (const ip of ips) {
            try {
                await execCommand(`nft insert rule inet PodkopTable mangle ip saddr ${ip} meta mark set 0x105 counter`);
            } catch (error) {
                logger.error(`Failed to add traffic rule for IP ${ip}: ${error.message}`);
            }
        }
    }

    async addExcludeRules(ips) {
        if (!Array.isArray(ips)) return;

        for (const ip of ips) {
            try {
                await execCommand(`nft insert rule inet PodkopTable mangle ip saddr ${ip} return`);
            } catch (error) {
                logger.error(`Failed to add exclude rule for IP ${ip}: ${error.message}`);
            }
        }
    }

    async excludeNtp() {
        try {
            await execCommand('nft insert rule inet PodkopTable mangle udp dport 123 return');
        } catch (error) {
            logger.error(`Failed to exclude NTP: ${error.message}`);
        }
    }
}

export const networkManager = new NetworkManager();