import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { AuthContext } from './AuthContext';

const MessagingContext = createContext();

export const useMessaging = () => {
    const context = useContext(MessagingContext);
    if (!context) {
        throw new Error('useMessaging must be used within a MessagingProvider');
    }
    return context;
};

export const MessagingProvider = ({ children }) => {
    const { isLoggedIn, authClient, identity } = useContext(AuthContext);
    const [messagingActor, setMessagingActor] = useState(null);
    const [conversations, setConversations] = useState([]);
    const [currentConversation, setCurrentConversation] = useState(null);
    const [messages, setMessages] = useState([]);
    const [unreadCount, setUnreadCount] = useState(0);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [privacySettings, setPrivacySettings] = useState(null);

    // Initialize messaging actor
    useEffect(() => {
        const initMessagingActor = async () => {
            try {
                if (isLoggedIn && identity) {
                    console.log('🔄 Initializing messaging actor...');
                    const { messaging, createActor } = await import('../declarations/messaging');
                    
                    let actor = messaging;
                    
                    if (!actor && identity) {
                        // Create actor with authenticated identity
                        actor = createActor(process.env.CANISTER_ID_MESSAGING || "be2us-64aaa-aaaaa-qaabq-cai", {
                            agentOptions: { identity }
                        });
                    }
                    
                    if (actor) {
                        setMessagingActor(actor);
                        console.log('✅ Messaging actor initialized');
                    }
                } else {
                    setMessagingActor(null);
                }
            } catch (error) {
                console.error('❌ Failed to initialize messaging actor:', error);
                setError('Failed to initialize messaging');
            }
        };

        initMessagingActor();
    }, [isLoggedIn, identity]);

    // Load user conversations
    const loadConversations = useCallback(async () => {
        if (!messagingActor) return;

        try {
            setLoading(true);
            const result = await messagingActor.getUserConversations();
            
            if ('ok' in result) {
                setConversations(result.ok);
            } else {
                console.error('Failed to load conversations:', result.err);
                setError(result.err);
            }
        } catch (error) {
            console.error('Error loading conversations:', error);
            setError('Failed to load conversations');
        } finally {
            setLoading(false);
        }
    }, [messagingActor]);

    // Load messages for a conversation
    const loadMessages = useCallback(async (conversationId, limit = 50, offset = 0) => {
        if (!messagingActor) return;

        try {
            setLoading(true);
            const result = await messagingActor.getConversationMessages(conversationId, limit, offset);
            
            if ('ok' in result) {
                setMessages(result.ok.reverse()); // Reverse to show oldest first
            } else {
                console.error('Failed to load messages:', result.err);
                setError(result.err);
            }
        } catch (error) {
            console.error('Error loading messages:', error);
            setError('Failed to load messages');
        } finally {
            setLoading(false);
        }
    }, [messagingActor]);

    // Send a message
    const sendMessage = useCallback(async (conversationId, content, messageType = { text: null }, replyTo = null, attachments = []) => {
        if (!messagingActor) return null;

        try {
            const request = {
                conversationId,
                content,
                messageType,
                replyTo: replyTo ? [replyTo] : [],
                attachments
            };

            const result = await messagingActor.sendMessage(request);
            
            if ('ok' in result) {
                // Add message to current messages if it's for the current conversation
                if (currentConversation && currentConversation.id === conversationId) {
                    setMessages(prev => [...prev, result.ok]);
                }
                
                // Reload conversations to update last message
                await loadConversations();
                
                return result.ok;
            } else {
                console.error('Failed to send message:', result.err);
                setError(result.err);
                return null;
            }
        } catch (error) {
            console.error('Error sending message:', error);
            setError('Failed to send message');
            return null;
        }
    }, [messagingActor, currentConversation, loadConversations]);

    // Create a new conversation
    const createConversation = useCallback(async (participants, participantNames, title = null, isGroup = false, initialMessage = null) => {
        if (!messagingActor) return null;

        try {
            const request = {
                participants,
                participantNames,
                title: title ? [title] : [],
                isGroup,
                initialMessage: initialMessage ? [initialMessage] : []
            };

            const result = await messagingActor.createConversation(request);
            
            if ('ok' in result) {
                await loadConversations();
                return result.ok;
            } else {
                console.error('Failed to create conversation:', result.err);
                setError(result.err);
                return null;
            }
        } catch (error) {
            console.error('Error creating conversation:', error);
            setError('Failed to create conversation');
            return null;
        }
    }, [messagingActor, loadConversations]);

    // Mark conversation as read
    const markConversationAsRead = useCallback(async (conversationId) => {
        if (!messagingActor) return;

        try {
            const result = await messagingActor.markConversationAsRead(conversationId);
            
            if ('ok' in result) {
                // Update local state
                setConversations(prev => prev.map(conv => 
                    conv.id === conversationId 
                        ? { ...conv, unreadCounts: conv.unreadCounts.map(([userId, _]) => [userId, 0]) }
                        : conv
                ));
                
                // Update unread count
                await loadUnreadCount();
            } else {
                console.error('Failed to mark conversation as read:', result.err);
            }
        } catch (error) {
            console.error('Error marking conversation as read:', error);
        }
    }, [messagingActor]);

    // Load unread message count
    const loadUnreadCount = useCallback(async () => {
        if (!messagingActor) return;

        try {
            const result = await messagingActor.getUnreadMessageCount();
            
            if ('ok' in result) {
                setUnreadCount(result.ok);
            } else {
                console.error('Failed to load unread count:', result.err);
            }
        } catch (error) {
            console.error('Error loading unread count:', error);
        }
    }, [messagingActor]);

    // Load privacy settings
    const loadPrivacySettings = useCallback(async () => {
        if (!messagingActor) return;

        try {
            const result = await messagingActor.getPrivacySettings();
            
            if ('ok' in result) {
                setPrivacySettings(result.ok);
            } else {
                console.error('Failed to load privacy settings:', result.err);
            }
        } catch (error) {
            console.error('Error loading privacy settings:', error);
        }
    }, [messagingActor]);

    // Update privacy settings
    const updatePrivacySettings = useCallback(async (settings) => {
        if (!messagingActor) return false;

        try {
            const result = await messagingActor.setPrivacySettings(settings);
            
            if ('ok' in result) {
                setPrivacySettings(settings);
                return true;
            } else {
                console.error('Failed to update privacy settings:', result.err);
                setError(result.err);
                return false;
            }
        } catch (error) {
            console.error('Error updating privacy settings:', error);
            setError('Failed to update privacy settings');
            return false;
        }
    }, [messagingActor]);

    // Edit a message
    const editMessage = useCallback(async (messageId, newContent) => {
        if (!messagingActor) return null;

        try {
            const result = await messagingActor.editMessage(messageId, newContent);
            
            if ('ok' in result) {
                // Update local message state
                setMessages(prev => prev.map(msg => 
                    msg.id === messageId ? result.ok : msg
                ));
                return result.ok;
            } else {
                console.error('Failed to edit message:', result.err);
                setError(result.err);
                return null;
            }
        } catch (error) {
            console.error('Error editing message:', error);
            setError('Failed to edit message');
            return null;
        }
    }, [messagingActor]);

    // Delete a message
    const deleteMessage = useCallback(async (messageId) => {
        if (!messagingActor) return false;

        try {
            const result = await messagingActor.deleteMessage(messageId);
            
            if ('ok' in result) {
                // Reload messages to reflect the deletion
                if (currentConversation) {
                    await loadMessages(currentConversation.id);
                }
                return true;
            } else {
                console.error('Failed to delete message:', result.err);
                setError(result.err);
                return false;
            }
        } catch (error) {
            console.error('Error deleting message:', error);
            setError('Failed to delete message');
            return false;
        }
    }, [messagingActor, currentConversation, loadMessages]);

    // Set current conversation and load its messages
    const selectConversation = useCallback(async (conversation) => {
        setCurrentConversation(conversation);
        if (conversation) {
            await loadMessages(conversation.id);
            await markConversationAsRead(conversation.id);
        } else {
            setMessages([]);
        }
    }, [loadMessages, markConversationAsRead]);

    // Auto-refresh conversations and unread count
    useEffect(() => {
        if (messagingActor) {
            loadConversations();
            loadUnreadCount();
            loadPrivacySettings();

            // Set up periodic refresh
            const interval = setInterval(() => {
                loadConversations();
                loadUnreadCount();
            }, 30000); // Refresh every 30 seconds

            return () => clearInterval(interval);
        }
    }, [messagingActor, loadConversations, loadUnreadCount, loadPrivacySettings]);

    // Clear error after some time
    useEffect(() => {
        if (error) {
            const timer = setTimeout(() => {
                setError(null);
            }, 5000);
            return () => clearTimeout(timer);
        }
    }, [error]);

    const value = {
        // State
        conversations,
        currentConversation,
        messages,
        unreadCount,
        loading,
        error,
        privacySettings,
        
        // Actions
        loadConversations,
        loadMessages,
        sendMessage,
        createConversation,
        markConversationAsRead,
        loadUnreadCount,
        loadPrivacySettings,
        updatePrivacySettings,
        editMessage,
        deleteMessage,
        selectConversation,
        
        // Utilities
        setError,
        setCurrentConversation
    };

    return (
        <MessagingContext.Provider value={value}>
            {children}
        </MessagingContext.Provider>
    );
};