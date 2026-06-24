import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();

  // 👇 FACTORY CONSTRUCTOR
  factory SocketService() {
    return _instance;
  }

  // 👇 PRIVATE CONSTRUCTOR (YEH MISSING THA)
  SocketService._internal();
  IO.Socket? _socket;
  bool _isConnecting = false;
  Function()? _onConnectedCallback;
  Function(Map<String, dynamic>)? _onMessageCallback;
  Function(String messageId)? _onMessageDeleted;
  Function()? _onDisconnectedCallback;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required String token,
    required String userId,
    Function()? onConnected,
    Function(Map<String, dynamic>)? onMessageReceived,
    Function(String messageId)? onDeleted,
    Function()? onDisconnected,
  }) {
    print("🔗 CONNECT CALLED");
    print("🪪 Token: $token");
    print("👤 UserID: $userId");

    dispose();
    _onConnectedCallback = onConnected;
    _onMessageCallback = onMessageReceived;
    _onDisconnectedCallback = onDisconnected;
    _onMessageDeleted = onDeleted;

    _isConnecting = true;
    _socket = IO.io(
      'http://15.235.204.49:305',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .setAuth({'token': token})
          .build(),
    );
    _setupEventListeners();
    _socket!.connect();
  }

  void _setupEventListeners() {
    _socket?.on('connect', (_) {
      _isConnecting = false;
      debugPrint('✅ Connected: ${_socket?.id}');
      _onConnectedCallback?.call();
    });

    _socket?.on('reconnect', (_) {
      debugPrint('✅ Reconnected: ${_socket?.id}');
      _onConnectedCallback?.call();
    });

    _socket?.on('newMessage', (data) {
      debugPrint("📥 newMessage received => $data");
      _onMessageCallback?.call(Map<String, dynamic>.from(data));
    });

    _socket?.on('messageDeleted', (data) {
      debugPrint("📥 deletedMessage => $data");
      final messageId = data['messageId'];
      if (messageId != null) {
        _onMessageDeleted?.call(messageId);
      }
    });

    _socket?.onDisconnect((_) {
      _isConnecting = false;
      debugPrint("🔌 Disconnected");
      print("Socket Disconnected: ${_socket?.id}");
      _onDisconnectedCallback?.call();
    });

    _socket?.onError(
        (data) => Fluttertoast.showToast(msg: '❌ Socket Error: $data'));
    _socket?.onReconnectAttempt(
        (_) => Fluttertoast.showToast(msg: '🔄 Reconnecting...'));
  }

  void joinConversation(String conversationId) {
    _socket?.emit('joinConversation', conversationId);
  }

  void deleteMessage(String messageId) {
    debugPrint("📤 Deleting message => $messageId");
    _socket?.emit('deleteMessage', {'messageId': messageId});
  }

  void sendMessage(Map<String, dynamic> messageData) {
    if (!isConnected) return;
    debugPrint("📤 Sending message => $messageData");
    _socket?.emit("sendMessage", messageData);
  }

  void dispose() {
    if (_socket != null) {
      print("🧹 Disposing socket: ${_socket?.id}");
      _socket!.clearListeners();
      _socket!.disconnect();
      _socket!.destroy();
      _socket = null;
    }
    _isConnecting = false;
  }
}
