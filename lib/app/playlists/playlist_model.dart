import 'package:music/data/audio.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class PlaylistModel extends SafeChangeNotifier {
  final Set<Audio> _likedAudios = {};
  Set<Audio> get likedAudios => _likedAudios;
  void addLikedAudio(Audio audio) {
    for (var a in likedAudios) {
      if (a.path == audio.path) {
        return;
      }
    }
    _likedAudios.add(audio);
    notifyListeners();
  }

  bool liked(Audio audio) {
    for (var a in likedAudios) {
      if (audio.path == a.path) {
        return true;
      }
    }
    return false;
  }

  void removeLikedAudio(Audio audio) {
    for (var a in likedAudios) {
      if (audio.path == a.path) {
        _likedAudios.remove(audio);
        notifyListeners();
        return;
      }
    }
  }

  final Set<Audio> _starredStations = {};
  Set<Audio> get starredStations => _starredStations;
  void addStarredStation(Audio station) {
    _starredStations.add(station);
    notifyListeners();
  }

  final Map<String, Set<Audio>> _playlists = {};
  Map<String, Set<Audio>> get playlists => _playlists;
  List<Audio> getPlaylistAt(int index) =>
      _playlists.entries.elementAt(index).value.toList();
  void addPlaylist(String name, List<Audio> audios) {
    _playlists.putIfAbsent(name, () => Set.from(audios));
    notifyListeners();
  }

  void updatePlaylistName(String oldName, String newName) {
    if (newName == oldName) return;
    final oldList = _playlists[oldName];
    if (oldList != null) {
      _playlists.remove(oldName);
      _playlists.putIfAbsent(newName, () => oldList);
    }

    notifyListeners();
  }

  void removePlaylist(String name) {
    _playlists.remove(name);
    notifyListeners();
  }

  void addAudioToPlaylist(String playlist, Audio audio) {
    final p = _playlists[playlist];
    if (p != null) {
      for (var e in p) {
        if (e.path == audio.path) {
          return;
        }
      }
      p.add(audio);
    }
    notifyListeners();
  }

  void removeAudioFromPlaylist(String playlist, Audio audio) {
    final p = _playlists[playlist];
    if (p != null && p.contains(audio)) {
      p.remove(audio);
    }
    notifyListeners();
  }

  Future<void> init() async {
    _playlists.putIfAbsent('likedAudio', () => _likedAudios);
  }
}