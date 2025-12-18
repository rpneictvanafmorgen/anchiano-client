import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class RealtimeService {
  StompClient? _client;

  bool get isConnected => _client?.connected ?? false;

  void connect({
    required String baseUrl,
    required String jwt,
    void Function()? onConnected,
    void Function(String error)? onError,
  }) {
    final wsUrl = _toWebSocketUrl(baseUrl);

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        stompConnectHeaders: {'Authorization': 'Bearer $jwt'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $jwt'},
        onConnect: (StompFrame frame) => onConnected?.call(),
        onWebSocketError: (dynamic error) => onError?.call(error.toString()),
        onStompError: (StompFrame frame) =>
            onError?.call(frame.body ?? 'Unknown STOMP error'),
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _client!.activate();
  }

  void Function() subscribeTasks(
    int workspaceId, {
    required void Function(Map<String, dynamic> event) onEvent,
  }) {
    final client = _client;
    if (client == null) return () {};

    return client.subscribe(
      destination: '/topic/workspaces/$workspaceId/tasks',
      callback: (StompFrame frame) {
        final body = frame.body;
        if (body == null || body.isEmpty) return;
        try {
          onEvent(jsonDecode(body) as Map<String, dynamic>);
        } catch (_) {}
      },
    );
  }

  void Function() subscribeAudit(
    int workspaceId, {
    required void Function(Map<String, dynamic> event) onEvent,
  }) {
    final client = _client;
    if (client == null) return () {};

    return client.subscribe(
      destination: '/topic/workspaces/$workspaceId/audit',
      callback: (StompFrame frame) {
        final body = frame.body;
        if (body == null || body.isEmpty) return;
        try {
          onEvent(jsonDecode(body) as Map<String, dynamic>);
        } catch (_) {}
      },
    );
  }

  void Function() subscribeMyWorkspaces({
    required void Function(Map<String, dynamic> event) onEvent,
  }) {
    final client = _client;
    if (client == null || !client.connected) return () {};

    return client.subscribe(
      destination: '/user/queue/workspaces',
      callback: (StompFrame frame) {
        final body = frame.body;
        if (body == null || body.isEmpty) return;
        try {
          onEvent(jsonDecode(body) as Map<String, dynamic>);
        } catch (_) {}
      },
    );
  }

  void Function() subscribeMyWorkspacesWhenConnected({
    required void Function(Map<String, dynamic> event) onEvent,
    Duration pollInterval = const Duration(milliseconds: 250),
    Duration timeout = const Duration(seconds: 10),
  }) {
    Timer? pollTimer;
    Timer? timeoutTimer;

    void Function() unsubscribe = () {};

    void cleanup() {
      pollTimer?.cancel();
      pollTimer = null;
      timeoutTimer?.cancel();
      timeoutTimer = null;
    }

    void trySubscribe() {
      final client = _client;
      if (client == null || !client.connected) return;

      cleanup();
      unsubscribe = subscribeMyWorkspaces(onEvent: onEvent);
    }

    if (isConnected) {
      unsubscribe = subscribeMyWorkspaces(onEvent: onEvent);
      return () {
        cleanup();
        unsubscribe();
      };
    }

    pollTimer = Timer.periodic(pollInterval, (_) => trySubscribe());

    timeoutTimer = Timer(timeout, () {
      cleanup();
    });

    return () {
      cleanup();
      unsubscribe();
    };
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
  }

  String _toWebSocketUrl(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final host = uri.host;
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '$scheme://$host$port/ws';
  }

  void sendPresenceEnter({required int workspaceId, required int taskId}) {
    final client = _client;
    if (client == null || !client.connected) return;

    client.send(
      destination: '/app/presence/workspaces/$workspaceId/tasks/$taskId/enter',
      body: '',
    );
  }

  void sendPresenceLeave({required int workspaceId, required int taskId}) {
    final client = _client;
    if (client == null || !client.connected) return;

    client.send(
      destination: '/app/presence/workspaces/$workspaceId/tasks/$taskId/leave',
      body: '',
    );
  }

  void Function() subscribeTaskPresence(
    int workspaceId,
    int taskId, {
    required void Function(List<dynamic> viewers) onEvent,
  }) {
    final client = _client;
    if (client == null) return () {};

    return client.subscribe(
      destination: '/topic/workspaces/$workspaceId/tasks/$taskId/presence',
      callback: (frame) {
        final body = frame.body;
        if (body == null || body.isEmpty) return;
        try {
          final decoded = jsonDecode(body);
          if (decoded is List) onEvent(decoded);
        } catch (_) {}
      },
    );
  }
}
