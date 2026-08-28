// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

class PitchDetectorWebService {
  static final PitchDetectorWebService _instance = PitchDetectorWebService._internal();
  factory PitchDetectorWebService() => _instance;
  PitchDetectorWebService._internal();

  StreamController<double>? _pitchController;
  StreamController<String>? _errorController;
  StreamController<String>? _statusController;

  Stream<double>? get pitchStream => _pitchController?.stream;
  Stream<String>? get errorStream => _errorController?.stream;
  Stream<String>? get statusStream => _statusController?.stream;

  StreamSubscription? _dataSub;
  StreamSubscription? _errSub;
  StreamSubscription? _statSub;

  void start() {
    if (!kIsWeb) return;

    _pitchController ??= StreamController<double>.broadcast();
    _errorController ??= StreamController<String>.broadcast();
    _statusController ??= StreamController<String>.broadcast();

    _dataSub?.cancel();
    _errSub?.cancel();
    _statSub?.cancel();

    _dataSub = html.window.on['cuatroPitchData'].listen((event) {
      if (event is html.CustomEvent && event.detail != null) {
        final detail = event.detail;
        final pitch = (detail['pitch'] as num?)?.toDouble() ?? -1.0;
        _pitchController?.add(pitch);
      }
    });

    _errSub = html.window.on['cuatroPitchError'].listen((event) {
      if (event is html.CustomEvent && event.detail != null) {
        final err = event.detail['error']?.toString() ?? 'Error accediendo al micrófono';
        _errorController?.add(err);
      }
    });

    _statSub = html.window.on['cuatroPitchStatus'].listen((event) {
      if (event is html.CustomEvent && event.detail != null) {
        final msg = event.detail['message']?.toString() ?? '';
        _statusController?.add(msg);
      }
    });

    try {
      if (js.context.hasProperty('cuatroPitchDetector')) {
        final detector = js.context['cuatroPitchDetector'];
        if (detector != null) {
          detector.callMethod('start', []);
        }
      }
    } catch (e) {
      _errorController?.add('Error al iniciar micrófono: $e');
    }
  }

  void stop() {
    if (!kIsWeb) return;
    try {
      if (js.context.hasProperty('cuatroPitchDetector')) {
        final detector = js.context['cuatroPitchDetector'];
        if (detector != null) {
          detector.callMethod('stop', []);
        }
      }
    } catch (_) {}
    _dataSub?.cancel();
    _errSub?.cancel();
    _statSub?.cancel();
  }

  void dispose() {
    stop();
    _pitchController?.close();
    _errorController?.close();
    _statusController?.close();
    _pitchController = null;
    _errorController = null;
    _statusController = null;
  }
}
