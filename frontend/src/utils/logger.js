import pino from 'pino';

// Enhanced browser-friendly logger configuration with better console output
const logger = pino({
  browser: {
    asObject: true,
    write: {
      info: (obj) => {
        console.group(`🔵 ${obj.msg}`);
        console.log('Component:', obj.component);
        console.log('Level:', obj.level);
        console.log('Time:', obj.time);
        if (obj.data) console.log('Data:', obj.data);
        console.groupEnd();
      },
      warn: (obj) => {
        console.group(`🟡 ${obj.msg}`);
        console.log('Component:', obj.component);
        console.log('Level:', obj.level);
        console.log('Time:', obj.time);
        if (obj.data) console.log('Data:', obj.data);
        console.groupEnd();
      },
      error: (obj) => {
        console.group(`🔴 ${obj.msg}`);
        console.log('Component:', obj.component);
        console.log('Level:', obj.level);
        console.log('Time:', obj.time);
        if (obj.data) console.log('Data:', obj.data);
        console.groupEnd();
      },
      debug: (obj) => {
        console.group(`🟢 ${obj.msg}`);
        console.log('Component:', obj.component);
        console.log('Level:', obj.level);
        console.log('Time:', obj.time);
        if (obj.data) console.log('Data:', obj.data);
        console.groupEnd();
      }
    }
  },
  level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
  base: {
    env: process.env.NODE_ENV,
    version: process.env.npm_package_version,
    app: 'chainedsocial'
  },
  formatters: {
    level: (label) => {
      return { level: label };
    },
    log: (object) => {
      return {
        ...object,
        data: object.data || object
      };
    }
  },
  timestamp: pino.stdTimeFunctions.isoTime
});

// Create child loggers for different components with enhanced formatting
export const createLogger = (component) => {
  return logger.child({ 
    component,
    // Add component-specific styling
    componentIcon: getComponentIcon(component)
  });
};

// Helper function to get component icons
function getComponentIcon(component) {
  const icons = {
    'Profile': '👤',
    'AuthContext': '🔐',
    'useLogin': '🔑',
    'Header': '📋',
    'PostForm': '📝',
    'PostList': '📰',
    'HeroSection': '🎯',
    'AuthUI': '🛡️',
    'PostingInterface': '✍️'
  };
  return icons[component] || '🔧';
}

// Export the main logger
export default logger; 