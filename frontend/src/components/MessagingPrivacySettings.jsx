import React, { useState, useEffect } from 'react';
import { useMessaging } from '../contexts/MessagingContext';

const MessagingPrivacySettings = ({ onClose }) => {
    const { privacySettings, updatePrivacySettings, loading } = useMessaging();
    const [settings, setSettings] = useState({
        allowMessagesFrom: 'followersOnly',
        allowGroupInvites: true,
        showOnlineStatus: true,
        showReadReceipts: true
    });
    const [saving, setSaving] = useState(false);

    useEffect(() => {
        if (privacySettings) {
            setSettings({
                allowMessagesFrom: privacySettings.allowMessagesFrom,
                allowGroupInvites: privacySettings.allowGroupInvites,
                showOnlineStatus: privacySettings.showOnlineStatus,
                showReadReceipts: privacySettings.showReadReceipts
            });
        }
    }, [privacySettings]);

    const handleSave = async () => {
        setSaving(true);
        try {
            const success = await updatePrivacySettings(settings);
            if (success) {
                onClose();
            }
        } catch (error) {
            console.error('Failed to save privacy settings:', error);
        } finally {
            setSaving(false);
        }
    };

    const handleSettingChange = (key, value) => {
        setSettings(prev => ({
            ...prev,
            [key]: value
        }));
    };

    const getMessagePrivacyDisplayName = (option) => {
        switch (option) {
            case 'everyone': return 'Everyone';
            case 'followersOnly': return 'Followers only';
            case 'connectionsOnly': return 'Connections only';
            case 'nobody': return 'Nobody';
            default: return 'Unknown';
        }
    };

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg shadow-xl max-w-md w-full mx-4 max-h-[90vh] overflow-hidden">
                {/* Header */}
                <div className="px-6 py-4 border-b border-gray-200">
                    <div className="flex items-center justify-between">
                        <h3 className="text-lg font-semibold text-gray-900">
                            Privacy Settings
                        </h3>
                        <button
                            onClick={onClose}
                            className="text-gray-400 hover:text-gray-600"
                        >
                            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                </div>

                {/* Body */}
                <div className="px-6 py-4 space-y-6 max-h-96 overflow-y-auto">
                    {/* Who can message you */}
                    <div>
                        <label className="block text-sm font-medium text-gray-900 mb-3">
                            Who can send you messages
                        </label>
                        <div className="space-y-3">
                            {[
                                { value: 'everyone', label: 'Everyone', description: 'Anyone can send you messages' },
                                { value: 'followersOnly', label: 'Followers only', description: 'Only people who follow you' },
                                { value: 'connectionsOnly', label: 'Connections only', description: 'Only mutual connections' },
                                { value: 'nobody', label: 'Nobody', description: 'Turn off messaging completely' }
                            ].map(option => (
                                <div key={option.value} className="flex items-start">
                                    <input
                                        type="radio"
                                        id={`messaging-${option.value}`}
                                        name="allowMessagesFrom"
                                        value={option.value}
                                        checked={settings.allowMessagesFrom === option.value}
                                        onChange={(e) => handleSettingChange('allowMessagesFrom', e.target.value)}
                                        className="mt-1 mr-3"
                                    />
                                    <div>
                                        <label htmlFor={`messaging-${option.value}`} className="text-sm font-medium text-gray-900 cursor-pointer">
                                            {option.label}
                                        </label>
                                        <p className="text-xs text-gray-500 mt-0.5">{option.description}</p>
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>

                    {/* Group invites */}
                    <div>
                        <div className="flex items-center justify-between">
                            <div>
                                <label className="text-sm font-medium text-gray-900">
                                    Allow group invites
                                </label>
                                <p className="text-xs text-gray-500 mt-0.5">
                                    Let others add you to group conversations
                                </p>
                            </div>
                            <label className="relative inline-flex items-center cursor-pointer">
                                <input
                                    type="checkbox"
                                    checked={settings.allowGroupInvites}
                                    onChange={(e) => handleSettingChange('allowGroupInvites', e.target.checked)}
                                    className="sr-only peer"
                                />
                                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                            </label>
                        </div>
                    </div>

                    {/* Show online status */}
                    <div>
                        <div className="flex items-center justify-between">
                            <div>
                                <label className="text-sm font-medium text-gray-900">
                                    Show online status
                                </label>
                                <p className="text-xs text-gray-500 mt-0.5">
                                    Let others see when you're online
                                </p>
                            </div>
                            <label className="relative inline-flex items-center cursor-pointer">
                                <input
                                    type="checkbox"
                                    checked={settings.showOnlineStatus}
                                    onChange={(e) => handleSettingChange('showOnlineStatus', e.target.checked)}
                                    className="sr-only peer"
                                />
                                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                            </label>
                        </div>
                    </div>

                    {/* Show read receipts */}
                    <div>
                        <div className="flex items-center justify-between">
                            <div>
                                <label className="text-sm font-medium text-gray-900">
                                    Show read receipts
                                </label>
                                <p className="text-xs text-gray-500 mt-0.5">
                                    Let others see when you've read their messages
                                </p>
                            </div>
                            <label className="relative inline-flex items-center cursor-pointer">
                                <input
                                    type="checkbox"
                                    checked={settings.showReadReceipts}
                                    onChange={(e) => handleSettingChange('showReadReceipts', e.target.checked)}
                                    className="sr-only peer"
                                />
                                <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                            </label>
                        </div>
                    </div>

                    {/* Current settings summary */}
                    <div className="bg-gray-50 p-4 rounded-lg">
                        <h4 className="text-sm font-medium text-gray-900 mb-2">Current Settings</h4>
                        <div className="space-y-1 text-xs text-gray-600">
                            <p>• Messages: {getMessagePrivacyDisplayName(settings.allowMessagesFrom)}</p>
                            <p>• Group invites: {settings.allowGroupInvites ? 'Allowed' : 'Disabled'}</p>
                            <p>• Online status: {settings.showOnlineStatus ? 'Visible' : 'Hidden'}</p>
                            <p>• Read receipts: {settings.showReadReceipts ? 'Shown' : 'Hidden'}</p>
                        </div>
                    </div>
                </div>

                {/* Footer */}
                <div className="px-6 py-4 border-t border-gray-200 flex justify-end space-x-3">
                    <button
                        onClick={onClose}
                        disabled={saving}
                        className="px-4 py-2 text-sm font-medium text-gray-700 border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50"
                    >
                        Cancel
                    </button>
                    <button
                        onClick={handleSave}
                        disabled={saving || loading}
                        className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                        {saving ? (
                            <div className="flex items-center">
                                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                                Saving...
                            </div>
                        ) : (
                            'Save Settings'
                        )}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default MessagingPrivacySettings;