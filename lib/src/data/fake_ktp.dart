import 'package:faker_dart/faker_dart.dart';
import 'package:intl/intl.dart';
import 'package:ktp_scan/src/data/ktp.dart';

String _randomBlood() => (blood..shuffle()).first;
String _randomReligion() => (religion..shuffle()).first;
String _randomMarriage() => (marriageStat..shuffle()).first;
String _birthDate() {
  final faker = Faker.instance;
  return DateFormat('dd-MMM-yyyy').format(
    faker.date.past(
      DateTime.now(),
      rangeInYears: faker.datatype.number(max: 100),
    ),
  );
}

mixin FakeKtp {
  static Ktp create({
    String? fullName,
    String? sex,
    String? job,
  }) {
    final faker = Faker.instance;
    fullName = fullName ?? faker.name.fullName();
    sex = sex ?? faker.name.gender(binary: true);
    job = job ?? faker.name.jobType();
    return Ktp(
      nik: faker.datatype.uuid(),
      name: fullName,
      birthDate: _birthDate(),
      bloodType: _randomBlood(),
      birthPlace: faker.address.city(),
      sex: sex,
      address: faker.address.streetName(),
      rt: faker.address.zipCode(format: '###'),
      rw: faker.address.zipCode(format: '###'),
      kelurahan: faker.address.city(),
      kecamatan: faker.address.state(),
      religion: _randomReligion(),
      marriageStat: _randomMarriage(),
      occupation: job,
      province: faker.address.state(),
      city: faker.address.city(),
      pictureUrl: faker.image.unsplash.people(w: 82, h: 82, keyword: 'face'),
    );
  }
}
