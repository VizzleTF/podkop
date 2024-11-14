// modules/dns.js
import { execCommand } from './utils.js';
import { logger } from './logger.js';

export class DnsManager {
    async configureDnsmasq() {
        try {
            const hasNftset = await this.checkDnsmasqCapabilities();
            if (!hasNftset) {
                logger.info('Dnsmasq-full is not installed. Feature: link only');
                return;
            }
        } catch (error) {
            logger.error(`Failed to configure dnsmasq: ${error.message}`);
        }
    }

    async checkDnsmasqCapabilities() {
        try {
            const result = await execCommand('/usr/sbin/dnsmasq -v');
            return !result.includes('no-nftset');
        } catch (error) {
            return false;
        }
    }

    async restartDnsmasq() {
        try {
            await execCommand('/etc/init.d/dnsmasq restart');
        } catch (error) {
            logger.error(`Failed to restart dnsmasq: ${error.message}`);
        }
    }
}

export const dnsManager = new DnsManager();

// modules/route.js
import { execCommand } from './utils.js';
import { logger } from './logger.js';

export class RouteManager {
    async initialize() {
        await this.ensureRouteTables();
    }

    async ensureRouteTables() {
        try {
            const tables = await execCommand('cat /etc/iproute2/rt_tables');
            if (!tables.includes('105 podkop')) {
                await execCommand('echo "105 podkop" >> /etc/iproute2/rt_tables');
            }
            if (!tables.includes('106 podkop2')) {
                await execCommand('echo "106 podkop2" >> /etc/iproute2/rt_tables');
            }
        } catch (error) {
            logger.error(`Failed to ensure route tables: ${error.message}`);
        }
    }

    async createTables() {
        // Implementation for creating routing tables
    }

    async addRouteInterface(interface_name, table) {
        try {
            const interfaceExists = await execCommand(`ip link show ${interface_name}`);
            if (!interfaceExists) {
                logger.error(`Interface ${interface_name} does not exist`);
                return;
            }

            const routeExists = await execCommand(`ip route show table ${table}`);
            if (routeExists.includes('default dev')) {
                logger.info(`Route for ${interface_name} exists`);
                return;
            }

            let retries = 0;
            while (retries < 10) {
                try {
                    await execCommand(`ip route add table ${table} default dev ${interface_name}`);
                    logger.info(`Route added for ${interface_name}`);
                    return;
                } catch (error) {
                    if (error.message.includes('Network is down')) {
                        retries++;
                        await new Promise(resolve => setTimeout(resolve, 3000));
                    } else {
                        throw error;
                    }
                }
            }
            throw new Error('Maximum retries exceeded');
        } catch (error) {
            logger.error(`Failed to add route interface: ${error.message}`);
        }
    }
}

export const routeManager = new RouteManager();