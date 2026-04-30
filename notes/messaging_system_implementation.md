# Messaging System Implementation

## Overview
This document provides a comprehensive guide to the messaging system implementation in the Outdoorda Flutter app. The messaging feature includes a conversation list screen and a one-on-one chat interface, designed to be pixel-perfect according to Figma specifications.

## Learning Objectives
- Understand Flutter messaging UI patterns
- Learn GetX state management for real-time updates
- Master responsive design with flutter_screenutil
- Implement reusable widget architecture
- Follow strict MVC pattern for maintainability

## Architecture (MVC Pattern)

### Models (`lib/features/customer_section/home/messaging/models/`)
**File: `message.dart`**

Contains two main data classes:

1. **Message Class**: Represents individual chat messages
   - `id`: Unique message identifier
   - `senderId`: ID of the user who sent the message
   - `senderName`: Display name of sender
   - `senderAvatar`: URL to sender's profile picture
   - `message`: Actual message text content
   - `timestamp`: When the message was sent
   - `isRead`: Whether message has been read
   - `isSentByMe`: Boolean to determine if current user sent this message

2. **Conversation Class**: Represents a chat conversation
   - `id`: Unique conversation identifier
   - `userId`: Other participant's ID
   - `userName`: Other participant's display name
   - `userAvatar`: URL to other participant's profile picture
   - `lastMessage`: Preview text of most recent message
   - `lastMessageTime`: Timestamp of last message
   - `unreadCount`: Number of unread messages

Both classes include:
- `fromJson()`: Convert JSON to Dart object
- `toJson()`: Convert Dart object to JSON
- `copyWith()`: Create copy with updated fields

### Controllers (`lib/features/customer_section/home/messaging/controllers/`)

**File: `message_list_controller.dart`**
- Manages conversation list state
- Loads conversations (currently using dummy data)
- Handles navigation to individual chats
- Formats timestamps for display
- Provides refresh functionality

Key Methods:
```dart
loadConversations()  // Load all conversations
openConversation()   // Navigate to chat screen
markAsRead()         // Clear unread count
formatTime()         // Format timestamp for display
refreshConversations() // Pull-to-refresh
```

**File: `messaging_controller.dart`**
- Manages individual chat screen state
- Loads messages for a conversation
- Sends new messages
- Auto-scrolls to latest message
- Handles message input

Key Methods:
```dart
loadMessages()       // Load chat messages
sendMessage()        // Send a new message
scrollToBottom()     // Auto-scroll to latest message
formatMessageTime()  // Format time for chat bubble
onCameraPressed()    // Handle camera/gallery picker
```

### Views (`lib/features/customer_section/home/messaging/views/`)

#### Widgets (`widgets/`)

**1. MessageListItemWidget**
- Reusable conversation list item
- Shows avatar (40x40 circular)
- Displays user name (Figtree 16px medium)
- Shows last message preview (Figtree 14px)
- Displays timestamp (12px)
- Unread count badge (gradient background)

**2. ChatBubbleWidget**
- Reusable message bubble
- Two variants: sent (blue) and received (white)
- Sent messages: right-aligned, rounded bottom-left
- Received messages: left-aligned, rounded bottom-right
- Includes timestamp below bubble
- Uses Figma-specified colors

**3. MessageInputWidget**
- Custom input field with camera and send buttons
- Camera button: left side, circular with icon
- Text input: expandable (40-100h), rounded
- Send button: right side, gradient background
- Placeholder text from AppStrings
- Disabled state support

#### Screens (`screens/`)

**1. MessageListScreen**
- Displays all conversations in a list
- Uses standard AppBar with title
- Loading state: CircularProgressIndicator
- Empty state: Icon + text
- Pull-to-refresh support
- Taps navigate to MessagingScreen

