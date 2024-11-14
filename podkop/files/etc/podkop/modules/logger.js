export class Logger {
    info(message) {
        const timestamp = new Date().toISOString();
        console.log(`\x1b[36m[${timestamp}]\x1b[0m \x1b[32m${message}\x1b[0m`);
        this.syslog(message);
    }

    error(message) {
        const timestamp = new Date().toISOString();
        console.error(`\x1b[36m[${timestamp}]\x1b[0m \x1b[31mERROR: ${message}\x1b[0m`);
        this.syslog(`ERROR: ${message}`);
    }

    async syslog(message) {
        try {
            await execCommand(`logger -t "podkop" "${message}"`);
        } catch (error) {
            console.error('Failed to write to syslog:', error);
        }
    }
}

export const logger = new Logger();