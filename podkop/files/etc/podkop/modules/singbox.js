import { execCommand } from './utils.js';
import { logger } from './logger.js';
import fs from 'fs/promises';

export class SingboxManager {
    constructor() {
        this.configPath = '/etc/sing-box/config.json';
    }

    async configure(config) {
        const { mode, proxy_string, yacd, socks5 } = config.main;
        const { second_enable, second_mode, second_proxy_string } = config.second || {};

        let baseConfig;
        if (proxy_string.startsWith('vless://')) {
            baseConfig = await this.configureVless(this.parseVlessUrl(proxy_string));
        } else if (proxy_string.startsWith('ss://')) {
            baseConfig = await this.configureShadowsocks(this.parseShadowsocksUrl(proxy_string));
        }

        // Add Yacd dashboard if enabled
        if (yacd === '1') {
            baseConfig.experimental = {
                clash_api: {
                    external_ui: "ui",
                    external_controller: "0.0.0.0:9090"
                }
            };
        }

        // Add Socks5 if enabled
        if (socks5 === '1') {
            baseConfig.inbounds.push({
                type: "mixed",
                listen: "0.0.0.0",
                listen_port: 2080,
                set_system_proxy: false
            });
        }

        // Configure second proxy if enabled
        if (second_enable === '1' && second_proxy_string) {
            let secondOutbound;
            if (second_proxy_string.startsWith('vless://')) {
                secondOutbound = (await this.configureVless(this.parseVlessUrl(second_proxy_string), true)).outbounds[0];
            } else if (second_proxy_string.startsWith('ss://')) {
                secondOutbound = (await this.configureShadowsocks(this.parseShadowsocksUrl(second_proxy_string), true)).outbounds[0];
            }
            baseConfig.outbounds.push(secondOutbound);
        }

        return baseConfig;
    }

    async configureShadowsocks(config, isOutboundOnly = false) {
        const outbound = {
            type: 'shadowsocks',
            server: config.host,
            server_port: parseInt(config.port),
            method: config.method,
            password: config.password,
            udp_over_tcp: {
                enabled: true,
                version: 2
            }
        };

        if (config.tag) {
            outbound.tag = config.tag;
        }

        if (isOutboundOnly) {
            return { outbounds: [outbound] };
        }

        return {
            log: { level: 'warn' },
            inbounds: [{
                type: 'tproxy',
                listen: '::',
                listen_port: parseInt(config.listenPort || 1602),
                sniff: false
            }],
            outbounds: [outbound],
            route: {
                auto_detect_interface: true
            }
        };
    }

    async configureVless(config, isOutboundOnly = false) {
        const outbound = {
            type: 'vless',
            server: config.host,
            server_port: parseInt(config.port),
            uuid: config.uuid,
            flow: config.flow || 'xtls-rprx-vision',
            tls: {
                enabled: true,
                insecure: false,
                server_name: config.sni,
                utls: {
                    enabled: true,
                    fingerprint: config.fp || 'chrome'
                },
                reality: {
                    enabled: true,
                    public_key: config.pbk,
                    short_id: config.sid
                }
            }
        };

        if (config.tag) {
            outbound.tag = config.tag;
        }

        if (isOutboundOnly) {
            return { outbounds: [outbound] };
        }

        return {
            log: { level: 'warn' },
            inbounds: [{
                type: 'tproxy',
                listen: '::',
                listen_port: parseInt(config.listenPort || 1602),
                sniff: false
            }],
            outbounds: [outbound],
            route: {
                auto_detect_interface: true
            }
        };
    }

    async writeConfig(config) {
        await fs.writeFile(this.configPath, JSON.stringify(config, null, 2));
    }

    async restart() {
        await execCommand('/etc/init.d/sing-box restart');
        await execCommand('/etc/init.d/sing-box enable');
    }

    parseVlessUrl(url) {
        const [_, __, uuid, serverPart] = url.split('/');
        const [server, paramString] = serverPart.split('?');
        const [host, port] = server.split(':');

        const params = new URLSearchParams(paramString);

        return {
            uuid,
            host,
            port,
            type: params.get('type'),
            flow: params.get('flow'),
            sni: params.get('sni'),
            fp: params.get('fp'),
            pbk: params.get('pbk'),
            sid: params.get('sid'),
            security: params.get('security')
        };
    }

    parseShadowsocksUrl(url) {
        const [_, __, encoded] = url.split('/');
        const [serverPart, tag] = encoded.split('#');
        const [auth, server] = serverPart.split('@');
        const [host, port] = server.split(':');

        const decoded = atob(auth);
        const [method, password] = decoded.split(':');

        return {
            host,
            port: parseInt(port),
            method,
            password,
            tag
        };
    }
}

export const singBoxManager = new SingboxManager();