**2. MessagingScreen**
- Individual chat interface
- Custom AppBar with back button and user info
- Message list with auto-scroll
- Message input at bottom
- Background color from Figma (#EBE8E3)
- SafeArea for notched devices

## Color System

All colors defined in `lib/core/utils/constants/colors.dart`:

```dart
messageBubbleSent: #395C70        // Sent message background
messageBubbleReceived: #EBEFF1    // Received message background
messageBubbleSentText: #FFFFFF    // White text on sent messages
messageBubbleReceivedText: #1E242C // Dark text on received messages
timestampSent: #EFEEEE            // Light timestamp for sent
timestampReceived: #C6CAD1        // Gray timestamp for received
messageInputBackground: #F9FAFB   // Input field background
messageInputBorder: #DFE1E6       // Input field border
unreadBadgeGradientStart: #6FAACC // Unread badge gradient
unreadBadgeGradientEnd: #395C70   // Unread badge gradient
```

## Text Styles

Using `global_text_style.dart` helpers:

```dart
figtreeTextStyle()     // Primary font for messages and UI
montserratTextStyle()  // Used for timestamps
```

Parameters:
- `fontSize`: Size in logical pixels (use .sp)
- `fontWeight`: FontWeight enum
- `lineHeight`: Line spacing multiplier
- `color`: AppColors constant

## Step-by-Step Implementation Guide

### 1. Models Setup
```dart
// Create Message and Conversation classes
// Include all required fields
// Add fromJson, toJson, copyWith methods
// Use null-safe types with proper defaults
```

### 2. Controllers Implementation
```dart
// MessageListController:
// - RxList<Conversation> for reactive updates
// - loadConversations() with dummy data
// - formatTime() for relative timestamps
// - openConversation() for navigation

// MessagingController:
// - RxList<Message> for chat messages
// - TextEditingController for input
// - ScrollController for auto-scroll
// - sendMessage() to add new messages
```

### 3. Widgets Development

**MessageListItemWidget**:
```dart
// Container with padding and border
// Row layout: Avatar + Content
// Avatar: 40x40 circular image
// Content: Column with name/time row and message/badge row
// Gradient badge for unread count
```

**ChatBubbleWidget**:
```dart
// Padding for spacing between messages
// Column layout: Bubble + Timestamp
// Conditional styling based on isSentByMe
// BorderRadius: rounded except pointed corner
// Color and alignment change based on sender
```

**MessageInputWidget**:
```dart
// Row layout: Camera + Input + Send
// Camera button: 40x40 circular
// Input: Expanded with TextField
// Send button: 40x40 with gradient
// SafeArea wrapper for notched phones
```

### 4. Screens Assembly

**MessageListScreen**:
```dart
Scaffold(
  appBar: AppBar with title,
  body: Obx(() => ListView.builder),
)
// Loading state
// Empty state
// List with RefreshIndicator
```

**MessagingScreen**:
```dart
Scaffold(
  backgroundColor: AppColors.bg,
  appBar: Custom with avatar + name,
  body: Column(
    children: [
      Expanded(ListView.builder), // Messages
      MessageInputWidget,          // Input
    ],
  ),
)
```

### 5. Routing Configuration

**controller_binder.dart**:
```dart
Get.lazyPut<MessageListController>(
  () => MessageListController(),
  fenix: true,
);
Get.lazyPut<MessagingController>(
  () => MessagingController(),
  fenix: true,
);
```

**app_routes.dart**:
```dart
static String messageListScreen = "/messageListScreen";
static String messagingScreen = "/messagingScreen";

GetPage(name: messageListScreen, page: () => const MessageListScreen()),
GetPage(name: messagingScreen, page: () => const MessagingScreen()),
```

## Responsive Design

All dimensions use flutter_screenutil:

```dart
// Width
width: 40.w
padding: EdgeInsets.symmetric(horizontal: 20.w)

// Height
height: 40.h
padding: EdgeInsets.symmetric(vertical: 12.h)

// Radius
borderRadius: BorderRadius.circular(20.r)

// Font Size
fontSize: 16.sp
```

## Common Issues and Solutions

### Issue 1: Images Not Loading
**Problem**: Network images fail to load
**Solution**: Implement errorBuilder with fallback UI
```dart
errorBuilder: (context, error, stackTrace) {
  return Container(/* fallback avatar */);
}
```

### Issue 2: Keyboard Overlaps Input
**Problem**: Keyboard covers message input
**Solution**: Use SafeArea and ensure Column fills screen
```dart
SafeArea(
  top: false,
  child: Row(/* input widgets */),
)
```

### Issue 3: Messages Don't Auto-Scroll
**Problem**: New messages sent but view doesn't scroll
**Solution**: Use ScrollController and WidgetsBinding
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  scrollToBottom();
});
```

### Issue 4: Controller Not Found
**Problem**: Get.find<Controller>() throws error
**Solution**: Ensure controller is registered in controller_binder.dart
```dart
Get.lazyPut<MyController>(() => MyController(), fenix: true);
```

### Issue 5: Colors Not Matching Figma
**Problem**: UI colors don't match design
**Solution**: Use exact hex values from Figma in AppColors
```dart
static const Color myColor = Color(0xFF395C70); // Exact hex
```

## Testing Guidelines

### Manual Testing Checklist

**Message List Screen**:
- [ ] Conversations load successfully
- [ ] Avatars display or show fallback
- [ ] Timestamps format correctly
- [ ] Unread badges show for unread messages
- [ ] Tapping conversation navigates to chat
- [ ] Pull-to-refresh works
- [ ] Empty state displays when no conversations
- [ ] Loading state shows during data fetch

**Messaging Screen**:
- [ ] Messages load and display correctly
- [ ] Sent messages appear on right (blue)
- [ ] Received messages appear on left (white)
- [ ] Timestamps show below each message
- [ ] Auto-scrolls to latest message on load
- [ ] Message input accepts text
- [ ] Send button sends message
- [ ] New message appears immediately
- [ ] Back button returns to conversation list
- [ ] User info shows in app bar

**Responsive Design**:
- [ ] Test on different screen sizes
- [ ] Check on notched devices
- [ ] Verify keyboard behavior
- [ ] Test landscape orientation

### Unit Testing (Future Implementation)

```dart
// Test controller methods
test('formatTime returns correct relative time', () {
  final controller = MessageListController();
  final time = DateTime.now().subtract(Duration(minutes: 30));
  expect(controller.formatTime(time), '30m ago');
});

