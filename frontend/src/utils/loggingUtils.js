import { createLogger } from './logger.js';

// Enhanced logging utilities with better error handling and data formatting
export class LoggingUtils {
  constructor(component) {
    this.logger = createLogger(component);
    this.component = component;
  }

  // Log API calls with request/response data
  logApiCall(method, url, requestData = null, responseData = null, error = null) {
    if (error) {
      this.logger.error('API call failed', {
        method,
        url,
        requestData,
        error: error.message,
        stack: error.stack
      });
    } else {
      this.logger.info('API call successful', {
        method,
        url,
        requestData,
        responseData
      });
    }
  }

  // Log user actions with context
  logUserAction(action, data = {}) {
    this.logger.info('User action', {
      action,
      component: this.component,
      ...data
    });
  }

  // Log authentication events
  logAuthEvent(event, data = {}) {
    this.logger.info('Authentication event', {
      event,
      component: this.component,
      ...data
    });
  }

  // Log follow/unfollow actions with detailed context
  logFollowAction(action, currentUser, targetUser, result = null, error = null) {
    const logData = {
      action,
      currentUser: currentUser?.toText?.() || currentUser,
      targetUser: targetUser?.toText?.() || targetUser,
      component: this.component
    };

    if (result) {
      logData.result = result;
    }

    if (error) {
      this.logger.error('Follow action failed', {
        ...logData,
        error: error.message || error
      });
    } else {
      this.logger.info('Follow action successful', logData);
    }
  }

  // Log component lifecycle events
  logLifecycle(event, data = {}) {
    this.logger.debug('Component lifecycle', {
      event,
      component: this.component,
      ...data
    });
  }

  // Log performance metrics
  logPerformance(operation, duration, data = {}) {
    this.logger.info('Performance metric', {
      operation,
      duration: `${duration}ms`,
      component: this.component,
      ...data
    });
  }

  // Log errors with enhanced context
  logError(message, error, context = {}) {
    this.logger.error(message, {
      error: error.message || error,
      stack: error.stack,
      component: this.component,
      ...context
    });
  }

  // Log warnings with context
  logWarning(message, data = {}) {
    this.logger.warn(message, {
      component: this.component,
      ...data
    });
  }

  // Log debug information
  logDebug(message, data = {}) {
    this.logger.debug(message, {
      component: this.component,
      ...data
    });
  }

  // Log info with context
  logInfo(message, data = {}) {
    this.logger.info(message, {
      component: this.component,
      ...data
    });
  }
}

// Create a logging utility for a component
export const createLoggingUtils = (component) => {
  return new LoggingUtils(component);
};

// Export convenience functions
export const logApiCall = (component, method, url, requestData, responseData, error) => {
  const utils = new LoggingUtils(component);
  utils.logApiCall(method, url, requestData, responseData, error);
};

export const logUserAction = (component, action, data) => {
  const utils = new LoggingUtils(component);
  utils.logUserAction(action, data);
};

export const logFollowAction = (component, action, currentUser, targetUser, result, error) => {
  const utils = new LoggingUtils(component);
  utils.logFollowAction(action, currentUser, targetUser, result, error);
}; 