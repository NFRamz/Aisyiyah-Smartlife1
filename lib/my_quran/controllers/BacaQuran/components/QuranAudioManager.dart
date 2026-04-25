import 'package:flutter/material.dart'; // Tambahkan ini untuk TextEditingController
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:aisyiyah_smartlife/modules/my_quran/models/BacaQuran/QuranModel.dart';

mixin QuranAudio on GetxController{
  final AudioPlayer audioPlayer = AudioPlayer(); // Player untuk Ayat Full
  final AudioPlayer wordAudioPlayer = AudioPlayer(); // Player untuk Kata (Word)
  var isPlaying = false.obs;
  var currentAyatId = "".obs;
  var playingWordUrl = "".obs;

  void initAudio(){
    // Listener Audio Ayat Full
    audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        isPlaying.value = false;
        currentAyatId.value = "";
      } else if (state.playing) {
        isPlaying.value = true;
      } else {
        isPlaying.value = false;
      }
    });

    // Listener Audio Kata
    wordAudioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playingWordUrl.value = "";
      }
    });
  }

  void disposeAudio(){
    audioPlayer.dispose();
    wordAudioPlayer.dispose();
  }

  // ==== AUDIO LOGIC ====
  Future<void> playAudio(Ayat ayat) async {
    if (ayat.audioUrl == null) return;

    if (wordAudioPlayer.playing) await wordAudioPlayer.stop();

    if (currentAyatId.value == ayat.id && isPlaying.value) {
      await audioPlayer.stop();
      return;
    }

    try {
      currentAyatId.value = ayat.id;
      await audioPlayer.setUrl(ayat.audioUrl!);
      await audioPlayer.play();
    } catch (e) {
      isPlaying.value     = false;
      currentAyatId.value = "";
    }
  }


  Future<void> stopAudio() async {
    await audioPlayer.stop();
    await wordAudioPlayer.stop();
  }


  Future<void> playWordAudio(String? url) async {
    if (url == null || url.isEmpty) return;

    try {
      if (audioPlayer.playing) {
        await audioPlayer.pause();
        isPlaying.value = false;
      }

      playingWordUrl.value = url;
      await wordAudioPlayer.stop();
      await wordAudioPlayer.setUrl(url);
      await wordAudioPlayer.play();
    } catch (e) {
      print("Error playing word:");
    }
  }

}