// Test message sending
test('sendMessage adds message to list', () {
  final controller = MessagingController();
  controller.messageController.text = 'Test message';
  controller.sendMessage();
  expect(controller.messages.length, 1);
  expect(controller.messages.first.message, 'Test message');
});
```

## Performance Considerations

### Optimization Strategies

1. **Image Caching**
   - Network images auto-cache via Flutter
   - Consider using cached_network_image package for better control

2. **List Performance**
   - ListView.builder creates items on-demand
   - Only visible items are rendered
   - Efficient for large conversation lists

3. **State Management**
   - GetX reactive updates only affected widgets
   - Obx() rebuilds minimal widget tree
   - Controllers lazy-loaded with Get.lazyPut

4. **Message Pagination**
   - Current: Loads all messages at once
   - Future: Implement pagination for large chats
   ```dart
   Future<void> loadMoreMessages() async {
     // Load older messages when scrolled to top
   }
   ```

5. **Memory Management**
   - Controllers auto-disposed when not in use
   - TextEditingController disposed in onClose()
   - ScrollController disposed in onClose()

## API Integration (Future)

Currently using dummy data. To integrate real API:

### 1. Update Message List Controller
```dart
Future<void> loadConversations() async {
  try {
    isLoading.value = true;
    EasyLoading.show();
    
    final response = await NetworkCaller.get(ApiConstants.conversations);
    final conversationList = (response.data as List)
        .map((json) => Conversation.fromJson(json))
        .toList();
    
    conversations.assignAll(conversationList);
    EasyLoading.showSuccess('Conversations loaded');
  } catch (error) {
    AppLoggerHelper.error('LoadConversations error: $error', error: error);
    EasyLoading.showError('Failed to load conversations');
  } finally {
    isLoading.value = false;
    EasyLoading.dismiss();
  }
}
```

### 2. Update Messaging Controller
```dart
Future<void> sendMessage() async {
  final messageText = messageController.text.trim();
  if (messageText.isEmpty) return;

  try {
    isSending.value = true;
    
    final newMessage = Message(/* ... */);
    
    // Optimistic update
    messages.add(newMessage);
    messageController.clear();
    scrollToBottom();
    
    // Send to server
    final response = await NetworkCaller.post(
      ApiConstants.sendMessage,
      body: newMessage.toJson(),
    );
    
    // Update with server response (message ID, etc.)
    final sentMessage = Message.fromJson(response.data);
    messages[messages.length - 1] = sentMessage;
    
  } catch (error) {
    AppLoggerHelper.error('SendMessage error: $error', error: error);
    // Remove optimistic message on error
    messages.removeLast();
    EasyLoading.showError('Failed to send message');
  } finally {
    isSending.value = false;
  }
}
```

### 3. WebSocket for Real-Time Updates
```dart
class MessagingController extends GetxController {
  // Add WebSocket connection
  late WebSocketChannel channel;
  
  @override
  void onInit() {
    super.onInit();
    _connectWebSocket();
  }
  
  void _connectWebSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse('ws://yourapi.com/messages/${conversation.id}'),
    );
    
    channel.stream.listen((data) {
      final newMessage = Message.fromJson(jsonDecode(data));
      messages.add(newMessage);
      scrollToBottom();
    });
  }
  
  @override
  void onClose() {
    channel.sink.close();
    super.onClose();
  }
}
```

## Accessibility Considerations

1. **Semantic Labels**: Add for screen readers
2. **Color Contrast**: All text meets WCAG AA standards
3. **Touch Targets**: Minimum 44x44 logical pixels
4. **Focus Management**: Keyboard navigation support

## Future Enhancements

1. **Image/File Attachments**: Camera/gallery integration
2. **Message Read Receipts**: Show when message is read
3. **Typing Indicators**: Show when other user is typing
4. **Message Search**: Search within conversations
5. **Push Notifications**: Alert for new messages
6. **Message Reactions**: Emoji reactions to messages
7. **Voice Messages**: Record and send audio
8. **Message Deletion**: Delete or edit sent messages
9. **Group Chats**: Support for multi-user conversations
10. **Message Encryption**: End-to-end encryption

## Code Quality Checklist

- [x] Package imports (not relative)
- [x] Color.withValues(alpha:) for opacity
- [x] Get.find() for controllers (not Get.put())
- [x] Controllers in controller_binder.dart
- [x] AppStrings for all text
- [x] AppColors for all colors
- [x] Responsive sizing with .sp, .w, .h, .r
- [x] Reusable widgets extracted
- [x] MVC pattern followed
- [x] No business logic in UI
- [x] Error handling with EasyLoading
- [x] Null-safe code
- [x] Documentation comments

## Conclusion

This messaging system provides a solid foundation for real-time communication in the Outdoorda app. The implementation follows Flutter and GetX best practices, uses a clear MVC architecture, and is designed to be maintainable and extendable. The pixel-perfect UI matches Figma specifications exactly, and the codebase is structured for easy future enhancements like API integration, WebSocket support, and additional features.

For questions or issues, refer to the copilot-instructions.md file for project-wide coding standards.
