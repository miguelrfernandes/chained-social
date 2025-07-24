import React, { useState, useRef } from 'react';

const MessageInput = ({ value, onChange, onSend, disabled = false }) => {
    const [showEmojiPicker, setShowEmojiPicker] = useState(false);
    const textareaRef = useRef(null);
    const fileInputRef = useRef(null);

    const emojis = ['😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏', '😒', '😞', '😔', '😟', '😕', '🙁', '☹️', '😣', '😖', '😫', '😩', '🥺', '😢', '😭', '😤', '😠', '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨', '😰', '😥', '😓', '🤗', '🤔', '🤭', '🤫', '🤥', '😶', '😐', '😑', '😬', '🙄', '😯', '😦', '😧', '😮', '😲', '🥱', '😴', '🤤', '😪', '😵', '🤐', '🥴', '🤢', '🤮', '🤧', '😷', '🤒', '🤕', '🤑', '🤠', '😈', '👿', '👹', '👺', '🤡', '💩', '👻', '💀', '☠️', '👽', '👾', '🤖', '🎃', '😺', '😸', '😹', '😻', '😼', '😽', '🙀', '😿', '😾'];

    const handleKeyPress = (e) => {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            handleSend();
        }
    };

    const handleSend = () => {
        const content = value.trim();
        if (content && !disabled) {
            onSend(content);
        }
    };

    const handleEmojiClick = (emoji) => {
        const newValue = value + emoji;
        onChange(newValue);
        setShowEmojiPicker(false);
        textareaRef.current?.focus();
    };

    const handleFileAttachment = (e) => {
        const files = Array.from(e.target.files);
        if (files.length > 0) {
            // For now, just show the file name in the input
            // In a production app, you'd upload the file and get a URL
            const fileNames = files.map(f => f.name).join(', ');
            onChange(value + ` [File: ${fileNames}]`);
        }
    };

    const handlePaste = (e) => {
        const items = Array.from(e.clipboardData.items);
        const imageItem = items.find(item => item.type.indexOf('image') !== -1);
        
        if (imageItem) {
            e.preventDefault();
            const file = imageItem.getAsFile();
            onChange(value + ` [Image: ${file.name}]`);
        }
    };

    return (
        <div className="relative">
            <div className="flex items-end space-x-2">
                {/* File attachment button */}
                <div className="flex-shrink-0">
                    <button
                        type="button"
                        onClick={() => fileInputRef.current?.click()}
                        disabled={disabled}
                        className="p-2 text-gray-500 hover:text-gray-700 disabled:opacity-50 disabled:cursor-not-allowed rounded-full hover:bg-gray-100"
                        title="Attach file"
                    >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13" />
                        </svg>
                    </button>
                    <input
                        ref={fileInputRef}
                        type="file"
                        multiple
                        className="hidden"
                        onChange={handleFileAttachment}
                        accept="image/*,video/*,audio/*,.pdf,.doc,.docx,.txt"
                    />
                </div>

                {/* Message input */}
                <div className="flex-1 relative">
                    <textarea
                        ref={textareaRef}
                        value={value}
                        onChange={(e) => onChange(e.target.value)}
                        onKeyPress={handleKeyPress}
                        onPaste={handlePaste}
                        placeholder="Type a message..."
                        disabled={disabled}
                        className="w-full px-4 py-2 pr-12 border border-gray-300 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:opacity-50 disabled:cursor-not-allowed"
                        rows="1"
                        style={{
                            minHeight: '40px',
                            maxHeight: '120px',
                        }}
                        onInput={(e) => {
                            // Auto-resize textarea
                            e.target.style.height = 'auto';
                            e.target.style.height = Math.min(e.target.scrollHeight, 120) + 'px';
                        }}
                    />
                    
                    {/* Emoji button */}
                    <button
                        type="button"
                        onClick={() => setShowEmojiPicker(!showEmojiPicker)}
                        disabled={disabled}
                        className="absolute right-2 top-1/2 transform -translate-y-1/2 p-1 text-gray-500 hover:text-gray-700 disabled:opacity-50 disabled:cursor-not-allowed rounded"
                        title="Add emoji"
                    >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M14.828 14.828a4 4 0 01-5.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                    </button>
                </div>

                {/* Send button */}
                <div className="flex-shrink-0">
                    <button
                        type="button"
                        onClick={handleSend}
                        disabled={disabled || !value.trim()}
                        className="p-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed focus:outline-none focus:ring-2 focus:ring-blue-500"
                        title="Send message"
                    >
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                        </svg>
                    </button>
                </div>
            </div>

            {/* Emoji picker */}
            {showEmojiPicker && (
                <div className="absolute bottom-full left-0 mb-2 p-4 bg-white border border-gray-300 rounded-lg shadow-lg z-10">
                    <div className="grid grid-cols-8 gap-2 max-w-64 max-h-32 overflow-y-auto">
                        {emojis.map((emoji, index) => (
                            <button
                                key={index}
                                type="button"
                                onClick={() => handleEmojiClick(emoji)}
                                className="p-1 hover:bg-gray-100 rounded text-lg"
                                title={emoji}
                            >
                                {emoji}
                            </button>
                        ))}
                    </div>
                    <div className="mt-2 pt-2 border-t border-gray-200">
                        <button
                            type="button"
                            onClick={() => setShowEmojiPicker(false)}
                            className="text-xs text-gray-500 hover:text-gray-700"
                        >
                            Close
                        </button>
                    </div>
                </div>
            )}

            {/* Click outside to close emoji picker */}
            {showEmojiPicker && (
                <div
                    className="fixed inset-0 z-5"
                    onClick={() => setShowEmojiPicker(false)}
                />
            )}
        </div>
    );
};

export default MessageInput;