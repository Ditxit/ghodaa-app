import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ghodaa/states/main.state.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';

/// A service to manage a Socket.IO connection for sending and receiving messages.
class SocketService {
  IO.Socket? _socket; // The Socket.IO client instance
  Timer? _timer; // Timer for periodic message sending
  final MainState mainState; // Instance of MainState for authentication
  final String _socketEndpoint = dotenv.env['SOCKET_ENDPOINT'] ?? '';

  /// Constructor that accepts MainState
  SocketService(this.mainState);

  Function? onConnectCallback;

  /// Initializes the socket service and connects to the server.
  void init() {
    _socket = IO.io(_socketEndpoint, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': true,
      'extraHeaders': {
        'Authorization': mainState.userToken ?? '',
        'Latitude': mainState.userLatitude,
        'Longitude': mainState.userLongitude,
      },
    });

    _socket?.connect(); // Establishes the connection to the server

    // Listen for connection events
    _socket?.onConnect((_) {
      print('SOCKET: Connected');
      if (onConnectCallback != null) {
        onConnectCallback!();
      }
    });

    // Listen for disconnection events
    _socket?.onDisconnect((_) {
      print('SOCKET: Disconnected');
      stopSendingMessages(); // Stop any ongoing messages on disconnect
    });

    // Listen for error events
    _socket?.onError((error) {
      print('SOCKET: error: $error');
    });

    // Listen for reconnection events
    _socket?.onReconnect((attempt) {
      print('SOCKET: Reconnected - (after $attempt attempts)');
    });
  }

  /// Sends a message to a specific channel if the socket is connected.
  void sendMessage({required String channel, required dynamic message}) {
    if (_socket?.connected ?? false) {
      _socket?.emit(
        channel,
        message,
      ); // Emit the message to the specified channel
      print('SOCKET: Sent to $channel: $message');
    } else {
      print(
          'SOCKET: Socket is not connected, message not sent to channel -> $channel');
    }
  }

  void ping() {
    stopSendingMessages();
    _timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      sendMessage(channel: 'ride_ongoing', message: {
        'latitude': mainState.userLatitude,
        'longitude': mainState.userLongitude,
      });
    });
  }

  void pong(Function(dynamic) callback) {
    _socket?.on('ride_ongoing', (data) {
      callback(data);
    });
  }

  /// Sends a message to a specific channel if the socket is connected.
  void sendMessagePeriodic({
    required String channel,
    required dynamic message,
    int? every,
  }) {
    stopSendingMessages(); // Stop any existing timer before starting a new one

    if (every != null) {
      // If an interval is provided, send the message periodically
      _timer = Timer.periodic(Duration(seconds: every), (Timer t) {
        sendMessage(
          channel: channel,
          message: channel == 'ride_ongoing'
              ? {
                  'latitude': mainState.userLatitude,
                  'longitude': mainState.userLongitude,
                }
              : message,
        ); // Send the message at defined intervals
      });
    } else {
      // If no interval is provided, send the message once
      sendMessage(
        channel: channel,
        message: message,
      );
    }
  }

  /// Stops sending messages by canceling the timer.
  void stopSendingMessages() {
    _timer?.cancel(); // Cancel the timer if it exists
    _timer = null; // Clear the timer reference
  }

  /// Listens for specific events and triggers a callback with the received data.
  ///
  /// [event]: The event to listen for.
  /// [callback]: The function to call when the event is received.
  void listen({required String event, required Function(dynamic) callback}) {
    _socket?.on(event, (data) {
      print('SOCKET: $event -> $data');
      callback(data); // Invoke the callback with the received data
    });
  }

  /// Disconnects the socket and stops any ongoing message sending.
  void disconnect() {
    stopSendingMessages(); // Ensure ongoing messages are stopped
    _socket?.disconnect(); // Disconnect the socket
  }

  /// Disposes of the socket service, cleaning up resources.
  void dispose() {
    stopSendingMessages(); // Stop the timer to avoid leaks
    if (_socket != null) {
      print('SOCKET: Disposing');
      _socket?.disconnect(); // Disconnect the socket
      _socket?.destroy(); // Destroy the socket instance to free resources
      _socket = null; // Set the socket to null
    }
  }
}
