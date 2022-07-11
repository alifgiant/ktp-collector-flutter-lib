import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ktp_scan/ktp_scan.dart';

class KtpOcrResult {
  final Ktp ktp;
  final String rawText;

  KtpOcrResult(this.ktp, this.rawText);
}

enum KtpOcrError { empty, notDetected, multipleDetected }

class KtpOcr {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  void dispose() {
    textRecognizer.close();
  }

  /// You have to add [directDispose] as true
  /// otherwise you have call dispose on widget dispose
  ///
  /// ```dart
  /// this.read(file, directDispose: true);
  /// ```
  Future<KtpOcrResult> read(
    File imageFile, [
    bool directDispose = false,
  ]) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await textRecognizer.processImage(inputImage);
    if (directDispose) textRecognizer.close();

    if (recognizedText.blocks.isEmpty) throw KtpOcrError.empty;

    // sorted text line
    List<TextLine> lineEntries = _sortedLineRead(recognizedText);
    // group lines
    List<List<TextLine>> groupText = _groupText(lineEntries);
    // parse group into KTP data
    KtpOcrResult? result = _parse(groupText);

    return result;
  }

  List<TextLine> _sortedLineRead(RecognizedText recognizedText) {
    return recognizedText.blocks
        .map((e) => e.lines)
        .reduce((prev, current) => prev + current)
      ..sort((a, b) => (a.boundingBox.top - b.boundingBox.top).toInt());
  }

  List<List<TextLine>> _groupText(List<TextLine> entries) {
    TextLine prev = entries.first;
    List<List<TextLine>> lineTextCollection = [];
    List<TextLine> lineText = [];

    void addLines(TextLine entry) {
      lineText.sort(
        (a, b) => (a.boundingBox.left - b.boundingBox.left).toInt(),
      );
      lineTextCollection.add(lineText);
      lineText = [entry];
    }

    for (TextLine entry in entries) {
      if (prev == entry) {
        lineText.add(entry);
      } else if (entry.boundingBox.top >= prev.boundingBox.top &&
          entry.boundingBox.top < prev.boundingBox.bottom) {
        final prevSpace = prev.boundingBox.bottom - prev.boundingBox.top;
        final curSpace = entry.boundingBox.bottom - entry.boundingBox.top;
        final diffSpace = prev.boundingBox.bottom - entry.boundingBox.top;

        final prevPercent = diffSpace / (prevSpace + 0.1);
        final curPercent = diffSpace / (curSpace + 0.1);

        if (prevPercent >= 0.7 && curPercent >= 0.7) {
          lineText.add(entry);
        } else {
          addLines(entry);
        }
      } else {
        addLines(entry);
      }
      prev = entry;
    }

    if (lineText.isNotEmpty) lineTextCollection.add(lineText);
    return lineTextCollection;
  }

  KtpOcrResult _parse(List<List<TextLine>> texLine) {
    final texts = texLine.map(
      (line) => line.map((e) => e.text),
    );
    final rawText = texts.fold<String>(
      '',
      (previousValue, element) {
        final str = element.join(' ');
        return '$previousValue\n$str';
      },
    ).trim();

    String nik = _parseNIK(rawText);
    String name = '';
    String birthPlace = '';
    String birthDate = _parseBirthDate(rawText);
    String bloodType = '';
    String sex = _parseSex(rawText);
    String address = '';
    String rt = _parseRtRw(rawText, 0);
    String rw = _parseRtRw(rawText, 1);
    String kelurahan = '';
    String kecamatan = '';
    String religion = '';
    String marriageStat = '';
    String occupation = '';
    String province = '';
    String city = '';

    for (final text in texts) {
      if (_parseProvince(text.c()).isNotEmpty) {
        province = _parseProvince(text);
      } else if (_parseCity(text.c()).isNotEmpty) {
        city = _parseCity(text);
      } else if (_parseName(text.c()).isNotEmpty) {
        name = _parseName(text);
      } else if (_parseBirthPlace(text.c()).isNotEmpty) {
        birthPlace = _parseBirthPlace(text);
      } else if (_parseBlood(text.c()).isNotEmpty) {
        bloodType = _parseBlood(text);
      } else if (_parseAddress(text.c()).isNotEmpty) {
        address = _parseAddress(text);
      } else if (_parseKelurahan(text.c()).isNotEmpty) {
        kelurahan = _parseKelurahan(text);
      } else if (_parseCamat(text.c()).isNotEmpty) {
        kecamatan = _parseCamat(text.c());
      } else if (_parseReligion(text.c()).isNotEmpty) {
        religion = _parseReligion(text);
      } else if (_parseMarriage(text.c()).isNotEmpty) {
        marriageStat = _parseMarriage(text);
      } else if (_parseOccupation(text.c()).isNotEmpty) {
        occupation = _parseOccupation(text);
      }
    }

    final ktp = Ktp(
      nik: nik,
      name: name,
      birthPlace: birthPlace,
      birthDate: birthDate,
      bloodType: bloodType,
      sex: sex,
      address: address,
      rt: rt,
      rw: rw,
      kelurahan: kelurahan,
      kecamatan: kecamatan,
      religion: religion,
      marriageStat: marriageStat,
      occupation: occupation,
      province: province,
      city: city,
    );

    return KtpOcrResult(ktp, rawText);
  }

  String _parseNIK(String text) {
    final nikRegex = RegExp(r'[0-9]{16}', caseSensitive: false);
    final match = nikRegex.allMatches(text);

    if (match.isEmpty) throw KtpOcrError.notDetected;
    // currently only support 1 KTP on Each Image
    if (match.length > 1) throw KtpOcrError.multipleDetected;

    return match.first.group(0) ?? '';
  }

  String _parseName(Iterable<String> iText) {
    final text = iText.toList();
    final i = text.indexWhere(
      (element) => element.toLowerCase().contains('nama'),
    );
    if (i < 0) return '';
    text.removeAt(i);
    return text.clearJoin();
  }

  String _parseBirthPlace(Iterable<String> text) {
    final rawText = text.join(' ').toLowerCase();
    final i = rawText.indexOf('lahir');
    if (i < 0) return '';
    final removedDate = rawText.replaceAll(
      RegExp(
        r'[0-9]{1,2}[- ][0-9]{1,2}[- ][0-9]{1,4}',
        caseSensitive: false,
      ),
      '',
    );
    final place = removedDate.substring(i + 5);
    return place.clean([',']);
  }

  String _parseBlood(Iterable<String> text) {
    final rawText = text.join(' ').toLowerCase();
    final i = rawText.indexOf('darah');
    if (i < 0) return '';
    final darah = rawText.substring(rawText.length - 2);
    final clean = darah.clean(['-']);
    final darahIsCorrect = ['a', 'b', 'ab', 'o'].contains(clean);
    return darahIsCorrect ? clean : '';
  }

  String _parseAddress(Iterable<String> iText) {
    final text = iText.toList();
    final i = text.indexWhere(
      (element) => element.toLowerCase().contains('alamat'),
    );
    if (i < 0) return '';

    text.removeAt(i);
    return text.clearJoin([' ']);
  }

  String _parseRtRw(String rawText, int i) {
    final rtRwRegex = RegExp(
      r'[0-9]{3}[/ ][0-9]{3}',
      caseSensitive: false,
    );
    final match = rtRwRegex.allMatches(rawText);
    if (match.isEmpty) return '';

    String search = match.first.group(0) ?? '';
    if (search.isEmpty) return '';

    final rtRw = search.replaceAll(' ', '/');

    return rtRw.split('/')[i];
  }

  String _parseBirthDate(String rawText) {
    final nikRegex = RegExp(
      r'[0-9]{1,2}[- ][0-9]{1,2}[- ][0-9]{1,4}',
      caseSensitive: false,
    );
    final match = nikRegex.allMatches(rawText);

    String date = '';
    if (match.isNotEmpty) date = match.first.group(0) ?? '';

    return date.replaceAll(' ', '-');
  }

  String _parseSex(String rawText) {
    final text = rawText.toLowerCase();
    final isFemale = text.contains('perempuan');
    final isMale = text.contains('laki');
    return isFemale
        ? 'perempuan'
        : isMale
            ? 'laki-laki'
            : '';
  }

  String _parseKelurahan(Iterable<String> all) {
    final text = all.join(' ').split(' ');
    final i = text.indexWhere(
      (element) =>
          element.toLowerCase().contains('kel') ||
          element.toLowerCase().contains('desa'),
    );
    if (i < 0) return '';

    final lurah = text.sublist(i + 1);
    return lurah.clearJoin(['/', 'kel', 'desa']);
  }

  String _parseCamat(Iterable<String> all) {
    final text = all.join(' ').split(' ');
    final i = text.indexWhere(
      (element) => element.toLowerCase().contains('camat'),
    );
    if (i < 0) return '';

    final camat = text.sublist(i + 1);
    return camat.clearJoin([' ']);
  }

  String _parseReligion(Iterable<String> iText) {
    final text = iText.toList();
    final i = text.indexWhere(
      (element) => element.toLowerCase().contains('agama'),
    );
    if (i < 0) return '';

    text.removeAt(i);
    return text.clearJoin([' ']);
  }

  String _parseMarriage(Iterable<String> text) {
    final rawText = text.join(' ').toLowerCase();
    final isNoMariage = rawText.contains('belum');
    final isMarried = rawText.contains('kawin');

    return isNoMariage
        ? 'belum kawin'
        : isMarried
            ? 'kawin'
            : '';
  }

  String _parseOccupation(Iterable<String> all) {
    final text = all.join(' ').split(' ');
    final i = text.indexWhere(
      (element) => element.toLowerCase().contains('kerja'),
    );
    if (i < 0) return '';

    final job = text.sublist(i + 1);
    return job.clearJoin();
  }

  String _parseProvince(Iterable<String> all) {
    final text = all.join(' ').split(' ');
    final i = text.indexWhere(
      (element) => element.toLowerCase().contains('provinsi'),
    );
    if (i < 0) return '';

    text.removeAt(i);
    return text.clearJoin(['provinsi']);
  }

  String _parseCity(Iterable<String> all) {
    final text = all.join(' ').split(' ');
    final i = text.indexWhere(
      (element) =>
          element.toLowerCase().contains('kota') ||
          element.toLowerCase().contains('kabupaten'),
    );
    if (i < 0) return '';

    text.removeAt(i);
    return text.clearJoin(['kota', 'kabupaten']);
  }
}

extension on String {
  String clean([List<String> removeKey = const []]) {
    final cleaned = replaceAll(':', '');
    return removeKey
        .fold<String>(
          cleaned,
          (previousValue, element) =>
              previousValue.toLowerCase().replaceAll(element, ''),
        )
        .trim();
  }
}

extension on Iterable<String> {
  String clearJoin([List<String> removeKey = const []]) {
    return join(' ').clean(removeKey);
  }

  List<String> c() {
    return toList();
  }
}
