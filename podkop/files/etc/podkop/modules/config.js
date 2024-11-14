// modules/config.js
import { execCommand } from './utils.js';

export class ConfigManager {
    async load() {
        try {
            const mainConfig = await this.loadSection('podkop', 'main');
            const secondConfig = await this.loadSection('podkop', 'second');

            return {
                main: mainConfig,
                second: secondConfig
            };
        } catch (error) {
            throw new Error(`Failed to load config: ${error.message}`);
        }
    }

    async loadSection(package_name, section) {
        const result = await execCommand(`uci show ${package_name}.${section}`);
        const config = {};

        result.split('\n').forEach(line => {
            if (!line) return;
            const [key, value] = line.split('=');
            const option = key.split('.')[2];
            const cleanValue = value.replace(/'/g, '');

            if (option.startsWith('custom_') && option.endsWith('[]')) {
                const listName = option.slice(0, -2);
                config[listName] = config[listName] || [];
                config[listName].push(cleanValue);
            } else {
                config[option] = cleanValue;
            }
        });

        return config;
    }
}

export const configManager = new ConfigManager();