// modules/service.js
import { execCommand } from './utils.js';
import { logger } from './logger.js';

export class ServiceManager {
    async updateLists(config) {
        const {
            domain_list_enabled,
            domain_list,
            custom_domains,
            custom_download_domains,
            subnets_list_enabled,
            custom_subnets_list_enabled,
            custom_download_subnets_list_enabled
        } = config.main;

        if (domain_list_enabled === '1') {
            await this.updateDomainList(domain_list);
        }

        if (custom_domains?.length) {
            await this.updateCustomDomains(custom_domains);
        }

        if (custom_download_domains?.length) {
            await this.downloadCustomDomains(custom_download_domains);
        }

        if (subnets_list_enabled === '1') {
            await this.updateSubnetsList(config.main.subnets);
        }

        if (custom_download_subnets_list_enabled === '1') {
            await this.downloadCustomSubnets(config.main.custom_download_subnets);
        }
    }

    async updateDomainList(listType) {
        const urls = {
            'ru_inside': 'https://raw.githubusercontent.com/itdoginfo/allow-domains/main/Russia/inside-dnsmasq-nfset.lst',
            'ru_outside': 'https://raw.githubusercontent.com/itdoginfo/allow-domains/main/Russia/outside-dnsmasq-nfset.lst',
            'ua': 'https://raw.githubusercontent.com/itdoginfo/allow-domains/main/Ukraine/inside-dnsmasq-nfset.lst'
        };

        const url = urls[listType];
        if (!url) {
            logger.error('Invalid domain list type');
            return;
        }

        try {
            await execCommand(`curl -f ${url} --output /tmp/dnsmasq.d/podkop-domains.lst`);
            await execCommand(`sed -i 's/fw4#vpn_domains/PodkopTable#podkop_domains/g' /tmp/dnsmasq.d/podkop-domains.lst`);
        } catch (error) {
            logger.error(`Failed to update domain list: ${error.message}`);
        }
    }

    async updateCustomDomains(domains) {
        try {
            for (const domain of domains) {
                await execCommand(`echo "nftset=/${domain}/4#inet#PodkopTable#podkop_domains" >> /tmp/dnsmasq.d/podkop-custom-domains.lst`);
            }
        } catch (error) {
            logger.error(`Failed to update custom domains: ${error.message}`);
        }
    }

    async downloadCustomDomains(urls) {
        try {
            for (const url of urls) {
                const filename = url.split('/').pop();
                await execCommand(`curl -f "${url}" --output "/tmp/podkop/${filename}"`);
                await execCommand(`while IFS= read -r domain; do echo "nftset=/$domain/4#inet#PodkopTable#podkop_domains" >> /tmp/dnsmasq.d/podkop-${filename}.lst; done < "/tmp/podkop/${filename}"`);
            }
        } catch (error) {
            logger.error(`Failed to download custom domains: ${error.message}`);
        }
    }
}

export const serviceManager = new ServiceManager();
