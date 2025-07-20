# Enhanced Pino Logging Setup

This project uses Pino for structured logging with enhanced browser console output and comprehensive logging utilities.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Configuration](#configuration)
- [Usage Examples](#usage-examples)
- [Best Practices](#best-practices)
- [File Structure](#file-structure)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

- **Enhanced Browser Logging**: Color-coded, grouped console output with icons
- **Structured JSON Output**: Easy to analyze and filter logs
- **Component-Specific Loggers**: Organized logging by component with icons
- **Comprehensive Utilities**: Specialized logging for different use cases
- **Performance Tracking**: Built-in performance monitoring
- **Error Context**: Enhanced error logging with stack traces

## ✨ Features

### 🎨 Enhanced Console Output
- **Color-coded log levels**: Blue (info), Yellow (warn), Red (error), Green (debug)
- **Grouped console output**: Collapsible log groups for better organization
- **Component icons**: Visual identification of log sources (👤 Profile, 🔐 Auth, etc.)
- **Structured data display**: Clean, readable object formatting
- **Timestamp information**: ISO timestamps for precise tracking

### 📊 Logging Utilities

Specialized logging classes for different use cases:

```javascript
import { createLoggingUtils } from '../utils/loggingUtils';

const logging = createLoggingUtils('Profile');

// API calls with request/response tracking
logging.logApiCall('GET', '/api/users', requestData, responseData, error);

// User actions with context
logging.logUserAction('button_click', { buttonId: 'follow', userId: '123' });

// Authentication events
logging.logAuthEvent('login_success', { method: 'NFID', principal: 'abc123' });

// Follow/unfollow actions with detailed tracking
logging.logFollowAction('follow', currentUser, targetUser, result, error);

// Component lifecycle events
logging.logLifecycle('component_mounted', { props: {...}, children: 3 });

// Performance metrics
logging.logPerformance('api_call', 150, { endpoint: '/users' });

// Enhanced error logging
logging.logError('API call failed', error, { context: 'user_profile' });
```

## ⚙️ Configuration

### Enhanced Logger

Browser-compatible logger with enhanced console output:

```javascript
import { createLogger } from '../utils/logger';

const logger = createLogger('ComponentName');

// Enhanced console output with grouping and icons
logger.info('User action', { userId: '123', action: 'follow' });
logger.error('API error', { error: error.message });
```

### Log Levels

- **🔵 debug**: Detailed information for development (green groups)
- **🔵 info**: General application flow (blue groups)
- **🟡 warn**: Potential issues that don't break functionality (yellow groups)
- **🔴 error**: Actual errors that need attention (red groups)

## 📝 Usage Examples

### Frontend Components with Enhanced Logging

```javascript
import { createLoggingUtils } from '../utils/loggingUtils';

const logging = createLoggingUtils('Profile');

// Follow functionality with detailed tracking
logging.logFollowAction('follow', currentUser, targetUser, result, error);

// User actions with context
logging.logUserAction('profile_view', { 
  targetUser: targetPrincipalObj.toText(),
  currentUser: currentUserPrincipal.toText() 
});

// Error handling with enhanced context
logging.logError('Follow failed', error, { 
  context: 'social_graph',
  userPrincipal: userPrincipal 
});
```

### Performance Monitoring

```javascript
const startTime = performance.now();
// ... perform operation
const duration = performance.now() - startTime;
logging.logPerformance('follow_operation', duration, {
  targetUser: targetUser,
  operation: 'social_graph_follow'
});
```

### API Call Tracking

```javascript
logging.logApiCall('POST', '/api/follow', 
  { targetUser: 'abc123' }, 
  { success: true }, 
  null // error
);
```

## 🎯 Best Practices

Based on [console.log() tips](https://dev.to/ackshaey/level-up-your-javascript-browser-logs-with-these-console-log-tips-55o2):

1. **Use structured logging** instead of plain console.log()
2. **Group related logs** for better organization
3. **Include context** in every log message
4. **Use appropriate log levels** for different types of information
5. **Track performance** for critical operations
6. **Include error context** for better debugging
7. **Use component-specific loggers** for better organization

## 📁 File Structure

```
frontend/
├── src/utils/
│   ├── logger.js          # Enhanced frontend logger
│   └── loggingUtils.js    # Comprehensive logging utilities
└── docs/
    └── LOGGING.md        # This documentation
```

## 🔧 Environment Variables

- `NODE_ENV`: Environment detection for log levels (debug in dev, info in prod)

## 🚀 Benefits

1. **🎨 Visual Enhancement**: Color-coded, grouped console output
2. **📊 Structured Data**: JSON format for easy analysis
3. **🏷️ Component Context**: Easy to identify log sources with icons
4. **⚡ Performance Optimized**: Efficient logging with proper levels
5. **🔍 Enhanced Debugging**: Better error tracking and context
6. **📈 Performance Monitoring**: Built-in performance tracking
7. **🔄 Lifecycle Tracking**: Component lifecycle event logging
8. **🌐 API Monitoring**: Comprehensive API call tracking
9. **👤 User Action Tracking**: Detailed user interaction logging
10. **🔐 Auth Event Tracking**: Authentication flow monitoring

## 🔍 Troubleshooting

### Common Issues

**Q: Logs not appearing in console?**
A: Check that `NODE_ENV` is set correctly and log level is appropriate.

**Q: Performance impact of logging?**
A: Use appropriate log levels and avoid logging in production for debug messages.

**Q: Error context missing?**
A: Always pass the error object as the second parameter to `logError()`.

### Debug Mode

Enable debug logging by setting `NODE_ENV=development` in your environment.

---

*For more information, see [Pino Documentation](https://getpino.io/) and [Console.log() Tips](https://dev.to/ackshaey/level-up-your-javascript-browser-logs-with-these-console-log-tips-55o2)* 