import { exec } from 'child_process';
import { promisify } from 'util';

export const execCommand = async (cmd) => {
    try {
        const { stdout, stderr } = await promisify(exec)(cmd);
        if (stderr) {
            throw new Error(stderr);
        }
        return stdout.trim();
    } catch (error) {
        throw new Error(`Command failed: ${cmd}\n${error.message}`);
    }
};