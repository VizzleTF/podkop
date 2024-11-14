// main.js
import { logger } from './modules/logger.js';
import { networkManager } from './modules/network.js';
import { configManager } from './modules/config.js';
import { serviceManager } from './modules/service.js';
import { dnsManager } from './modules/dns.js';
import { routeManager } from './modules/route.js';
import { singBoxManager } from './modules/singbox.js';
import { execCommand } from './modules/utils.js';

class RouterApp {
    constructor() {
        this.config = null;
    }

    async parseArgs() {
        const args = process.argv.slice(2);
        if (args[0] === '--update-lists') {
            await serviceManager.updateLists();
            return true;
        }
        if (args[0] === '--add-route' && args[1] && args[2]) {
            await routeManager.addRouteInterface(args[1], args[2]);
            return true;
        }
        return false;
    }

    async start() {
        try {
            if (await this.parseArgs()) {
                return;
            }

            await this.initialize();
            await this.startService();
            await this.setupCron();
        } catch (error) {
            logger.error(`Failed to start service: ${error.message}`);
            process.exit(1);
        }
    }

    async initialize() {
        this.config = await configManager.load();
        await networkManager.initialize();
        await routeManager.initialize();
    }

    async setupCron() {
        const { update_interval } = this.config.main;
        if (update_interval) {
            await execCommand(`(crontab -l | grep -v "/etc/init.d/podkop list_update") | crontab -`);
            await execCommand(`(crontab -l; echo "${update_interval} /etc/init.d/podkop list_update") | crontab -`);
        }
    }

    async startService() {
        const { mode, second_enable } = this.config.main;

        await dnsManager.configureDnsmasq();
        await routeManager.createTables();
        await networkManager.addMarking();

        switch (mode) {
            case 'vpn':
                await this.handleVpnMode();
                break;
            case 'proxy':
                await this.handleProxyMode();
                break;
            default:
                throw new Error('Invalid mode: requires vpn or proxy');
        }

        await serviceManager.updateLists(this.config);
        await this.handleTrafficRules();
    }

    async handleVpnMode() {
        logger.info('VPN mode');
        const { interface: mainInterface } = this.config.main;

        if (mainInterface) {
            await routeManager.addRouteInterface(mainInterface, 'podkop');
        }

        if (this.config.second?.second_enable === '1') {
            await this.handleSecondaryInterface();
        }
    }

    async handleProxyMode() {
        logger.info('Proxy mode');
        if (!await execCommand('which sing-box')) {
            throw new Error('Sing-box is not installed');
        }

        const config = await singBoxManager.configure(this.config);
        await singBoxManager.writeConfig(config);
        await singBoxManager.restart();
    }

    async handleTrafficRules() {
        const {
            all_traffic_from_ip_enabled,
            all_traffic_ip,
            exclude_from_ip_enabled,
            exclude_traffic_ip,
            exclude_ntp
        } = this.config.main;

        if (all_traffic_from_ip_enabled === '1') {
            await networkManager.addAllTrafficRules(all_traffic_ip);
        }

        if (exclude_from_ip_enabled === '1') {
            await networkManager.addExcludeRules(exclude_traffic_ip);
        }

        if (exclude_ntp === '1') {
            await networkManager.excludeNtp();
        }
    }
}

const app = new RouterApp();
app.start().catch(error => {
    logger.error(`Application failed to start: ${error.message}`);
    process.exit(1);
});