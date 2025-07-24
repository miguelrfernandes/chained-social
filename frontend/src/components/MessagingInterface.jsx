import React, { useState, useEffect, useRef } from 'react';
import { useMessaging } from '../contexts/MessagingContext';
import { useAuth } from '../contexts/AuthContext';
import ConversationList from './ConversationList';
import MessageList from './MessageList';
import MessageInput from './MessageInput';
import NewConversationModal from './NewConversationModal';
import MessagingPrivacySettings from './MessagingPrivacySettings';

const MessagingInterface = () => {
    const { 
        conversations, 
        currentConversation, 
        messages, 
        loading, 
        error, 
        selectConversation,
        sendMessage,
        createConversation,
        setError
    } = useMessaging();
    
    const { isLoggedIn } = useAuth();
    const [showNewConversation, setShowNewConversation] = useState(false);
    const [showPrivacySettings, setShowPrivacySettings] = useState(false);
    const [messageContent, setMessageContent] = useState('');
    const messagesEndRef = useRef(null);

    // Auto-scroll to bottom when new messages arrive
    useEffect(() => {
        scrollToBottom();
    }, [messages]);

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    };

    const handleSendMessage = async (content, messageType = { text: null }, replyTo = null, attachments = []) => {
        if (!currentConversation || !content.trim()) return;

        try {
            await sendMessage(currentConversation.id, content, messageType, replyTo, attachments);
            setMessageContent('');
        } catch (error) {
            console.error('Failed to send message:', error);
            setError('Failed to send message');
        }
    };

    const handleNewConversation = async (participants, participantNames, title, isGroup, initialMessage) => {
        try {
            const conversation = await createConversation(participants, participantNames, title, isGroup, initialMessage);
            if (conversation) {
                setShowNewConversation(false);
                selectConversation(conversation);
            }
        } catch (error) {
            console.error('Failed to create conversation:', error);
            setError('Failed to create conversation');
        }
    };

    if (!isLoggedIn) {
        return (
            <div className="flex items-center justify-center h-full bg-gray-50">
                <div className="text-center p-8">
                    <div className="text-gray-400 mb-4">
                        <svg className="mx-auto h-16 w-16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                        </svg>
                    </div>
                    <h3 className="text-lg font-medium text-gray-900 mb-2">Sign in to start messaging</h3>
                    <p className="text-gray-500">Connect with other users through private messages</p>
                </div>
            </div>
        );
    }

    return (
        <div className="flex h-full bg-white">
            {/* Conversation List Sidebar */}
            <div className="w-1/3 border-r border-gray-200 flex flex-col">
                {/* Header */}
                <div className="p-4 border-b border-gray-200 bg-gray-50">
                    <div className="flex items-center justify-between">
                        <h2 className="text-lg font-semibold text-gray-900">Messages</h2>
                        <div className="flex items-center space-x-2">
                            <button
                                onClick={() => setShowPrivacySettings(true)}
                                className="inline-flex items-center p-2 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                                title="Privacy Settings"
                            >
                                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                                </svg>
                            </button>
                            <button
                                onClick={() => setShowNewConversation(true)}
                                className="inline-flex items-center px-3 py-1.5 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
                            >
                                <svg className="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 4v16m8-8H4" />
                                </svg>
                                New
                            </button>
                        </div>
                    </div>
                </div>

                {/* Conversations */}
                <div className="flex-1 overflow-y-auto">
                    {loading && conversations.length === 0 ? (
                        <div className="flex items-center justify-center h-32">
                            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                        </div>
                    ) : (
                        <ConversationList
                            conversations={conversations}
                            currentConversation={currentConversation}
                            onSelectConversation={selectConversation}
                        />
                    )}
                </div>
            </div>

            {/* Message Area */}
            <div className="flex-1 flex flex-col">
                {currentConversation ? (
                    <>
                        {/* Chat Header */}
                        <div className="p-4 border-b border-gray-200 bg-gray-50">
                            <div className="flex items-center">
                                <div className="flex-1">
                                    <h3 className="text-lg font-semibold text-gray-900">
                                        {currentConversation.isGroup 
                                            ? currentConversation.title || 'Group Chat' 
                                            : currentConversation.participantNames.find((name, index) => 
                                                currentConversation.participants[index] !== /* current user principal */ null
                                              ) || 'Unknown User'
                                        }
                                    </h3>
                                    <p className="text-sm text-gray-500">
                                        {currentConversation.isGroup 
                                            ? `${currentConversation.participants.length} participants`
                                            : 'Direct message'
                                        }
                                    </p>
                                </div>
                                
                                {/* Chat options */}
                                <div className="flex items-center space-x-2">
                                    <button className="p-2 text-gray-400 hover:text-gray-600 rounded-full hover:bg-gray-100">
                                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
                                        </svg>
                                    </button>
                                </div>
                            </div>
                        </div>

                        {/* Messages */}
                        <div className="flex-1 overflow-y-auto p-4 space-y-4">
                            {loading && messages.length === 0 ? (
                                <div className="flex items-center justify-center h-32">
                                    <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                                </div>
                            ) : (
                                <MessageList messages={messages} />
                            )}
                            <div ref={messagesEndRef} />
                        </div>

                        {/* Message Input */}
                        <div className="border-t border-gray-200 p-4">
                            <MessageInput
                                value={messageContent}
                                onChange={setMessageContent}
                                onSend={handleSendMessage}
                                disabled={loading}
                            />
                        </div>
                    </>
                ) : (
                    /* No conversation selected */
                    <div className="flex items-center justify-center h-full bg-gray-50">
                        <div className="text-center p-8">
                            <div className="text-gray-400 mb-4">
                                <svg className="mx-auto h-16 w-16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                                </svg>
                            </div>
                            <h3 className="text-lg font-medium text-gray-900 mb-2">Select a conversation</h3>
                            <p className="text-gray-500 mb-4">Choose a conversation from the sidebar to start messaging</p>
                            <button
                                onClick={() => setShowNewConversation(true)}
                                className="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
                            >
                                Start a new conversation
                            </button>
                        </div>
                    </div>
                )}
            </div>

            {/* Error Display */}
            {error && (
                <div className="fixed top-4 right-4 z-50">
                    <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-lg shadow-lg">
                        <div className="flex items-center">
                            <svg className="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
                                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                            </svg>
                            <span>{error}</span>
                            <button
                                onClick={() => setError(null)}
                                className="ml-4 text-red-500 hover:text-red-700"
                            >
                                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                                    <path fillRule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clipRule="evenodd" />
                                </svg>
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* New Conversation Modal */}
            {showNewConversation && (
                <NewConversationModal
                    onClose={() => setShowNewConversation(false)}
                    onCreateConversation={handleNewConversation}
                />
            )}

            {/* Privacy Settings Modal */}
            {showPrivacySettings && (
                <MessagingPrivacySettings
                    onClose={() => setShowPrivacySettings(false)}
                />
            )}
        </div>
    );
};

export default MessagingInterface;