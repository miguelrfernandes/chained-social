import pino from 'pino';

// Create a browser-friendly logger configuration
const logger = pino({
  browser: {
    asObject: true
  },
  level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
  base: {
    env: process.env.NODE_ENV,
    version: process.env.npm_package_version
  },
  formatters: {
    level: (label) => {
      return { level: label };
    }
  },
  timestamp: pino.stdTimeFunctions.isoTime
});

// Create child loggers for different components
export const createLogger = (component) => {
  return logger.child({ component });
};

// Export the main logger
export default logger; 