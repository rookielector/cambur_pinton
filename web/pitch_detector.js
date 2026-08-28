/**
 * Web Audio API Microphone Pitch Detector for Cuatro Venezolano
 * Autocorrelation algorithm optimized for real-time instrument tuning on iOS/Android/Desktop browsers.
 */
window.cuatroPitchDetector = {
  audioCtx: null,
  mediaStream: null,
  analyser: null,
  isListening: false,

  start: async function() {
    try {
      if (this.isListening) return;

      const AudioContext = window.AudioContext || window.webkitAudioContext;
      if (!this.audioCtx) {
        this.audioCtx = new AudioContext();
      }

      if (this.audioCtx.state === 'suspended') {
        await this.audioCtx.resume();
      }

      // Request microphone access with echo cancellation and noise suppression
      this.mediaStream = await navigator.mediaDevices.getUserMedia({
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: false,
        }
      });

      const source = this.audioCtx.createMediaStreamSource(this.mediaStream);
      this.analyser = this.audioCtx.createAnalyser();
      this.analyser.fftSize = 2048;
      source.connect(this.analyser);

      this.isListening = true;
      console.log("[CuatroPitchDetector] Microphone stream started successfully.");

      // Dispatch event to inform Flutter app that mic is active
      window.dispatchEvent(new CustomEvent('cuatroPitchStatus', {
        detail: { active: true, message: 'Micrófono activo' }
      }));

      const buffer = new Float32Array(this.analyser.fftSize);

      const processFrame = () => {
        if (!this.isListening) return;

        this.analyser.getFloat32Array(buffer);

        // 1. Calculate RMS volume to filter out silent background noise
        let sum = 0;
        for (let i = 0; i < buffer.length; i++) {
          sum += buffer[i] * buffer[i];
        }
        const rms = Math.sqrt(sum / buffer.length);

        if (rms < 0.012) {
          // Silent or extremely low ambient noise
          window.dispatchEvent(new CustomEvent('cuatroPitchData', {
            detail: { pitch: -1, rms: rms }
          }));
        } else {
          // 2. Perform Autocorrelation pitch detection
          const pitch = this.autoCorrelate(buffer, this.audioCtx.sampleRate);
          window.dispatchEvent(new CustomEvent('cuatroPitchData', {
            detail: { pitch: pitch, rms: rms }
          }));
        }

        if (this.isListening) {
          requestAnimationFrame(processFrame);
        }
      };

      processFrame();
    } catch (err) {
      console.error("[CuatroPitchDetector] Error accessing microphone:", err);
      this.isListening = false;
      window.dispatchEvent(new CustomEvent('cuatroPitchError', {
        detail: { error: err.toString() }
      }));
    }
  },

  stop: function() {
    this.isListening = false;
    if (this.mediaStream) {
      this.mediaStream.getTracks().forEach(track => track.stop());
      this.mediaStream = null;
    }
    console.log("[CuatroPitchDetector] Microphone stream stopped.");
    window.dispatchEvent(new CustomEvent('cuatroPitchStatus', {
      detail: { active: false, message: 'Micrófono detenido' }
    }));
  },

  autoCorrelate: function(buf, sampleRate) {
    const SIZE = buf.length;
    let r1 = 0, r2 = SIZE - 1;
    const thres = 0.2;

    for (let i = 0; i < SIZE / 2; i++) {
      if (Math.abs(buf[i]) < thres) {
        r1 = i;
        break;
      }
    }
    for (let i = 1; i < SIZE / 2; i++) {
      if (Math.abs(buf[SIZE - i]) < thres) {
        r2 = SIZE - i;
        break;
      }
    }

    const trimmedBuf = buf.slice(r1, r2);
    const bufLen = trimmedBuf.length;
    if (bufLen === 0) return -1;

    const c = new Float32Array(bufLen);
    for (let i = 0; i < bufLen; i++) {
      for (let j = 0; j < bufLen - i; j++) {
        c[i] = c[i] + trimmedBuf[j] * trimmedBuf[j + i];
      }
    }

    let d = 0;
    while (d < bufLen - 1 && c[d] > c[d + 1]) {
      d++;
    }

    let maxval = -1, maxpos = -1;
    for (let i = d; i < bufLen; i++) {
      if (c[i] > maxval) {
        maxval = c[i];
        maxpos = i;
      }
    }

    let T0 = maxpos;
    if (T0 <= 0 || T0 >= bufLen - 1) return -1;

    // Parabolic interpolation for sub-sample accuracy
    const x1 = c[T0 - 1], x2 = c[T0], x3 = c[T0 + 1];
    const a = (x1 + x3 - 2 * x2) / 2;
    const b = (x3 - x1) / 2;
    if (a !== 0) {
      T0 = T0 - b / (2 * a);
    }

    const pitch = sampleRate / T0;
    // Cuatro frequency range: ~100 Hz to ~800 Hz
    if (pitch >= 100 && pitch <= 850) {
      return pitch;
    }

    return -1;
  }
};
